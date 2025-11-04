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
//T1

mem[0]=32'b000000000001_00000_000_00001_0010011 ; // addi x1, x0, 1   ; i = 1
mem[1]=32'b000000000000_00000_000_00110_0010011 ; // addi x6, x0, 0   ; sum = 0
mem[2]=32'b000000000101_00000_000_00010_0010011 ; // addi x2, x0, 5   ; limit = 5

// loop: sum += i
mem[3]=32'b0000000_00001_00110_000_00110_0110011 ; // add x6, x6, x1   ; sum = sum + i
mem[4]=32'b000000000001_00001_000_00001_0010011 ; // addi x1, x1, 1   ; i = i + 1

// check if i <= 5 ? continue loop
mem[5]=32'b0100000_00010_00001_000_00111_0110011 ; // sub x7, x1, x2   ; x7 = i - 5
mem[6]=32'b11111110011100000101101011100011 ; // bge x0, x7, -12  ; if i < 5, branch back (to mem[3])

// end (loop done)
mem[7]=32'b0000000_00110_00000_010_01100_0100011 ; // sw x6, 12(x0)    ; store sum (optional)
mem[8]=32'b000000001100_00000_010_00110_0000011 ; // lw x6, 12(x0)     ; reload sum
mem[9] = 32'b00000000000000000000000001110011; //ecall to exit


//addi, add, sw, lw, ecall , sub, bge, blt, beq succeded testing 
//T2       
//mem[0] = 32'h00000093; // addi x1, x0, 0
//mem[1] = 32'h00500113; // addi x2, x0, 5
//mem[2] = 32'h00000193; // addi x3, x0, 0
//mem[3] = 32'h001181B3; // add  x3, x3, x1
//mem[4] = 32'h00108093; // addi x1, x1, 1
//mem[5] = 32'hFEA12CE3; // blt  x1, x2, -8
//mem[6] = 32'h00C002EF; // jal  x5, 12
//mem[7] = 32'h00118213; // addi x4, x3, 1
//mem[8] = 32'h00000073; // ecall
//mem[9] = 32'h00A18193; // addi x3, x3, 10
//mem[10]= 32'h00028067; // jalr x0, 0(x5)


end
    assign data_out = mem[addr];
endmodule


