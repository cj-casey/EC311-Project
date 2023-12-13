`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2023 11:17:35 AM
// Design Name: 
// Module Name: VGA_Main
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


module VGA_Main(
    input wire in_clk,
    input [9:0] movementData,
    input wire reset,
    input wire posr,
    output reg [3:0] VGA_RB,
    output reg [3:0] VGA_GB,
    output reg [3:0] VGA_BB,
    output [7:0] anode,
    output [6:0] cathode,
    output [1:0] col,
    output wire hs,
    output wire vs
    );
    
    wire clk_pix,clk_mvm;
    wire w1,w2;
    wire [10:0] vga_hcnt, vga_vcnt;
    reg signed [15:0] x = 0,y = 0;
    wire vga_blank;
    wire [31:0] sseg_number;
    
    
    //movement_clock VGA_Move_Gen(in_clk,clk_mvm);
    clock_gen VGA_Clock_Gen(in_clk,clk_pix);
    signal_generation VGA_Signal_Gen(
.pixel_clk(clk_pix),
.HS(hs),
.VS(vs),
.hcounter(vga_hcnt),
.vcounter(vga_vcnt),
.blank(vga_blank));

wire fast_clock;
wire fast_clock2;
wire fsec;
wire sec_clock;
wire hsec_clock;
wire rand_enable;


 fsm fsm1(fast_clock,sseg_number,cathode,anode);
 
 Clock_divider cd1(in_clk,fast_clock);
 defparam cd1.number = 50000;
 
 Clock_divider cd2(in_clk,fast_clock2);
 defparam cd2.number = 40000;
 
  Clock_divider cd3(in_clk,hsec_clock);
  defparam cd3.number = 50000000/2;
  
  Clock_divider cd4(in_clk,fsec);
  defparam cd4.number = 50000000*5;
  
  


  
  Clock_divider cd5(in_clk,sec_clock);

parameter pcount = 400;

//parameter b_length = 94;
//parameter b_width = 94;

//parameter y_dimensions = 5;
//parameter x_dimensions = 5;

parameter horizontal_n = 5;
parameter vertical_n = 5;
parameter hline_length = pcount/horizontal_n-2;
parameter hline_width = 2;
parameter vline_length = 2;
parameter vline_width = pcount/vertical_n-2;

wire [10:0] x1_h [horizontal_n*(vertical_n):0];
wire [10:0] x2_h [horizontal_n*(vertical_n):0];
wire [10:0] y1_h [horizontal_n*(vertical_n):0];
wire [10:0] y2_h [horizontal_n*(vertical_n):0];

wire [10:0] x1_v [horizontal_n*(vertical_n):0];
wire [10:0] x2_v [horizontal_n*(vertical_n):0];
wire [10:0] y1_v [horizontal_n*(vertical_n):0];
wire [10:0] y2_v [horizontal_n*(vertical_n):0];
wire [horizontal_n*(vertical_n):0] random_h;
wire [horizontal_n*(vertical_n):0] random_v;


reg [horizontal_n*(vertical_n):0] wall_on;

reg direction_x,direction_y;
reg signed [11:0] movement_x,movement_y;
reg [11:0] vx,vy;

reg [10:0] h_min,  v_min; 
wire [10:0] h_max, v_max;



// Clock divider. Generate 25MHz pixel_clk from 100MHz clock.



//integer num = 0;
//generate
//for (i = 0; i<x_dimensions; i=i+1) begin
//	for (j=0; j<y_dimensions; j=j+1) begin
//		block #(.length(b_length), .width(b_width)) b1 (.pixel_clk(clk_pix), .ix(i*b_length+81), .iy(j*b_width), .x1(x1[5*i+j]), .x2(x2[5*i+j]), .y1(y1[5*i+j]), .y2(y2[5*i+j]), .on(random[5*i+j]));
//	end
//end
//endgenerate
genvar i; // x
genvar j; // y

generate
for (i = 0; i<horizontal_n; i=i+1) begin
for (j = 0; j<vertical_n; j=j+1) begin
		hline #(.length(hline_length), .width(hline_width)) h1 (.pixel_clk(clk_pix), .ix(i*hline_length+((640-pcount)/2)+3), .iy(j*vline_width+vline_width), .x1(x1_h[horizontal_n*i+j]), 
		.x2(x2_h[horizontal_n*i+j]), .y1(y1_h[horizontal_n*i+j]), .y2(y2_h[horizontal_n*i+j]));
	end
end
endgenerate

generate
for (i = 0; i<vertical_n; i=i+1) begin
for (j = 0; j<horizontal_n; j=j+1) begin
		vline #(.length(vline_length), .width(vline_width)) v1 (.pixel_clk(clk_pix), .ix(i*hline_length+((640-pcount)/2)+1+pcount/horizontal_n), .iy(j*vline_width), .x1(x1_v[horizontal_n*i+j]), 
		.x2(x2_v[horizontal_n*i+j]), .y1(y1_v[horizontal_n*i+j]), .y2(y2_v[horizontal_n*i+j]));
	end
end
endgenerate


parameter left_bar = ((640-pcount)/2)+1;
parameter right_bar = ((640-pcount)/2)+pcount;
parameter top_bar = 2;
parameter bottom_bar = pcount;



parameter pwidth = 20;
parameter h_start = ((640-pcount)/2)+10;
parameter v_start = pcount - vline_width +10;
initial begin
h_min = h_start;
v_min = v_start;
end

assign h_max = h_min + pwidth;
assign v_max = v_min + pwidth;

parameter START = 30504031;

 assign sseg_number = {5'b00000,movement_y,5'b00000,movement_x};
 
 assign rand_enable = ~reset;
 
LFSR  lfsrh
            (.i_Clk(fast_clock2),
            .i_Enable(rand_enable),
            .i_Seed_DV(),
            .i_Seed_Data(START), // Replication
            .o_LFSR_Data(random_h),
            .o_LFSR_Done()
            );
 defparam lfsrh.NUM_BITS = horizontal_n*(vertical_n);
 
 LFSR  lfsrv
            (.i_Clk(fast_clock),
            .i_Enable(rand_enable),
            .i_Seed_DV(),
            .i_Seed_Data(START), // Replication
            .o_LFSR_Data(random_v),
            .o_LFSR_Done()
            );
 defparam lfsrv.NUM_BITS = horizontal_n*(vertical_n);

//parameter length = 94;
//parameter width = 95;



reg [horizontal_n*(vertical_n):0] random_hr;
reg [horizontal_n*(vertical_n):0] random_vr;



always@(posedge sec_clock) begin
        
        random_hr = random_h;
        random_vr = random_v;
        
     end 

always@(posedge clk_pix) begin
        x <= x - 1;
     end 


wire refresh_tick;
assign refresh_tick = ((vga_vcnt == 481 ) && (vga_hcnt == 0)) ? 1:0;



always @(*) begin
        movement_x = (movementData[9] == 1'b0) ? {{7{1'b0}}, movementData[8:5]} : -(16-movementData[8:5]);
        movement_y = (movementData[4] == 1'b0) ? {{7{1'b0}}, movementData[3:0]} : -(16-movementData[3:0]);
        
//        if (movement_y[11] == 1) begin
//        movement_y = ~(movement_y-1);
//        movement_y = movement_y*-1;
//        end
        
//        if (movement_x[11] == 1) begin
//        movement_x = ~(movement_x-1);
//        movement_x = movement_x*-1;
//        end
        
        if (movement_y <= -3)
        vx = 3;
        else if (movement_y >= 3)
        vx = -3;
//        else if (movement_y >= -1 && movement_y <= 1)
//        vx = 0;
        else
        vx = -movement_y;
        
        if (movement_x <= -3)
        vy = -3;
        else if (movement_x >= 3)
        vy = 3;
//        else if (movement_x >= -1 && movement_x <= 1)
//        vy = 0;
        else
        vy = movement_x;
       
end

reg collision;
reg l_collision;



always @ (posedge refresh_tick) begin
         //if ((v_min - movement_x > (5) && v_min - movement_x <= pcount )) begin
                // if ((h_min - movement_y > ((640-pcount)/2+2) && h_min - movement_y <= ((640-pcount)/2+pcount)) ) begin

         
end
assign col = {collision, l_collision};

integer k;
always @ (posedge refresh_tick) begin
     if ( left_bar >= h_min || right_bar <= h_max || bottom_bar <= v_max || top_bar >= v_min) begin
     
        collision = 1;
    end
        for (k=0; k<horizontal_n*(vertical_n); k=k+1) begin
            if(~random_hr[k]) begin

                if(h_min <= x2_h[k] && h_max >= x1_h[k] && v_max >= y1_h[k] && v_min <=  y2_h[k]) begin
                 collision = 1;
                end           
            end
            end
        for (k=0; k<horizontal_n*(vertical_n); k=k+1) begin    
            if(~random_vr[k]) begin
                if(h_min <= x2_v[k] && h_max >= x1_v[k] && v_max >= y1_v[k] && v_min <=  y2_v[k]) begin
                 collision = 1;
                end           
            end
         
        end
//          if(~random_hr[0]) begin
//             if (h_min <= x2_h[0] && h_max >= x1_h[0] && v_max >= y1_h[0] && v_min <= y2_h[0]) begin
//              collision = 1;
//        end
       // end
        if(posr || collision || l_collision) begin
            h_min = h_start;
            v_min = v_start;
         end else begin
            if(~reset) begin
                v_min = v_min + vy;
                h_min = h_min + vx;
            end
          end
        collision = 0;
    end 


always @ (posedge refresh_tick) begin
         //if ((v_min - movement_x > (5) && v_min - movement_x <= pcount )) begin
         
       //end
end

//always @ (posedge refresh_tick) begin
//         if (reset) begin
//    h_min = ((640-pcount)/2)+2;
//    v_min = pcount - vline_width +5;
//       end
//end


always @(*) begin
    // Set pixels to black during Sync. Failure to do so will result in dimmed colors or black screens.
    if (vga_blank) begin 
        VGA_RB = 0;
        VGA_GB = 0;
        VGA_BB = 0;
    end
    else begin  // Image to be displayed
        // Default values for the checkerboard background
        VGA_RB = 0;
        VGA_GB = 0;
        VGA_BB = 0;
            
//            //start
//            if ((vga_hcnt >= (81) && vga_hcnt <= (175)) && 
//            (vga_vcnt >= (386) && vga_vcnt <= (478))) begin
//            VGA_RB = 0;
//            VGA_GB = 25;
//            VGA_BB = 0;
//            end
            
//            //end
//            if ((vga_hcnt >= (465) && vga_hcnt <= (559)) && 
//            (vga_vcnt >= (2) && vga_vcnt <= (96))) begin
//            VGA_RB = 0;
//            VGA_GB = 0;
//            VGA_BB = 25;
//            end            
            
//            //top bar
//            if ((vga_hcnt >= (80) && vga_hcnt <= (560)) && (vga_vcnt == (1))) begin
//            VGA_RB = 25;
//            VGA_GB = 0;
//            VGA_BB = 0;
//            end
//            //bottom bar
//            if ((vga_hcnt >= (80) && vga_hcnt <= (560)) && (vga_vcnt == (479))) begin
//            VGA_RB = 25;
//            VGA_GB = 0;
//            VGA_BB = 0;
//            end
            
//          //left bar
//            if ((vga_hcnt == (80)) && (vga_vcnt >= (1)) && (vga_vcnt <= (479))) begin
//            VGA_RB = 255;
//            VGA_GB = 0;
//            VGA_BB = 0;
//            end   
            
//            //right bar
//            if ((vga_hcnt == (560)) && (vga_vcnt >= (1)) && (vga_vcnt <= (479))) begin
//            VGA_RB = 255;
//            VGA_GB = 0;
//            VGA_BB = 0;
//            end
            

            
            for(k=0; k<horizontal_n*(vertical_n); k=k+1) begin
                if(~random_hr[k]) begin
		 		if ((vga_hcnt >= x1_h[k]) && (vga_hcnt <=  x2_h[k]) &&
         		((vga_vcnt >=  y1_h[k]) && vga_vcnt <=  y2_h[k])) begin
	               VGA_RB = 0;
                    VGA_GB = 255;
                    VGA_BB = 0;
		 		end
		 		end
         	end
         	
         	for(k=0; k<horizontal_n*(vertical_n); k=k+1) begin
                if(~random_vr[k]) begin
		 		if ((vga_hcnt >= x1_v[k]) && (vga_hcnt <=  x2_v[k]) &&
         		((vga_vcnt >=  y1_v[k]) && vga_vcnt <=  y2_v[k])) begin
	               VGA_RB = 0;
                    VGA_GB = 255;
                    VGA_BB = 0;
		 		end
		 		end
         	end
         	      //left bar
            if ((vga_hcnt >= (((640-pcount)/2)+1)) && (vga_hcnt <= ((640-pcount)/2)+2) && (vga_vcnt >= (0)) && (vga_vcnt <= (pcount-3))) begin
            VGA_RB = 255;
            VGA_GB = 255;
            VGA_BB = 255;
            end  
//         	  //right bar
            if ((vga_hcnt >= (((640-pcount)/2)+pcount-5)) && (vga_hcnt <= (((640-pcount)/2)+pcount-4)) && (vga_vcnt >= (0)) && (vga_vcnt <= (pcount-3))) begin
            VGA_RB = 255;
            VGA_GB = 255;
            VGA_BB = 255;
            end
//             top bar
            if ((vga_hcnt >= (y1_v[0]) && (vga_hcnt <= (640-pcount)/2)+pcount) && (vga_vcnt == (0))) begin
            VGA_RB = 255;
            VGA_GB = 255;
            VGA_BB = 255;
            end
////bottom bar
            if ((vga_hcnt >= (y1_v[0]) && (vga_hcnt <= (640-pcount)/2)+pcount)&& (vga_vcnt == (pcount-4))) begin
            VGA_RB = 255;
            VGA_GB = 255;
            VGA_BB = 255;
            end
            
           

        
        // White square at the center
        if ((vga_hcnt >= (h_min) && vga_hcnt <= (h_max )) &&
            (vga_vcnt >= (v_min) && vga_vcnt <= (v_max))) begin
            VGA_RB = 4'hf;
            if(VGA_GB == 255)
                l_collision = 1;
            else
                l_collision = 0;
            VGA_BB = 4'hf;
        end

        end
    end
endmodule