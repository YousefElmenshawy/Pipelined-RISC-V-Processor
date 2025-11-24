`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2025 03:59:02 PM
// Design Name: 
// Module Name: program_tb
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


module program_tb();
reg clk, rst;
Pipelined DUT (clk,rst);
initial begin
clk =0 ;
forever#(5) clk = ~clk;

end
initial begin
rst = 1;
#10
rst =0;

end

endmodule
