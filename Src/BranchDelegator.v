`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2025 05:48:59 PM
// Design Name: 
// Module Name: BranchDelegator
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


module BranchDelegator(input ZFlag, CFlag, SFlag, VFlag, Branch, input [2:0] func3, output reg ConfirmBranch  );

always @(*) begin
    case (func3)
      
        3'b000: begin //BEQ
        if(Branch && ZFlag) ConfirmBranch = 1'b1;
        end
        
        3'b001: begin  //BNE
        if(Branch && ~ZFlag) ConfirmBranch = 1'b1;
        end
        
        3'b100: begin  //BLT
        if(Branch && (SFlag != VFlag)) ConfirmBranch = 1'b1;
        end
        
        3'b101: begin  //BGE
        if(Branch && (SFlag == VFlag)) ConfirmBranch = 1'b1;
        end
        
        3'b110: begin  //BLTU
        if(Branch && ~CFlag) ConfirmBranch = 1'b1;
        end
        
        3'b111: begin  //BGEU
        if(Branch && CFlag) ConfirmBranch = 1'b1;
        end
        
        
        default: ConfirmBranch = 1'b0;

endcase
end
endmodule
