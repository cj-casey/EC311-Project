`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2023 08:43:13 AM
// Design Name: 
// Module Name: fsm
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


module fsm(
        input clock,
        input [31:0] thirty2_bit_number,
        output [6:0] cathode,
        output reg [7:0] anode
    );
    
    reg [3:0] four_bit_number;
    decoder decoder1(four_bit_number,cathode);
    // instantiate decoder that decodes the four bit number into the cathode
    reg [2:0] state; // stores state of FSM
    
    initial begin
		state = 0;
		anode = 8'b11111111;
	end
    
    always @(posedge clock)
	begin
	   state = state + 1;
	   case(state)
           3'b000: begin anode = 8'b11111110; four_bit_number = thirty2_bit_number[3:0]; end
           3'b001: begin anode = 8'b11111101; four_bit_number = thirty2_bit_number[7:4]; end
           3'b010: begin anode = 8'b11111011; four_bit_number = thirty2_bit_number[11:8]; end
           3'b011: begin anode = 8'b11110111; four_bit_number = thirty2_bit_number[15:12]; end
           3'b100: begin anode = 8'b11101111; four_bit_number = thirty2_bit_number[19:16]; end
           3'b101: begin anode = 8'b11011111; four_bit_number = thirty2_bit_number[23:20]; end
           3'b110: begin anode = 8'b10111111; four_bit_number = thirty2_bit_number[27:24]; end
           3'b111: begin anode = 8'b01111111; four_bit_number = thirty2_bit_number[31:28]; end 
	   endcase
		// increment state
		// set anode (which display do you want to set?)
		//   hint: if state == 0, then set only the LSB of anode to zero,
		//         if state == 1, then set only the second to LSB to zero.
		// set the four bit number to be the approprate slice of the 16-bit number
	end
    
endmodule
