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
 
assign InstOut = {mem[addr+3],mem[addr+2],mem[addr+1], mem[addr]}; //instruction
reg [31:0] data_out;


 
initial begin
//Data
mem[256]=8'd17;
mem[260]=8'd9;
mem[264]=8'd25;

// Instructions

    // mem[0..3] = addi x1, x0, 1
    mem[0] = 8'h93;  // 00010011
    mem[1] = 8'h00;  // 00000001
    mem[2] = 8'h10;
    mem[3] = 8'h00;

    // mem[4..7] = addi x6, x0, 0
    mem[4] = 8'h13;
    mem[5] = 8'h03;
    mem[6] = 8'h00;
    mem[7] = 8'h00;

    // mem[36..39] = ecall
    mem[36] = 8'h73;
    mem[37] = 8'h00;
    mem[38] = 8'h00;
    mem[39] = 8'h00;


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
 3'b001: data_out = {{16{mem[addr+256][7]}}, mem[addr+256], mem[addr+256]};           //lhw
 3'b010: data_out = { mem[addr+256+3], mem[addr+256+2], mem[addr+256+1], mem[addr+256]};  //LW
 3'b100: data_out = {24'b0, mem[addr+256]}; //lbu
 3'b101: data_out = {16'b0, mem[addr+256+1], mem[addr+256]};  //lhu
 default: data_out = 32'b0;
 endcase
end
assign Mem_out = (MemRead)? (data_out):(InstOut);
endmodule



