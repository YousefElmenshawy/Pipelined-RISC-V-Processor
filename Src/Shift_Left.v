`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2025 03:39:12 PM
// Design Name: 
// Module Name: Shift_Left
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


module Shift_Left #(parameter N = 8) (input [N-1:0] In , output [N-1:0] out );
assign out = {In [N-2:0] , 1'b0};
endmodule
