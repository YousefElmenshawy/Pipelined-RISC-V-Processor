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


module SingleCycle(input clk,rst );
wire [31:0] PCIn;
 wire [31:0] PCOut;
 wire [31:0] Inst;
 wire Branch;
 wire MemRead;
 wire [2:0] WDsel;
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
wire [31:0] JalAdderOut; //Jal/JalR
wire [31:0] AUIPCadderOut; //AUIPC
wire [1:0]  PCsel; 
wire [4:0] shamt;
wire  cf, zf, vf, sf;
wire [31:0] LUIData;
wire ConfirmBranch;
wire [1:0] BitSel;
assign shamt = Inst[5]? ReadData2[4:0]: gen_out[4:0]; //deciding on I-R types for shifting
assign ReadAddress1 =   Inst[19:15];
assign ReadAddress2 =   Inst[24:20];
assign WriteAddress = Inst[11:7];
assign DataMemIn = ALU_Result[7:2];
assign func7 = Inst [30];
assign func3 = Inst[14:12];

assign PartialOpcode = Inst[6:2];
wire [5:0] InstIn;
assign InstIn = PCOut [7:2]; 
Register #(32) PC (clk,rst,1'b1, PCIn,PCOut);
InstMem Mem(InstIn,Inst);
ControlUnit control (PartialOpcode,  Branch, MemRead, WDsel, MemWrite, ALUSrc, RegWrite, ALUOp, PCsel, BitSel);
ImmGen  Gen(Inst, gen_out);
ALU_ControlUnit CU(ALUOp, func3,  func7 , ALUsel);
Shift_Left #(32) Shift(gen_out , ShiftOut );
RegisterFile RF  ( clk, rst, ReadAddress1,  ReadAddress2,  WriteAddress,  WriteData,  RegWrite, ReadData1,  ReadData2);
Mux  ALUinMux (gen_out, ReadData2, ALUSrc, ALUin);
ALU  OurALU( ReadData1, ALUin,shamt, ALU_Result,cf, zf, vf, sf, ALUsel);
DataMem DMem(clk, MemRead, MemWrite,DataMemIn, ReadData2,DataMemOut);
WriteData_Selector SelD (WDsel,ALU_Result,DataMemOut,NormalAdderOut,AUIPCadderOut,LUIData, WriteData);

assign BranchAdderOut = ShiftOut + PCOut;
assign NormalAdderOut = PCOut +4;
assign JalAdderOut = PCOut + gen_out; // Jal Support
BranchDelegator Delg( zf, cf, sf, vf, Branch,  func3, ConfirmBranch );
PC_Selector Sel (BranchAdderOut,NormalAdderOut,JalAdderOut,ALU_Result,PCsel,ConfirmBranch,PCIn);// JalR will get the ALU result


//LUI and AUIPC 
ShiftTwelve Shift(gen_out, LUIData);

assign AUIPCadderOut = LUIData + PCOut;


endmodule
