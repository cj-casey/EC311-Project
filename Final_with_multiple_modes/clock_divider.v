`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:28:31 11/27/2017 
// Design Name: 
// Module Name:    Cloc_divider 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Clock_divider(
    input in_clk, 
    output reg out_clk);
	
	parameter number = 50000000;
	
	reg[32:0] count;

	initial begin
	   count = 0;
	   out_clk = 0;
		// initialize everything to zero
	end
	
	
	always @(posedge in_clk)
	begin
	   count = count + 1;
	   if(count == number) begin
	       out_clk = ~out_clk;
	       count = 0;
	    end 
		// increment count by one
		// if count equals to some big number (that you need to calculate),
		//   then flip the output clock,
		//   and reset count to zero.
	end


endmodule
