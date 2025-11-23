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
mem[256]=8'd17;
mem[257] = 8'd6;
mem[260]=8'd9;
mem[264] = 8'h00 ; 
mem[265] = 8'hFF;  // byte = 255 unsigned, -1 signed
mem[266] = 8'h7F ; // second byte for halfword ? 0x7FFF = 32767
mem[267] = 8'h80;  // optional extra byte


// Instructions
//x2 = 0
mem[0] = 8'b10000011; // lb x1, 0(x2) [byte 1]  //x1 = 17
mem[1] = 8'b00000000; //  [byte 2]
mem[2] = 8'b00000001; //  [byte 3]
mem[3] = 8'b00000000; //  [byte 4]    
mem[4] = 8'b10000011; // lh x1, 0(x2) [byte 1] // x1 = 1554
mem[5] = 8'b00010000; //  [byte 2]
mem[6] = 8'b00000001; //  [byte 3]
mem[7] = 8'b00000000; //  [byte 4]
mem[8] = 8'b10000011; // lw x1, 4(x2) [byte 1] x1 = 9
mem[9] = 8'b00100000; //  [byte 2]
mem[10] = 8'b01000001; //  [byte 3]
mem[11] = 8'b00000000; //  [byte 4]
mem[12] = 8'b10000011; // lbu x1, 9(x2) [byte 1] // x1 = 255
mem[13] = 8'b01000000; //  [byte 2]
mem[14] = 8'b10010001; //  [byte 3]
mem[15] = 8'b00000000; //  [byte 4]
mem[16] = 8'b10000011; // lhu x1, 9(x2) [byte 1] x1 = 32767
mem[17] = 8'b01010000; //  [byte 2]
mem[18] = 8'b10010001; //  [byte 3]
mem[19] = 8'b00000000; //  [byte 4]


mem[20] = 8'h73;        //0x00000073
mem[21] = 8'h00;
mem[22] = 8'h00;
mem[23] = 8'h00;



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



