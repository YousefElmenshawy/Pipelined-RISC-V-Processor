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

module DataMem(input clk,input [2:0] func3, input MemRead, input MemWrite,
input [7:0] addr, input [31:0] data_in, output reg [31:0] data_out);
reg [7:0] mem [0:255];
 integer j;
initial begin
  for (j = 0; j < 255; j = j + 1)
      mem[j] = 0;
 end
 
initial begin
mem[0]=8'd17;
mem[4]=8'd9;
mem[8]=8'd25;

end
always@ (posedge clk) begin
if(MemWrite)
case(func3)
3'b000:  mem[addr] <= data_in[7:0]; //sb
3'b001: {mem[addr+1], mem[addr]}<= data_in[15:0]; //shw
3'b010: {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]} <= data_in ; //sw
endcase
end
always@ (*) begin
if(MemRead)
case(func3)
 3'b000: data_out = {{ 24{mem[addr][7]}} ,mem[addr]};      //lb
 3'b001: data_out = {{16{mem[addr][7]}}, mem[addr+1], mem[addr]};           //lhw
 3'b010: data_out = { mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};  //LW
 3'b100: data_out = {24'b0, mem[addr]}; //lbu
 3'b101: data_out = {16'b0, mem[addr+1], mem[addr]};  //lhu
 default: data_out = 32'b0;
 endcase
end
endmodule
