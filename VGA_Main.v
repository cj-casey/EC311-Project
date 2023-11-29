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
    input [3:0] r,
    input [3:0] g,
    input [3:0] b,
    output reg [3:0] VGA_RB,
    output reg [3:0] VGA_GB,
    output reg [3:0] VGA_BB,
    output wire hs,
    output wire vs
    );
    
    wire clk_pix,clk_mvm;
    wire w1,w2;
    wire [10:0] vga_hcnt, vga_vcnt;
    reg signed [15:0] x = 0,y = 0;
    wire vga_blank;
    
    movement_clock VGA_Move_Gen(in_clk,clk_mvm);
    clock_gen VGA_Clock_Gen(in_clk,clk_pix);
    signal_generation VGA_Signal_Gen(
.pixel_clk(clk_pix),
.HS(hs),
.VS(vs),
.hcounter(vga_hcnt),
.vcounter(vga_vcnt),
.blank(vga_blank));

// Generate figure to be displayed
// Decide the color for the current pixel at index (hcnt, vcnt).
// This example displays an white square at the center of the screen with a colored checkerboard background.
  /*always@(posedge clk_mvm)begin
        if(up == 1'b1) begin
        y <= y + 1;
        end
        if(down == 1'b1) begin
        y <= y - 1;
        end
        if(left == 1'b1) begin
        x <= x - 1;
        end
        if(right == 1'b1) begin
        x <= x + 1;
        end
        end */
always@(posedge clk_pix) begin
        //if(left == 1'b1) begin
        x <= x - 1;
        //end
       // if(right == 1'b1) begin
       // x <= x + 1; 
       // end 
     end 
        
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
        
    
            //house
            if ((vga_hcnt >= (0) && vga_hcnt <= (150)) &&
        	(vga_vcnt >= (150) && vga_vcnt <= (350))) begin
			VGA_RB = 15;
			VGA_GB = 15;
			VGA_BB = 15;
            end
            //door
            if ((vga_hcnt >= (0) && vga_hcnt <= (75)) &&
        	(vga_vcnt >= (225) && vga_vcnt <= (275))) begin
			VGA_RB = 7;
			VGA_GB = 3;
			VGA_BB = 0;
            end
            
            //roof
            
            if (((vga_hcnt >= (120) && vga_hcnt <= (140)) &&
        	(vga_vcnt >= (125) && vga_vcnt <= (150)))||((vga_hcnt >= (120) && vga_hcnt <= (140)) &&
        	(vga_vcnt >= (350) && vga_vcnt <= (375)))||((vga_hcnt >= (130) && vga_hcnt <= (150)) &&
        	(vga_vcnt >= (325) && vga_vcnt <= (350)))||((vga_hcnt >= (130) && vga_hcnt <= (150)) &&
        	(vga_vcnt >= (150) && vga_vcnt <= (175)))||((vga_hcnt >= (140) && vga_hcnt <= (160)) &&
        	(vga_vcnt >= (175) && vga_vcnt <= (200)))||((vga_hcnt >= (140) && vga_hcnt <= (160)) &&
        	(vga_vcnt >= (300) && vga_vcnt <= (325)))||((vga_hcnt >= (150) && vga_hcnt <= (170)) &&
        	(vga_vcnt >= (200) && vga_vcnt <= (300)))) begin
			VGA_RB = 7;
			VGA_GB = 0;
			VGA_BB = 0;
            end
            
            if ((vga_hcnt >= (60) && vga_hcnt <= (85)) &&
        	(vga_vcnt >= (175) && vga_vcnt <= (200))) begin
			VGA_RB = 0;
			VGA_GB = 14;
			VGA_BB = 15;
            end
            
            if ((vga_hcnt >= (60) && vga_hcnt <= (85)) &&
        	(vga_vcnt >= (300) && vga_vcnt <= (325))) begin
			VGA_RB = 0;
			VGA_GB = 14;
			VGA_BB = 15;
            end
        // White square at the center
        if ((vga_hcnt >= (0+x) && vga_hcnt <= (340+x)) &&
        	(vga_vcnt >= (0+y) && vga_vcnt <= (640+y))) begin
			VGA_RB = r;
			VGA_GB = g;
			VGA_BB = b;
            end
            /*if ((vga_hcnt >= (220+x) && vga_hcnt <= (270+x)) &&
        	(vga_vcnt >= (300+y) && vga_vcnt <= (350+y))) begin
			VGA_R = r;
			VGA_G = g;
			VGA_B = b;
            end */
        end
    end
endmodule
