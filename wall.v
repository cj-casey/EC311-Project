`timescale 1ns / 1ps



module wall (pixel_clk,x,y);
    parameter START = 4;

    input pixel_clk;

    output reg [10:0] x;
    output reg [10:0] y;
    
    wire [10:0] x_loc;
    wire [10:0] y_loc;

   
    LFSR  lfsrx
            (.i_Clk(pixel_clk),
            .i_Enable(1'b1),
            .i_Seed_DV(1'b0),
            .i_Seed_Data(START), // Replication
            .o_LFSR_Data(x_loc),
            .o_LFSR_Done()
            );

    LFSR  lfsry
            (.i_Clk(pixel_clk),
            .i_Enable(1'b1),
            .i_Seed_DV(1'b0),
            .i_Seed_Data(START), // Replication
            .o_LFSR_Data(y_loc),
            .o_LFSR_Done()
            );
    
    always@(posedge pixel_clk) begin
        if (x == 0) begin
            x = x_loc;
        end
        if (y == 0) begin
            y = y_loc;
        end
    end
    
    
endmodule