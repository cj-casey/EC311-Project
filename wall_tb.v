`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2023 11:55:54 AM
// Design Name: 
// Module Name: LFSR_tb
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


module wall_tb();
    reg pixel_clk, reset;
    parameter WALL_NUM = 10;
    wire done;
    wire [10:0] wall_x [WALL_NUM-1:0];
    wire [10:0] wall_y [WALL_NUM-1:0];
    genvar k;
    generate
	for (k=0; k<WALL_NUM; k=k+1) begin
		wall #(.START(50*k+k*k+5)) w1 (.pixel_clk(pixel_clk), .x(wall_x[k]), .y(wall_y[k]), .reset(reset));
	end
    endgenerate

     initial begin
        pixel_clk = 0; reset = 0;
        #220 reset = 1;
        #260 reset = ~reset;
     end

    always begin
        #10 pixel_clk = ~pixel_clk;
    end   

endmodule

