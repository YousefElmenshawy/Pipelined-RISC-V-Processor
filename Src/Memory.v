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
//Data

/*
mem[256]=8'd17;
mem[260]=8'd9;
mem[264]=8'd25;

*/
mem[0] = 8'b00010011; // addi x2, x0, 2 [byte 1]
mem[1] = 8'b00000001; //  [byte 2]
mem[2] = 8'b00100000; //  [byte 3]
mem[3] = 8'b00000000; //  [byte 4]
mem[4] = 8'b10010011; // addi x3, x0, 3 [byte 1]
mem[5] = 8'b00000001; //  [byte 2]
mem[6] = 8'b00110000; //  [byte 3]
mem[7] = 8'b00000000; //  [byte 4]
mem[8] = 8'b10110011; // add x1, x2, x3 [byte 1]
mem[9] = 8'b00000000; //  [byte 2]
mem[10] = 8'b00110001; //  [byte 3]
mem[11] = 8'b00000000; //  [byte 4]
mem[12] = 8'b10110011; // sub x1, x2, x3 [byte 1]
mem[13] = 8'b00000000; //  [byte 2]
mem[14] = 8'b00110001; //  [byte 3]
mem[15] = 8'b01000000; //  [byte 4]
mem[16] = 8'b10110011; // sll x1, x2, x3 [byte 1]
mem[17] = 8'b00010000; //  [byte 2]
mem[18] = 8'b00110001; //  [byte 3]
mem[19] = 8'b00000000; //  [byte 4]
mem[20] = 8'b10110011; // slt x1, x2, x3 [byte 1]
mem[21] = 8'b00100000; //  [byte 2]
mem[22] = 8'b00110001; //  [byte 3]
mem[23] = 8'b00000000; //  [byte 4]
mem[24] = 8'b10110011; // sltu x1, x2, x3 [byte 1]
mem[25] = 8'b00110000; //  [byte 2]
mem[26] = 8'b00110001; //  [byte 3]
mem[27] = 8'b00000000; //  [byte 4]
mem[28] = 8'b10110011; // xor x1, x2, x3 [byte 1]
mem[29] = 8'b01000000; //  [byte 2]
mem[30] = 8'b00110001; //  [byte 3]
mem[31] = 8'b00000000; //  [byte 4]
mem[32] = 8'b10110011; // srl x1, x2, x3 [byte 1]
mem[33] = 8'b01010000; //  [byte 2]
mem[34] = 8'b00110001; //  [byte 3]
mem[35] = 8'b00000000; //  [byte 4]
mem[36] = 8'b10110011; // sra x1, x2, x3 [byte 1]
mem[37] = 8'b01010000; //  [byte 2]
mem[38] = 8'b00110001; //  [byte 3]
mem[39] = 8'b01000000; //  [byte 4]
mem[40] = 8'b10110011; // or x1, x2, x3 [byte 1]
mem[41] = 8'b01100000; //  [byte 2]
mem[42] = 8'b00110001; //  [byte 3]
mem[43] = 8'b00000000; //  [byte 4]
mem[44] = 8'b10110011; // and x1, x2, x3 [byte 1]
mem[45] = 8'b01110000; //  [byte 2]
mem[46] = 8'b00110001; //  [byte 3]
mem[47] = 8'b00000000; //  [byte 4]
mem[48] = 8'b00001111; // FENCE.TSO [byte 1]
mem[49] = 8'b00000000; //  [byte 2]
mem[50] = 8'b00110000; //  [byte 3]
mem[51] = 8'b10000011; //  [byte 4]



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
assign Mem_out = (MemRead|MemWrite)?(data_out):(InstOut);
endmodule



