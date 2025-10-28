`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2025 03:01:56 PM
// Design Name: 
// Module Name: ALU
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


  module ALU #(parameter N = 32)(input [N-1:0] A, [N-1:0] B, input [3:0] sel, output reg [N-1:0] out, output ZFlag );
wire [N-1:0] Result;
wire [N-1:0] MuxBOut;
wire [N-1:0] OrOut ;
wire [N-1:0] AndOut;
wire [N-1:0] MuxInputs [15:0];
wire MuxCarry;
assign MuxInputs[0] = AndOut; 
assign MuxInputs[1] = OrOut;
assign MuxInputs[2] = Result;
assign MuxInputs[6] = Result;
assign ZFlag = (out == 0)? (1'b1): (1'b0);
assign OrOut = A | B;
assign AndOut = A & B;
wire [N-1:0] NotB;
assign NotB = ~B;
Mux #(N) instB(NotB, B, sel[2], MuxBOut);
Mux #(1) instC(1'b1, 1'b0, sel[2], MuxCarry);
wire Cout;
RCA #(N)  instA( A, MuxBOut, MuxCarry, Result, Cout);
always @(*) begin
case(sel) 
        4'd0:  out = MuxInputs[0];
        4'd1:  out = MuxInputs[1];
        4'd2:  out = MuxInputs[2];
        4'd6:  out = MuxInputs[6];

        default: out = 0;
endcase
end
endmodule
