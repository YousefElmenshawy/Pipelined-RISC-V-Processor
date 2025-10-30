`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2025 03:09:34 PM
// Design Name: 
// Module Name: BitSelector
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


module BitSelector( input  [31:0] Data, input  [2:0] Sel, output reg [31:0] DataOut);

always @(*) begin
    case (Sel)
        3'b000: begin // Word
            DataOut = Data;
        end
        
        3'b001: begin // Half unsigned
            DataOut = {16'b0, Data[15:0]};
        end
        
        3'b010: begin // Half signed
            // Sign-extend from lower byte
            DataOut = {{16{Data[15]}}, Data[15:0]};
        end
        
        3'b011: begin // Byte Unsigned
            // Sign-extend from lower byte
            DataOut = {{16{Data[15]}}, Data[15:0]};
        end
        
        default: begin
            DataOut = Data;
        end
    endcase
end

endmodule