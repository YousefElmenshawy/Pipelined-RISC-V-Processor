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

 $readmemb("Mem_Sum1to5.txt", mem);



end
    assign data_out = mem[addr];
endmodule


