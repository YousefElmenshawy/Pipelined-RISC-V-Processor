`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2025 07:18:42 PM
// Design Name: 
// Module Name: ALU_ControlUnit
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


module ALU_ControlUnit (input [1:0] ALUOp, input [2:0]func3, input func7 ,output reg [3:0] ALUsel );
always @ (*) begin
case(ALUOp)
2'b00: ALUsel = 4'b0010;
2'b01: ALUsel= 4'b0110;
2'b10: begin
if (func3 == 3'b111 & func7 == 0)
ALUsel = 4'b0000;
else if (func3 == 3'b110 & func7 == 0)
ALUsel = 4'b0001;
else if (func3==3'b000)
 ALUsel = func7 ? 4'b0110:4'b0010;
end
default: ALUsel = 4'b1111;
endcase
end
   
endmodule
