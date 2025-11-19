`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2025 11:48:02 AM
// Design Name: 
// Module Name: ForwardingUnit
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


 module ForwardingUnit(input EX_MEM_RegWrite,input [4:0] EX_MEM_RegisterRd,
 ID_EX_RegisterRs1,ID_EX_RegisterRs2,input MEM_WB_RegWrite, input [4:0] MEM_WB_RegisterRd , 
 output reg [1:0] ForwardA, ForwardB);
 reg EXA, EXB;
 
 always@(*) begin
 // No Forwarding
 ForwardA = 2'b00;
 ForwardB = 2'b00;
 EXA = 1'b0;
 EXB = 1'b0;

 
 // EX Conditions
 if (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) &&(EX_MEM_RegisterRd == ID_EX_RegisterRs1))begin
 ForwardA = 2'b10;
 EXA = 1'b1;
 end
 else
 EXA = 1'b0;
 if (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) &&(EX_MEM_RegisterRd == ID_EX_RegisterRs2))begin
 ForwardB = 2'b10;
 EXB = 1'b1;
 end
 else
 EXB = 1'b0;
 // MEM Conditions
 if(!EXA && MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0)&&(MEM_WB_RegisterRd == ID_EX_RegisterRs1))
 ForwardA = 2'b01;
  if(!EXB && MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0)&&(MEM_WB_RegisterRd == ID_EX_RegisterRs2))
 ForwardB = 2'b01;
 
 end

endmodule
