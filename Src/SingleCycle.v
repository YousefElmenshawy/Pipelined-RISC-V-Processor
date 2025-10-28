`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2025 12:55:41 PM
// Design Name: 
// Module Name: SingleCycle
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


module SingleCycle(input clk,rst,input [1:0] ledSel, input [3:0] ssdSel, output reg [15:0] leds, output reg [12:0] ssd );
wire [31:0] PCIn;
 wire [31:0] PCOut;
 wire [31:0] Inst;
 wire Branch;
 wire MemRead;
 wire MemtoReg;
 wire MemWrite;
 wire ALUSrc;
 wire RegWrite;
 wire [1:0] ALUOp;
 wire [31:0]gen_out;
 wire [2:0] func3;
 wire func7;
 wire [3:0] ALUsel;
 wire [31:0] ShiftOut;
 wire [4:0] ReadAddress1;
wire [4:0] ReadAddress2;
wire [4:0] WriteAddress;
wire [31:0] WriteData;
wire [31:0] ReadData1;
wire [31:0] ReadData2;
wire [4:0] PartialOpcode;
wire [31:0] ALUin;
wire [31:0] ALU_Result;
wire [5:0] DataMemIn;
wire [31:0] DataMemOut;
wire [31:0] BranchAdderOut;
wire [31:0] NormalAdderOut;
wire PCsel;
assign ReadAddress1 =   Inst[19:15];
assign ReadAddress2 =   Inst[24:20];
assign WriteAddress = Inst[11:7];
assign DataMemIn = ALU_Result[7:2];
assign func7 = Inst [30];
assign func3 = Inst[14:12];
wire ZFlag;
assign PartialOpcode = Inst[6:2];
wire [5:0] InstIn;
assign InstIn = PCOut [7:2]; 
Register #(32) PC (clk,rst,1'b1, PCIn,PCOut);
InstMem Mem(InstIn,Inst);
ControlUnit control (PartialOpcode,  Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ALUOp);
ImmGen  Gen(Inst, gen_out);
ALU_ControlUnit CU(ALUOp, func3,  func7 , ALUsel);
Shift_Left #(32) Shift(gen_out , ShiftOut );
RegisterFile RF  ( clk, rst, ReadAddress1,  ReadAddress2,  WriteAddress,  WriteData,  RegWrite, ReadData1,  ReadData2);
Mux  ALUinMux (gen_out, ReadData2, ALUSrc, ALUin);
ALU  OurALU( ReadData1, ALUin, ALUsel,ALU_Result,ZFlag);
DataMem DMem(clk, MemRead, MemWrite,DataMemIn, ReadData2,DataMemOut);
Mux MemtoRegMux (DataMemOut, ALU_Result, MemtoReg, WriteData);
assign BranchAdderOut = ShiftOut + PCOut;
assign NormalAdderOut = PCOut +4;
assign PCsel = Branch & ZFlag;
Mux PCMux (BranchAdderOut,NormalAdderOut, PCsel, PCIn);
always @(*) begin
case (ledSel)
2'b00: leds = Inst [15:0];
2'b01: leds = Inst [31:16];
2'b10: leds = {2'b00, ALUOp,ALUsel, ALUSrc,ZFlag,PCsel,Branch,MemRead,MemtoReg, MemWrite,RegWrite};
default: leds = 16'd0;
endcase

case (ssdSel)
4'b0000:ssd = PCOut[12:0];
4'b0001: ssd= NormalAdderOut[12:0];
4'b0010: ssd = BranchAdderOut [12:0];
4'b0011: ssd = PCIn [12:0];
4'b0100: ssd = ReadData1 [12:0];
4'b0101: ssd = ReadData2 [ 12:0];
4'b0110: ssd = WriteData [12:0];
4'b0111: ssd = gen_out[12:0];
4'b1000: ssd = ShiftOut[12:0];
4'b1001: ssd = ALUin[12:0];
4'b1010: ssd = ALU_Result[12:0];
4'b1011: ssd = DataMemOut[12:0];
default: ssd = 13'd0;


endcase
end

endmodule
