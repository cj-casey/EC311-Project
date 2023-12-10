`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2023 03:06:32 PM
// Design Name: 
// Module Name: hline
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


module hline(pixel_clk, ix,iy,x1,y1,x2,y2);
      parameter length = 94;
    parameter width = 2;
    
    input pixel_clk;
    
    input wire [10:0] ix;
    input wire [10:0] iy;

    output reg [10:0] x1;
    output reg [10:0] y1;
    output reg [10:0] x2;
    output reg [10:0] y2;
    
    always @(*) begin
        x1 = ix;
        y1 = iy;
        
        x2 = ix + length;
        y2 = iy + width;
    end
    
    
    
endmodule
