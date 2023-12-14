

module vline(pixel_clk, ix,iy,x1,y1,x2,y2);
      parameter length = 2;
    parameter width = 94;
    
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