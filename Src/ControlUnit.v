`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2025 05:14:12 PM
// Design Name: 
// Module Name: ControlUnit
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


module ControlUnit(input [4:0] PartialOpcode, output reg Branch,output reg MemRead,output reg MemtoReg,output reg MemWrite,output reg ALUSrc,output reg RegWrite,output reg [1:0] ALUOp);
always @(*) begin
    case (PartialOpcode)
      
        5'b01100: begin
            Branch   = 0;
            MemRead  = 0;
            MemtoReg = 0;
            ALUOp    = 2'b10;
            MemWrite = 0;
            ALUSrc   = 0;
            RegWrite = 1;
        end
       
        5'b00000: begin
            Branch   = 0;
            MemRead  = 1;
            MemtoReg = 1;
            ALUOp    = 2'b00;
            MemWrite = 0;
            ALUSrc   = 1;
            RegWrite = 1;
        end
        
        5'b01000: begin
            Branch   = 0;
            MemRead  = 0;
            MemtoReg = 1'bx;  
            ALUOp    = 2'b00;
            MemWrite = 1;
            ALUSrc   = 1;
            RegWrite = 0;
        end
       
        5'b11000: begin
            Branch   = 1;
            MemRead  = 0;
            MemtoReg = 1'bx;  
            ALUOp    = 2'b01;
            MemWrite = 0;
            ALUSrc   = 0;
            RegWrite = 0;
        end
        
         default: begin
            Branch   = 1'bx;
            MemRead  = 1'bx;
            MemtoReg = 1'bx;  
            ALUOp    = 2'bxx;
            MemWrite = 1'bx;
            ALUSrc   = 1'bx;
            RegWrite = 1'bx;
        end
    endcase
end
endmodule
