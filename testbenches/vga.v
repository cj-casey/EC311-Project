`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2023 05:58:42 PM
// Design Name: 
// Module Name: vga
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module vga_controller_640_60 (pixel_clk,HS,VS,hcounter,vcounter,blank);

	input pixel_clk;
	output HS, VS, blank;
	output [10:0] hcounter, vcounter;

	parameter HMAX = 800; // maximum value for the horizontal pixel counter
	parameter VMAX = 525; // maximum value for the vertical pixel counter
	parameter HLINES = 640; // total number of visible columns
	parameter HFP = 648; // value for the horizontal counter where front porch ends
	parameter HSP = 744; // value for the horizontal counter where the synch pulse ends
	parameter VLINES = 480; // total number of visible lines
	parameter VFP = 482; // value for the vertical counter where the front porch ends
	parameter VSP = 484; // value for the vertical counter where the synch pulse ends
	parameter SPP = 0;


	wire video_enable;
	reg HS,VS,blank;
	reg [10:0] hcounter,vcounter;

	always@(posedge pixel_clk)begin
		blank <= ~video_enable; 
	end

	always@(posedge pixel_clk)begin
		if (hcounter == HMAX) hcounter <= 0;
		else hcounter <= hcounter + 1;
	end

	always@(posedge pixel_clk)begin
		if(hcounter == HMAX) begin
			if(vcounter == VMAX) vcounter <= 0;
			else vcounter <= vcounter + 1; 
		end
	end

	always@(posedge pixel_clk)begin
		if(hcounter >= HFP && hcounter < HSP) HS <= SPP;
		else HS <= ~SPP; 
	end

	always@(posedge pixel_clk)begin
		if(vcounter >= VFP && vcounter < VSP) VS <= SPP;
		else VS <= ~SPP; 
	end

	assign video_enable = (hcounter < HLINES && vcounter < VLINES) ? 1'b1 : 1'b0;

endmodule


// top module that instantiate the VGA controller and generate images
module vga(
    input wire CLK100MHZ,
    input [14:0] movementData,
    input up, down, left, right,
    output reg [3:0] VGA_R,
    output reg [3:0] VGA_G,
    output reg [3:0] VGA_B,
    output wire VGA_HS,
    output wire VGA_VS,
    output reg LED
    );

parameter BW = 12;
parameter WALL_NUM = 10;
parameter wall_w = 10;
reg pclk_div_cnt;
reg pixel_clk;
reg move_clk_cnt;
reg [31:0] move_clk;
wire [10:0] vga_hcnt, vga_vcnt;
wire vga_blank;
reg [10:0] h_min, h_max, v_min, v_max;
reg [10:0] wh_min, wh_max, wv_min, wv_max;
reg [10:0] top_screen, bottom_screen, right_screen, left_screen;
reg [10:0] x,y,x1,y1;
reg [10:0] vx,vy;
reg [3:0] green,red,blue;
reg collision_x, collision_y;
//wire [10:0] random;
wire [WALL_NUM-1:0] wall_x [10:0];
wire [WALL_NUM-1:0] wall_y [10:0];

//genvar k;
//generate
//	for (k=0; k<WALL_NUM; k=k+1) begin
//		wall #(.START(50*k+k*k+5)) w1 (.pixel_clk(pixel_clk), .x(wall_x[k]), .y(wall_y[k]));
//	end
//endgenerate


initial begin
h_min = 300;
h_max = 340;
v_min = 200;
v_max = 400;
x = 100;
y = 100;
move_clk_cnt = 0;
move_clk = 0;
LED = 0;
top_screen = 1;
bottom_screen = 479;
right_screen = 639;
left_screen = 1;
end

wire refresh_tick;
assign refresh_tick = ((vga_vcnt == 481 ) && (vga_hcnt == 0)) ? 1:0;

// Clock divider. Generate 25MHz pixel_clk from 100MHz clock.
always @(posedge CLK100MHZ) begin
    pclk_div_cnt <= !pclk_div_cnt;
    if (pclk_div_cnt == 1'b1) pixel_clk <= !pixel_clk;
end

always @(posedge CLK100MHZ) begin
    move_clk_cnt = move_clk_cnt + 1;
    if (move_clk_cnt == 5000)begin
    move_clk = ~move_clk;
    move_clk_cnt = 0;
    end
end


// Instantiate VGA controller
vga_controller_640_60 vga_controller(
    .pixel_clk(pixel_clk),
    .HS(VGA_HS),
    .VS(VGA_VS),
    .hcounter(vga_hcnt),
    .vcounter(vga_vcnt),
    .blank(vga_blank)
);

parameter START = 4;

// LFSR  LFSR_maze
//          (.i_Clk(pixel_clk),
//           .i_Enable(1'b1),
//           .i_Seed_DV(1'b0),
//           .i_Seed_Data(START), // Replication
//           .o_LFSR_Data(random),
//           .o_LFSR_Done()
//           );

// Generate figure to be displayed
// Decide the color for the current pixel at index (hcnt, vcnt).
// This example displays an white square at the center of the screen with a colored checkerboard background.

always @ * begin 
if (up) begin
vy = -2;
end
else if (down) begin
vy = 2;
end
else
vy = 0;
end

always @ * begin
if (left) begin
vx = -2;
end
else if (right) begin
vx = 2;
end
else 
vx = 0;
end

wire [10:0] square_top, square_bottom, square_left, square_right;
parameter square_length = 20;

assign square_top = y;
assign square_bottom = y + square_length;
assign square_left = x;
assign square_right = x + square_length;


always @ (posedge refresh_tick) begin

if ((square_left + vx) <= h_max && (square_right + vx) >= h_min && square_bottom >= v_min && square_top <= v_max) begin
collision_x = 1;
end

if ((square_left + vx) <= left_screen || (square_right + vx) >= right_screen) begin
collision_x = 1;
end

//if ((square_right + vx) >= 639) begin
//collision_x = 1;
//end

if (square_left <= h_max && square_right >= h_min && (square_bottom + vy) >= v_min && (square_top + vy) <= v_max) begin
collision_y = 1;
end

if ((square_top + vy) <= top_screen || (square_bottom + vy) >= bottom_screen) begin
collision_y = 1;
end

//if ((square_bottom + vy) >= 479) begin
//collision_y = 1;
//end

if (collision_x == 0) begin
x = x + vx;
end

if (collision_y == 0) begin
y = y + vy;
end

collision_x = 0;
collision_y = 0;

end


always @ * begin
if (collision_x == 1 || collision_y == 1) begin
    red = 4'hf;
    green = 0;
end
else begin
red = 0;
green = 4'hf;
end
end

integer i;
always @(*) begin
    // Set pixels to black during Sync. Failure to do so will result in dimmed colors or black screens.
    if (vga_blank) begin 
        VGA_R = 0;
        VGA_G = 0;
        VGA_B = 0;
    end
    else begin  // Image to be displayed
        // Default values for the checkerboard background
        VGA_R = 4'hf;
        VGA_G = 4'hf;
        VGA_B = 4'hf;
        
        

        if ((vga_hcnt >= (h_min ) && vga_hcnt <= (h_max )) &&
        	((vga_vcnt >= (v_min)) && vga_vcnt <= (v_max) )) begin
			VGA_R = 0;
			VGA_G = 0;
			VGA_B = 4'hf;
	    end
	    
	    if ((vga_hcnt >= (square_left ) && vga_hcnt <= (square_right )) &&
        	((vga_vcnt >= (square_top)) && vga_vcnt <= (square_bottom) )) begin
			VGA_R = red;
			VGA_G = green;
			VGA_B = 0;
	    end
//        else begin 
//			for(i=0; i<WALL_NUM; i=i+1) begin
//				if ((vga_hcnt >= wall_x[i] + wall_w) && (vga_hcnt <=  wall_x[i] + wall_w) &&
//        		((vga_vcnt >=  wall_y[i] + wall_w) && vga_vcnt <=  wall_y[i] + wall_w)) begin
//					VGA_R = 0;
//					VGA_G = 0;
//					VGA_B = 0;
//				end
        	
       /* 
        
       e=
        h_min <= h_min + movementData[9:4];
        v_min <= v_min + movementData[4:0];
        h_max <= h_max + movementData[9:4];
        v_max <= v_max + movementData[4:0];
        */
    	end
	end


endmodule

