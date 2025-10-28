`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2025 03:01:24 PM
// Design Name: 
// Module Name: FA
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


module FA(input A, B, Cin, output Sum, Cout );

assign Sum = A^B^Cin;
assign Cout = (A&B)| (B&Cin)|(A&Cin);
endmodule
