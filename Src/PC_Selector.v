`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2025 12:31:50 PM
// Design Name: 
// Module Name: PC_Selector
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


module PC_Selector(input [31:0] BranchAdderOut,
input [31:0]NormalAdderOut,
input [31:0] JalAdderOut,
input [31:0] JALRdata,
input [1:0] PCsel,
input ConfirmBranch,
output reg [31:0] PCIn);

always@(*) begin
case(PCsel)
2'b00: PCIn = NormalAdderOut;
2'b01: PCIn = ConfirmBranch ? BranchAdderOut: NormalAdderOut; // if the condition is true Branch otherwise 
2'b10: PCIn = JalAdderOut;
2'b11: PCIn = JALRdata;
endcase
end
endmodule
