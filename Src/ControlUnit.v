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
`include "defines.v"
module ControlUnit(input [6:0] PartialOpcode, output reg Branch,output reg MemRead,output reg[2:0] WDsel,output reg MemWrite,output reg ALUSrc,output reg RegWrite,output reg [1:0] ALUOp, output reg [1:0] PCsel,output reg jump, output reg BreakSel);

always @(*) begin
    case (PartialOpcode[6:2])
      
         `OPCODE_Arith_R: begin
            Branch   = 0;
            MemRead  = 0;
            WDsel = 0;
            ALUOp    = 2'b10;
            MemWrite = 0;
            ALUSrc   = 0;
            RegWrite = 1;
            PCsel = 2'b00;
            BreakSel = 1'b0;
            jump = 1'b0;
        end
        
        `OPCODE_Arith_I: begin // I-Type Control Signals
            Branch   = 0;
            MemRead  = 0;
            WDsel = 0;
            ALUOp    = 2'b11;
            MemWrite = 0;
            ALUSrc   = 1;
            RegWrite = 1;
            PCsel = 2'b00;
            BreakSel = 1'b0;
           jump = 1'b0;
           
        end
       
        `OPCODE_Load : begin
        if(PartialOpcode==7'b0000000) begin
         Branch   = 0;
        MemRead  = 0;
        WDsel = 3'b000; 
        ALUOp    = 2'b00;
        MemWrite = 0;
        ALUSrc   = 1'b0;
        RegWrite = 0;
        PCsel = 2'b00;
        BreakSel = 1'b0;
        jump = 1'b0;

        end
        
        else begin
            Branch   = 0;
            MemRead  = 1;
            WDsel = 3'd1;
            ALUOp    = 2'b00;
            MemWrite = 0;
            ALUSrc   = 1;
            RegWrite = 1;
            PCsel = 2'b00;
            BreakSel = 1'b0;
           jump = 1'b0;

            end
        end
        
        `OPCODE_Store : begin
            Branch   = 0;
            MemRead  = 0;
            WDsel = 3'bxxx;  
            ALUOp    = 2'b00;
            MemWrite = 1;
            ALUSrc   = 1;
            RegWrite = 0;
            PCsel = 2'b00;
            BreakSel = 1'b0;
           jump = 1'b0;

        end
       
        `OPCODE_Branch : begin
            Branch   = 1;
            MemRead  = 0;
            WDsel = 3'bxxx;  
            ALUOp    = 2'b01;
            MemWrite = 0;
            ALUSrc   = 0;
            RegWrite = 0;
            PCsel = 2'b01;
            BreakSel = 1'b0;
            jump = 1'b0;

           end 
       `OPCODE_JAL : begin
         Branch   = 0;
         MemRead  = 0;
         WDsel = 3'b010; 
         ALUOp    = 2'bxx; //No need for the ALU
         MemWrite = 0;
         ALUSrc   = 1'bx; 
         RegWrite = 1;
         PCsel = 2'b10;
         BreakSel = 1'b0;
         jump = 1'b1;

        end
        
       `OPCODE_JALR : begin
         Branch   = 0;
         MemRead  = 0;
         WDsel = 3'b010; 
         ALUOp    = 2'b00; //Add rs1 and IMM
         MemWrite = 0;
         ALUSrc   = 1;
         RegWrite = 1;
         PCsel = 2'b11;
         BreakSel = 1'b0;
        jump = 1'b1;

        end
        `OPCODE_AUIPC : begin
        
         Branch   = 0;
         MemRead  = 0;
         WDsel = 3'b011; 
         ALUOp    = 2'bxx;
         MemWrite = 0;
         ALUSrc   = 1'bx;
         RegWrite = 1;
         PCsel = 2'b00;
         BreakSel = 1'b0;
         jump = 1'b0;

         end
        
       `OPCODE_LUI : begin
    
        Branch   = 0;
        MemRead  = 0;
        WDsel = 3'b100; 
        ALUOp    = 2'bxx;
        MemWrite = 0;
        ALUSrc   = 1'bx;
        RegWrite = 1;
        PCsel = 2'b00;
        BreakSel = 1'b0;
        jump = 1'b0;
      
        end
        
       `OPCODE_SYSTEM : begin
        Branch   = 0;
        MemRead  = 0;
        WDsel = 3'b000; 
        ALUOp    = 2'b00;
        MemWrite = 0;
        ALUSrc   = 1'b0;
        RegWrite = 0;
        PCsel = 2'b00;
        BreakSel = 1'b1;
        jump = 1'b0;

        end
        
        `OPCODE_FENCE : begin
         Branch   = 0;
        MemRead  = 0;
        WDsel = 3'b000; 
        ALUOp    = 2'b00;
        MemWrite = 0;
        ALUSrc   = 1'b0;
        RegWrite = 0;
        PCsel = 2'b00;
        BreakSel = 1'b1;
       jump = 1'b0;

        end
        
        default: begin
        Branch   = 0;
        MemRead  = 0;
        WDsel = 3'b000; 
        ALUOp    = 2'b00;
        MemWrite = 0;
        ALUSrc   = 1'b0;
        RegWrite = 0;
        PCsel = 2'b00;
        BreakSel = 1'b0;
        jump = 1'b0;

        end
        
        
    endcase
end
endmodule
