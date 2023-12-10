`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2023 10:55:18 PM
// Design Name: 
// Module Name: block
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


module block (pixel_clk,ix,iy,x1,x2,y1,y2,on);
    parameter length = 94;
    parameter width = 94;
    
    input pixel_clk;
    
    input wire [10:0] ix;
    input wire [10:0] iy;
    input wire on;

    output reg [10:0] x1;
    output reg [10:0] y1;
    output reg [10:0] x2;
    output reg [10:0] y2;
    
    always @(*) begin
        x1 = ix;
        y1 = iy;
        
        x2 = ix + length - 2*on;
        y2 = iy + width - 2*on;
    end
    
    
    
endmodule
