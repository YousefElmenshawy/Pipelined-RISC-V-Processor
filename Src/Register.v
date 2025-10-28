`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2025 03:09:02 PM
// Design Name: 
// Module Name: Register
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


module Register #(parameter N = 8)(input clk, rst, ld, input [N-1:0]D, output [N-1:0] Q );
genvar j;
wire [N-1:0] MuxOut;
generate
for(j = 0; j < N; j = j+1)
begin: Gen_Modules
Mux #(1) inst( D[N-j-1],Q[N-1-j],ld, MuxOut[N-j-1]);
DFlipFlop Inst(clk, rst, MuxOut[N-j-1], Q[N-1-j]); 
end
endgenerate
endmodule
