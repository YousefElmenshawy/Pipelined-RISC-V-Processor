`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2025 02:49:07 PM
// Design Name: 
// Module Name: ShifterTwelve
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


module ShifterTwelve(input [31:0] genOut, output [31:0] ShiftOut);

assign ShiftOut[31:12] = genOut [19:0];
assign ShiftOut[11:0] = 12'b0;
endmodule
