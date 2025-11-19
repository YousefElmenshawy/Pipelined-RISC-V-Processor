`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2025 02:41:11 PM
// Design Name: 
// Module Name: Mux4
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


module Mux4(input [31:0] a,b,c,d,input [1:0] s, output reg [31:0] out );
always@(*) begin
case(s)
2'b00: out = a;
2'b01: out = b;
2'b10: out = c;
2'b11: out = d;
endcase
end
endmodule
