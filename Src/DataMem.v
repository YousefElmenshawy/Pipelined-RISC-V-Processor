`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2025 03:17:41 PM
// Design Name: 
// Module Name: DataMem
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

module DataMem(input clk, input MemRead, input MemWrite,
input [5:0] addr, input [31:0] data_in, output reg [31:0] data_out);
reg [31:0] mem [0:63];
 integer j;
initial begin
  for (j = 0; j < 64; j = j + 1)
      mem[j] = 0;
 end
always@ (posedge clk) begin
if(MemWrite)
mem[addr] <= data_in ;
end
always@ (*) begin
if(MemRead)
 data_out =  mem[addr];
end
 
initial begin
mem[0]=32'd17;
mem[1]=32'd9;
mem[2]=32'd25;
end
endmodule
