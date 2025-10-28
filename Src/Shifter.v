`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2025 05:07:48 PM
// Design Name: 
// Module Name: Shifter
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


module Shifter(input  [31:0] A, input [4:0] shamt, input [1:0] type, output reg [31:0] result);
always @(*) begin
case (type)
2'b00:result = A << shamt; // sll (logical shift left)
2'b01:result = A>>shamt; //srl (logical shift right)
2'b10: result = $signed(A)>>>shamt; // arthmetic shift right (sra)
endcase
end
endmodule
