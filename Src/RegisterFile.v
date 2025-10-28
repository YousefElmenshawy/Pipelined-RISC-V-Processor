`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2025 04:39:21 PM
// Design Name: 
// Module Name: RegisterFile
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


module RegisterFile #(parameter N = 32)(input clk, rst, input [4:0] ReadAddress1, input[4:0] ReadAddress2, input [4:0] WriteAddress, input [N-1:0] WriteData, input RegWrite, output [N-1:0]ReadData1, output [N-1:0] ReadData2);
reg [N-1:0] RegFile [31:0];
integer i;

assign ReadData1 = RegFile[ReadAddress1];
assign ReadData2 = RegFile[ReadAddress2];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 32; i = i + 1)
            RegFile[i] <= 0;
    end
    else if (RegWrite && WriteAddress!= 0) begin
        RegFile[WriteAddress] <= WriteData;
    end
end
endmodule
