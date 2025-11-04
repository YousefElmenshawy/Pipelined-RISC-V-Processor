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
2'b00: ALUsel = 4'b0010; // Add
2'b01: ALUsel= 4'b0110; // Subtract
2'b10: begin
if (func3 == 3'b111 && func7 == 0)
ALUsel = 4'b0000; //and
else if (func3 == 3'b110 && func7 == 0)
ALUsel = 4'b0001; //Or
else if (func3==3'b000)
 ALUsel = func7 ? 4'b0110:4'b0010; // sub : add
 else if (func3 ==3'b001&& func7==0)
 ALUsel = 4'b1000; //SLL-SLLI
 else if (func3 == 3'b101)
 ALUsel = func7 ? 4'b1010: 4'b1001; //SRL-SRLI/SRA-SRAI
 else if (func3 == 3'b010&& func7==0)
 ALUsel = 4'b1101;//slt
 else if(func3 == 3'b011 && func7==0)
 ALUsel =4'b1111; //sltu
 else if (func3 == 3'b100 && func7==0)
 ALUsel = 4'b0111; //xor
end
endcase
end
   
endmodule
