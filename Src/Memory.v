`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2025 05:30:12 PM
// Design Name: 
// Module Name: Memory
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


module Memory(input clk,input [2:0] func3, input MemRead, input MemWrite,
input [7:0] addr, input [31:0] data_in, output  [31:0] Mem_out);

reg [7:0] mem [0:511]; // Half Instructions and Half Data (Total 4kb)
integer j;
initial begin
  for (j = 0; j < 511; j = j + 1)
      mem[j] = 0;
 end
 
wire [31:0] InstOut; 
assign InstOut = {mem[addr+3],mem[addr+2],mem[addr+1], mem[addr]}; //instruction
reg [31:0] data_out;


 
initial begin

$readmemb("Mem_Fib.txt",mem);



end
always@ (posedge clk) begin
if(MemWrite)
case(func3)
3'b000:  mem[addr+256] <= data_in[7:0]; //sb
3'b001: {mem[addr+256+1], mem[addr+256]}<= data_in[15:0]; //shw
3'b010: {mem[addr+256+3], mem[addr+256+2], mem[addr+256+1], mem[addr+256]} <= data_in ; //sw
endcase
end
always@ (*) begin
if(MemRead)
case(func3)
 3'b000: data_out = {{ 24{mem[addr+256][7]}} ,mem[addr+256]};      //lb
 3'b001: data_out = {{16{mem[addr+256+1][7]}}, mem[addr+256+1], mem[addr+256]};           //lhw
 3'b010: data_out = { mem[addr+256+3], mem[addr+256+2], mem[addr+256+1], mem[addr+256]};  //LW
 3'b100: data_out = {24'b0, mem[addr+256]}; //lbu
 3'b101: data_out = {16'b0, mem[addr+256+1], mem[addr+256]};  //lhu
 default: data_out = 32'b0;
 endcase
end
assign Mem_out = (MemRead|MemWrite)?(data_out):(InstOut);
endmodule



