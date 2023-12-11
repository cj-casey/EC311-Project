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
    input wire reset,
    
    output reg [3:0] VGA_RB,
    output reg [3:0] VGA_GB,
    output reg [3:0] VGA_BB,
    output [7:0] anode,
    output [6:0] cathode,
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
parameter hline_length = pcount/horizontal_n;
parameter hline_width = 2;
parameter vline_length = 2;
parameter vline_width = pcount/vertical_n;

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

parameter START = 30504031;


initial begin
//wall_on = 0;
end

 assign sseg_number = {5'b00000,random_v,5'b00000,random_h};
 
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

 integer k;


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
	               VGA_RB = 255;
                    VGA_GB = 255;
                    VGA_BB = 255;
		 		end
		 		end
         	end
         	
         	for(k=0; k<horizontal_n*(vertical_n); k=k+1) begin
                if(~random_vr[k]) begin
		 		if ((vga_hcnt >= x1_v[k]) && (vga_hcnt <=  x2_v[k]) &&
         		((vga_vcnt >=  y1_v[k]) && vga_vcnt <=  y2_v[k])) begin
	               VGA_RB = 255;
                    VGA_GB = 255;
                    VGA_BB = 255;
		 		end
		 		end
         	end
         	      //left bar
            if ((vga_hcnt >= (x1_h[0]-1)) && (vga_hcnt <= (x1_h[0]+1)) && (vga_vcnt >= (0)) && (vga_vcnt <= (pcount))) begin
            VGA_RB = 255;
            VGA_GB = 255;
            VGA_BB = 255;
            end  
//         	  //right bar
            if ((vga_hcnt >= (x1_h[0]+pcount-2)) && (vga_hcnt <= (x1_h[0]+pcount)) && (vga_vcnt >= (0)) && (vga_vcnt <= (pcount))) begin
            VGA_RB = 255;
            VGA_GB = 255;
            VGA_BB = 255;
            end
//             //top bar
            if ((vga_hcnt >= (x1_h[0])) && (vga_hcnt <= (x1_h[0]+pcount)) && (vga_vcnt == (0))) begin
            VGA_RB = 255;
            VGA_GB = 255;
            VGA_BB = 255;
            end
//              //bottom bar
            if ((vga_hcnt >= (x1_h[0]-1)) && (vga_hcnt <= (x1_h[0]+pcount)) && (vga_vcnt >= (pcount)) && (vga_vcnt <= (pcount+2))) begin
            VGA_RB = 255;
            VGA_GB = 255;
            VGA_BB = 255;
            end

        end
    end
endmodule
