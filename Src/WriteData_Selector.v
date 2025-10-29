`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2025 02:43:08 PM
// Design Name: 
// Module Name: WriteData_Selector
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


module WriteData_Selector(input [2:0] WDsel, 
input [31:0] ALU_Result,
input[31:0] MemReadData,
input[31:0] JumpAdder,
input [31:0] AUIPCadder,
input [31:0] LUIdata,
output reg [31:0] WriteData );
always@(*)begin
case (WDsel)
3'b000: WriteData = ALU_Result;
3'b001: WriteData = MemReadData;
3'b010: WriteData = JumpAdder;
3'b011: WriteData = AUIPCadder;
3'b100: WriteData = LUIdata;
endcase
end
endmodule
