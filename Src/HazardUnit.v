`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2025 03:46:36 PM
// Design Name: 
// Module Name: HazardUnit
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


module HazardUnit(input [4:0] IF_ID_RS1, IF_ID_RS2, ID_EX_Rd,input ID_EX_MemRead,EX_MEM_MemRead,EX_MEM_MemWrite, output reg stall,fetchstall);
always@(*) begin
if(((IF_ID_RS1 == ID_EX_Rd) || (IF_ID_RS2 == ID_EX_Rd)) && ID_EX_MemRead && (ID_EX_Rd!=0))
stall = 1'b1;
else
stall = 1'b0;
if(EX_MEM_MemRead||EX_MEM_MemWrite)
fetchstall = 1'b1;
else
fetchstall = 1'b0;

end
endmodule
