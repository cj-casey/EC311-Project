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


module LFSR_tb();

    reg clk, enable, seed_en;
    reg [10:0] seed_data; 
    wire [10:0] out;
    wire done;
    
    LFSR DUT(
    .i_Clk(clk),
    .i_Enable(enable),
    .i_Seed_DV(seed_en),
    .i_Seed_Data(seed_data),
    .o_LFSR_Data(out),
    .o_LFSR_Done(done)
    );
    
    initial begin
    clk = 0; enable = 0; seed_data = 0; seed_en = 0;
    #30 enable = 1;
    #30 seed_data = 884;
    #10 seed_en = 1;
    #10 seed_en = 0;
    
    end

    always begin
    #10 clk = ~clk;
    end    
    
endmodule
