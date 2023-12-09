`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2023 10:45:24 AM
// Design Name: 
// Module Name: clock_gen
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


module clock_gen (
    input in_clk,
    output reg pixel_clk
    );
    
reg pclk_div_cnt;


// Clock divider. Generate 25MHz pixel_clk from 100MHz clock.
always @(posedge in_clk) begin
    pclk_div_cnt <= !pclk_div_cnt;
    if (pclk_div_cnt == 1'b1) pixel_clk <= !pixel_clk;
end
endmodule
