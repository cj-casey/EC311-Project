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
wire sec_clock;
wire rand_enable;


 fsm fsm1(fast_clock,sseg_number,cathode,anode);
 
 Clock_divider cd2(in_clk,fast_clock);
 defparam cd2.number = 50000;
 
  Clock_divider cd1(in_clk,sec_clock);

parameter b_length = 94;
parameter b_width = 95;
parameter y_dimensions = 5;
parameter x_dimensions = 5;

wire [10:0] x1 [y_dimensions*x_dimensions-1:0];
wire [10:0] x2 [y_dimensions*x_dimensions-1:0];
wire [10:0] y1 [y_dimensions*x_dimensions-1:0];
wire [10:0] y2 [y_dimensions*x_dimensions-1:0];
wire [y_dimensions*x_dimensions-1:0] random;
reg [y_dimensions*x_dimensions-1:0] wall_on;

genvar i; // x
genvar j; // y
integer num = 0;
generate
for (i = 0; i<x_dimensions; i=i+1) begin
	for (j=0; j<y_dimensions; j=j+1) begin
		block #(.length(b_length), .width(b_width)) b1 (.pixel_clk(clk_pix), .ix(i*b_length+81), .iy(j*b_width), .x1(x1[5*i+j]), .x2(x2[5*i+j]), .y1(y1[5*i+j]), .y2(y2[5*i+j]), .on(random[5*i+j]));
	end
end
endgenerate


parameter START = 30504031;


initial begin
//wall_on = 0;
end

 assign sseg_number = {5'b00000,wall_on,5'b00000,random};
 
 assign rand_enable = ~reset;
 
LFSR  lfsrx
            (.i_Clk(fast_clock),
            .i_Enable(rand_enable),
            .i_Seed_DV(),
            .i_Seed_Data(START), // Replication
            .o_LFSR_Data(random),
            .o_LFSR_Done()
            );
 defparam lfsrx.NUM_BITS = 25;

parameter length = 94;
parameter width = 95;





always@(posedge in_clk) begin
       
       if(reset)
            wall_on = random;
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
            
//            if(random[0]) begin
//            //box 1,1
//            if ((vga_hcnt >= (81) && vga_hcnt <= (175)) &&
//                (vga_vcnt >= (2) && vga_vcnt <= (96))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end    
            
//            end
//            //box 1,2
//            if(random[1]) begin
//            if ((vga_hcnt >= (81) && vga_hcnt <= (175)) &&
//                (vga_vcnt >= (98) && vga_vcnt <= (192))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end    
//            end
//            //box 1,3
//            if ((vga_hcnt >= (81) && vga_hcnt <= (175)) &&
//                (vga_vcnt >= (194) && vga_vcnt <= (288))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end   
            
//            if(random[9]) begin 
//            //box 1,4
//            if ((vga_hcnt >= (81) && vga_hcnt <= (176)) &&
//                (vga_vcnt >= (290) && vga_vcnt <= (385))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end   
//            end            
//            //box 2,1
//            if ((vga_hcnt >= (177) && vga_hcnt <= (272)) &&
//                (vga_vcnt >= (2) && vga_vcnt <= (97))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end    
                        
//            //box 2,2
//            if ((vga_hcnt >= (177) && vga_hcnt <= (271)) &&
//                (vga_vcnt >= (97) && vga_vcnt <= (193))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end    
             
                       
//            //box 2,3
//            if ((vga_hcnt >= (177) && vga_hcnt <= (272)) &&
//                (vga_vcnt >= (193) && vga_vcnt <= (288))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end            
                        
//            //box 2,4
//            if ((vga_hcnt >= (176) && vga_hcnt <= (272)) &&
//                (vga_vcnt >= (290) && vga_vcnt <= (384))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end            
                        
//            //box 2,5
//            if ((vga_hcnt >= (176) && vga_hcnt <= (271)) &&
//                (vga_vcnt >= (386) && vga_vcnt <= (478))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end            
                        
//            //box 3,1
//            if ((vga_hcnt >= (272) && vga_hcnt <= (367)) &&
//                (vga_vcnt >= (2) && vga_vcnt <= (97))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end    
                        
//            //box 3,2
//            if ((vga_hcnt >= (273) && vga_hcnt <= (368)) &&
//                (vga_vcnt >= (97) && vga_vcnt <= (192))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end     
                        
//            //box 3,3
//            if ((vga_hcnt >= (272) && vga_hcnt <= (367)) &&
//                (vga_vcnt >= (194) && vga_vcnt <= (289))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end     
                         
//            //box 3,4
//            if ((vga_hcnt >= (272) && vga_hcnt <= (367)) &&
//                (vga_vcnt >= (289) && vga_vcnt <= (384))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end     
                        
//            //box 3,5
//            if ((vga_hcnt >= (273) && vga_hcnt <= (367)) &&
//                (vga_vcnt >= (386) && vga_vcnt <= (478))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end     
                    
//            //box 4,1
//            if ((vga_hcnt >= (369) && vga_hcnt <= (463)) &&
//                (vga_vcnt >= (2) && vga_vcnt <= (96))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end    
                    
//            //box 4,2
//            if ((vga_hcnt >= (369) && vga_hcnt <= (463)) &&
//                (vga_vcnt >= (98) && vga_vcnt <= (192))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end                
                    
//            //box 4,3
//            if ((vga_hcnt >= (369) && vga_hcnt <= (463)) &&
//                (vga_vcnt >= (194) && vga_vcnt <= (288))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end                
                    
                    
//            //box 4,4
//            if ((vga_hcnt >= (369) && vga_hcnt <= (463)) &&
//                (vga_vcnt >= (290) && vga_vcnt <= (384))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end   
                                
//            //box 4,5
//            if ((vga_hcnt >= (369) && vga_hcnt <= (463)) &&
//                (vga_vcnt >= (386) && vga_vcnt <= (478))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end     
                          
//            //box 5,2
//            if ((vga_hcnt >= (464) && vga_hcnt <= (559)) &&
//                (vga_vcnt >= (97) && vga_vcnt <= (192))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end 
                          
//            //box 5,3
//            if ((vga_hcnt >= (465) && vga_hcnt <= (559)) &&
//                (vga_vcnt >= (194) && vga_vcnt <= (288))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end 
                          
//            //box 5,4
//            if ((vga_hcnt >= (465) && vga_hcnt <= (559)) &&
//                (vga_vcnt >= (290) && vga_vcnt <= (384))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end 
            
//            //box 5,5
//            if ((vga_hcnt >= (465) && vga_hcnt <= (559)) &&
//                (vga_vcnt >= (386) && vga_vcnt <= (478))) begin
//            VGA_RB = 255;
//            VGA_GB = 255;
//            VGA_BB = 255;
//            end
            
            for(k=0; k<x_dimensions*y_dimensions; k=k+1) begin
		 		if ((vga_hcnt >= x1[k]) && (vga_hcnt <=  x2[k]) &&
         		((vga_vcnt >=  y1[k]) && vga_vcnt <=  y2[k])) begin
	               VGA_RB = 255;
                    VGA_GB = 255;
                    VGA_BB = 255;
		 		end
         	end

        end
    end
endmodule
