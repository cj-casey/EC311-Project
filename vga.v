`timescale 1ns / 1ps

// Generate HS, VS signals from pixel clock.
// hcounter & vcounter are the index of the current pixel 
// origin (0, 0) at top-left corner of the screen
// valid display range for hcounter: [0, 640)
// valid display range for vcounter: [0, 480)
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
	input wire reset,
    input [14:0] movementData,
    output reg [3:0] VGA_R,
    output reg [3:0] VGA_G,
    output reg [3:0] VGA_B,
    output wire VGA_HS,
    output wire VGA_VS
    );

parameter WALL_NUM = 10;
parameter wall_w = 100;
reg pclk_div_cnt;
reg pixel_clk;
wire [10:0] vga_hcnt, vga_vcnt;
wire vga_blank;
reg [10:0] h_min, h_max, v_min, v_max;
reg [10:0] wh_min, wh_max, wv_min, wv_max;
//wire [10:0] random;
wire [10:0] wall_x [WALL_NUM-1:0];
wire [10:0] wall_y [WALL_NUM-1:0];

genvar k;
generate
	for (k=0; k<WALL_NUM; k=k+1) begin
		wall #(.START(50*k+k*k+5)) w1 (.pixel_clk(pixel_clk), .x(wall_x[k]), .y(wall_y[k]), .reset(reset));
	end
endgenerate


initial begin
h_min = 300;
h_max = 340;
v_min = 220;
v_max = 260;
end

// Clock divider. Generate 25MHz pixel_clk from 100MHz clock.
always @(posedge CLK100MHZ) begin
    pclk_div_cnt <= !pclk_div_cnt;
    if (pclk_div_cnt == 1'b1) pixel_clk <= !pixel_clk;
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
        
        

        if ((vga_hcnt >= (h_min + movementData[9:4]) && vga_hcnt <= (h_max + movementData[9:4])) &&
        	((vga_vcnt >= (v_min + movementData[4:0])) && vga_vcnt <= (v_max + movementData[4:0]))) begin
			VGA_R = 0;
			VGA_G = 0;
			VGA_B = 4'hf;
	    end
        // else begin 
		// 	for(i=0; i<WALL_NUM; i=i+1) begin
		// 		if ((vga_hcnt >= wall_x[i] + wall_w) && (vga_hcnt <=  wall_x[i] + wall_w) &&
        // 		((vga_vcnt >=  wall_y[i] + wall_w) && vga_vcnt <=  wall_y[i] + wall_w)) begin
		// 			VGA_R = 0;
		// 			VGA_G = 4'hf;
		// 			VGA_B = 0;
		// 		end
        // 	end
		// end
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
