`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2025 03:42:08 PM
// Design Name: 
// Module Name: TC_01
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


module Program_tb();
reg clk, rst;
SingleCycle DUT (clk,rst);
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
