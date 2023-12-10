`timescale 1ns / 1ps



module wall (pixel_clk,x,y,reset);
    parameter START = 4;

    input pixel_clk;
    input reset;

    output reg [10:0] x;
    output reg [10:0] y;
    
    wire [10:0] x_loc;
    wire [10:0] y_loc;

    reg x_set;
    reg y_set;
    reg seed_en;
    LFSR  lfsrx
            (.i_Clk(pixel_clk),
            .i_Enable(1'b1),
            .i_Seed_DV(seed_en),
            .i_Seed_Data(START), // Replication
            .o_LFSR_Data(x_loc),
            .o_LFSR_Done()
            );

    LFSR  lfsry
            (.i_Clk(pixel_clk),
            .i_Enable(1'b1),
            .i_Seed_DV(seed_en),
            .i_Seed_Data(START*3+START^2), // Replication
            .o_LFSR_Data(y_loc),
            .o_LFSR_Done()
            );
    
    always@(posedge pixel_clk) begin
        if(reset) begin
	        x = 0;
            y = 0;
            seed_en = 0;
           // x_set = 0;
            //y_set = 0;
	    end
        else begin
            if (x == 0) begin
                x = x_loc;
                x_set = 1;
                
            end
            else if (x_set === 1) begin
                seed_en = 0;
                x = x;
            end
            else if (x !== 0) begin
                seed_en = 1;
                x = 0;
            end

            if (y == 0) begin
                y = y_loc;
                y_set = 1;
            end
            else if (y_set === 1)
                y = y;
            else if (y !== 0) begin
                y = 0;
            end
        end
    end
    
    
endmodule