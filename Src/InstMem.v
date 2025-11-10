`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2025 02:54:09 PM
// Design Name: 
// Module Name: InstMem
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



module InstMem (input [5:0] addr, output [31:0] data_out);

    reg [31:0] mem [0:63];
    integer j;

  
initial begin

  for (j = 0; j < 64; j = j + 1)
      mem[j] = 0;
 end
initial begin// initialize

 //$readmemb("Mem_Sum1to5.txt", mem); COMMENTED FOR TESTING   
 
mem[0]  = 32'b00000000100000000000000100010011; // addi x2, x0, 8
mem[1]  = 32'b00000000000100000000000110010011; // addi x3, x0, 1
mem[2]  = 32'b11111111100000000000001000010011; // addi x4, x0, -8

mem[3]  = 32'b00000000001100010001001010110011; // sll x5, x2, x3
mem[4]  = 32'b00000000001100010101001100110011; // srl x6, x2, x3


mem[5]  = 32'b01000000001100100101001110110011; // sra x7, x4, x3
mem[6]  = 32'b00000000001100010001010000010011; // slli x8, x2, 3
mem[7]  = 32'b01000000001000100101010010010011; // srai x9, x4, 2
end
    assign data_out = mem[addr];
endmodule


