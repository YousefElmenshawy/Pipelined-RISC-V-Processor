`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2025 03:11:22 PM
// Design Name: 
// Module Name: RCA
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


module RCA #(parameter N = 8) (input signed [N-1:0] A, input signed [N-1:0] B,input Cin, output  [N-1:0]Sum , output Cout );
genvar j;
wire [N-1:0] Carry;
FA Instance(A[0],B[0],Cin,Sum[0], Carry[0]);
generate
for(j = 1; j < N; j = j+1)
begin: Gen_Modules
FA Instance(A[j],B[j],Carry[j-1],Sum[j], Carry[j]);
end
endgenerate
assign Cout = Carry[N-1];

endmodule
