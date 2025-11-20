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


module Pipelined(input clk,rst );
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
wire [7:0] DataMemIn;
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
wire BreakSel;



//  START OF     IF         /////////////////////////////////////

Register #(32) PC (clk,rst,~stall&~BreakSel, PCIn,PCOut);


wire [63:0] PC_and_Inst_In;




Mux#(64) Control_ID_Mux ({32'b0,32'h000_00033},{PCOut,MemOut},ConfirmBranch, PC_and_Inst_In);

wire [31:0] IF_ID_PC, IF_ID_Inst;
Register #(64) IF_ID (clk,rst,~stall&~BreakSel,PC_and_Inst_In
,{IF_ID_PC,IF_ID_Inst} );




//  START OF     ID         /////////////////////////////////////
assign ReadAddress1 =   IF_ID_Inst[19:15];
assign ReadAddress2 =   IF_ID_Inst[24:20];
assign WriteAddress = IF_ID_Inst[11:7];
assign func7 = IF_ID_Inst [30];
assign func3 = IF_ID_Inst[14:12];
assign PartialOpcode = IF_ID_Inst[6:2];









wire [31:0] ID_EX_PC, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm;
wire [7:0] ID_EX_Ctrl;
wire [1:0] ID_EX_PC_sel;
wire ID_EX_BSel;
wire ID_EX_ShiftCheck;
wire [2:0] ID_EX_WDSel;
wire [3:0] ID_EX_Func;
wire [4:0] ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd;


RegisterFile RF  ( clk, rst, ReadAddress1,  ReadAddress2,  MEM_WB_Rd,  WriteData,  MEM_WB_Ctrl[1], ReadData1,  ReadData2);   // RF


ImmGen  Gen(IF_ID_Inst, gen_out);


ControlUnit control (PartialOpcode,  Branch, MemRead, WDsel, MemWrite, ALUSrc, RegWrite, ALUOp, PCsel, BreakSel);
wire [7:0] ControlIn;
wire [2:0] WDselIn;
Mux#(3) WDsel_Mux(3'b0,WDsel,stall|ConfirmBranch,WDselIn);
Mux#(8) EX_Control_Mux(8'b0,{RegWrite,1'b0,MemRead,MemWrite, Branch ,ALUOp,ALUSrc}, stall|ConfirmBranch, ControlIn);
Register #(162) ID_EX (clk,rst,1'b1,{ControlIn,IF_ID_PC,
ReadData1,ReadData2,gen_out,func7,func3,ReadAddress1, ReadAddress2,WriteAddress, BreakSel, WDselIn, IF_ID_Inst[5],PCsel},

{ID_EX_Ctrl,ID_EX_PC,ID_EX_RegR1,ID_EX_RegR2,
ID_EX_Imm, ID_EX_Func,ID_EX_Rs1,ID_EX_Rs2,ID_EX_Rd, ID_EX_BSel, ID_EX_WDSel, ID_EX_ShiftCheck,ID_EX_PC_sel} );

// Rs1 and Rs2 are needed later for the forwarding unit


//  START OF     EX         /////////////////////////////////////

wire [31:0] EX_MEM_BranchAddOut, EX_MEM_ALU_out, EX_MEM_RegR2, EX_MEM_NormalAdderOut, EX_MEM_AUIPCadderOut, EX_MEM_LUIData;
wire [4:0] EX_MEM_Ctrl;
wire [4:0] EX_MEM_Rd;
wire EX_MEM_Zero;
wire[2:0] EX_MEM_WDSel;


assign shamt = ID_EX_ShiftCheck? ID_EX_RegR2[4:0]: ID_EX_Imm[4:0]; //deciding on I-R types for shifting

Shift_Left #(32) Shift(ID_EX_Imm , ShiftOut ); //shifting for Branch
ShifterTwelve ShiftB(ID_EX_Imm, LUIData); //shifting for LUI

assign AUIPCadderOut = LUIData + ID_EX_PC; //AUIPC






// Forwarding Unit 
wire [1:0]  ForwardA, ForwardB;

ForwardingUnit  FU (EX_MEM_Ctrl[4],EX_MEM_Rd,ID_EX_Rs1,ID_EX_Rs2, MEM_WB_Ctrl[1],MEM_WB_Rd,ForwardA,ForwardB);

                    //RegWrite EX                                      //RegWrite Mem_WB





wire [31:0] ALUinA, ALUinB;

Mux4 MuxA (ID_EX_RegR1, WriteData,EX_MEM_ALU_out,  32'b0, ForwardA, ALUinA);  //First Input ALU Mux

Mux4 MuxB (ID_EX_RegR2, WriteData, EX_MEM_ALU_out, 32'b0, ForwardB, ALUin); // Second Input ALU second Mux

Mux  ALUinMux (ID_EX_Imm, ALUin, ID_EX_Ctrl[0], ALUinB);  // Second Input ALU Second Mux 


ALU  OurALU( ALUinA, ALUinB,shamt, ALU_Result,cf, zf, vf, sf, ALUsel);



ALU_ControlUnit CU(ID_EX_Ctrl[2:1], ID_EX_Func[2:0],  ID_EX_Func[3] , ALUsel);


BranchDelegator Delg( zf, cf, sf, vf, ID_EX_Ctrl[3],  ID_EX_Func[2:0], ConfirmBranch );

wire [2:0] EX_MEM_Func3;
wire [4:0] EX_MEM_ControlIn;
wire [2:0]  WD_ControlIn;   

Register #(209) EX_MEM (clk,rst,1'b1,
{ID_EX_Ctrl[7:3],BranchAdderOut,zf,ALU_Result,ALUin,ID_EX_Rd, ID_EX_WDSel, NormalAdderOut, AUIPCadderOut, LUIData,ID_EX_Func[2:0]},
{EX_MEM_Ctrl, EX_MEM_BranchAddOut, EX_MEM_Zero,
EX_MEM_ALU_out, EX_MEM_RegR2, EX_MEM_Rd,  EX_MEM_WDSel, EX_MEM_NormalAdderOut, EX_MEM_AUIPCadderOut, EX_MEM_LUIData,EX_MEM_Func3} );








//  START OF     MEM        /////////////////////////////////////


wire [31:0] MEM_WB_Mem_out, MEM_WB_ALU_out, MEM_WB_NormalAdderOut, MEM_WB_AUIPCadderOut, MEM_WB_LUIData;
wire [1:0]  MEM_WB_Ctrl;
wire [2:0]  MEM_WB_WDSel;

wire [4:0] MEM_WB_Rd;
Register #(170) MEM_WB (clk,rst,1'b1,
{EX_MEM_Ctrl[4:3],MemOut,EX_MEM_ALU_out,EX_MEM_Rd, EX_MEM_WDSel, EX_MEM_NormalAdderOut,EX_MEM_AUIPCadderOut, EX_MEM_LUIData },

{MEM_WB_Ctrl,MEM_WB_Mem_out, MEM_WB_ALU_out,
MEM_WB_Rd, MEM_WB_WDSel,MEM_WB_NormalAdderOut, MEM_WB_AUIPCadderOut, MEM_WB_LUIData} );





//wire [5:0] InstIn;
//assign InstIn = PCOut [7:2]; 
wire [7:0] MemAddr;

assign  MemAddr = (EX_MEM_Ctrl[2]|EX_MEM_Ctrl[1])? (EX_MEM_ALU_out[7:0]):(PCOut);

wire [31:0] MemOut;

//InstMem MemI(InstIn,Inst);
//module Memory(input clk,input [2:0] func3, input MemRead, input MemWrite,
//input [7:0] addr, input [31:0] data_in, output  [31:0] Mem_out);
Memory Mem(.clk(clk),
            .func3(EX_MEM_Func3),
            .MemRead(EX_MEM_Ctrl[2]),
            .MemWrite(EX_MEM_Ctrl[1]),
            .addr(MemAddr),
            .data_in(EX_MEM_RegR2),
            .Mem_out(MemOut)
            );
            
//DataMem DMem(
//    .clk(clk),
//    .func3(EX_MEM_Func3),
//    .MemRead(EX_MEM_Ctrl[2]),
//    .MemWrite(EX_MEM_Ctrl[1]),
//    .addr(EX_MEM_ALU_out[7:0]),
//    .data_in(EX_MEM_RegR2),
//    .data_out(DataMemOut)
//    );

WriteData_Selector SelD (MEM_WB_WDSel,MEM_WB_ALU_out,MEM_WB_Mem_out,MEM_WB_NormalAdderOut,MEM_WB_AUIPCadderOut,MEM_WB_LUIData, WriteData);

assign BranchAdderOut = ShiftOut + ID_EX_PC;
assign NormalAdderOut = PCOut + 4;
assign JalAdderOut = ID_EX_PC + ID_EX_Imm; // Jal Support
PC_Selector Sel (BranchAdderOut,NormalAdderOut,JalAdderOut,ALU_Result,ID_EX_PC_sel,ConfirmBranch,PCIn);// JalR will get the ALU result


// Hazard Detection Unit

wire stall;

HazardUnit HU (ReadAddress1,ReadAddress2,ID_EX_Rd,ID_EX_Ctrl[5],stall);





endmodule
