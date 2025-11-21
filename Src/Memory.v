`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2025 05:30:12 PM
// Design Name: 
// Module Name: Memory
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


module Memory(input clk,input [2:0] func3, input MemRead, input MemWrite,
input [7:0] addr, input [31:0] data_in, output  [31:0] Mem_out);

reg [7:0] mem [0:511]; // Half Instructions and Half Data (Total 4kb)
integer j;
initial begin
  for (j = 0; j < 511; j = j + 1)
      mem[j] = 0;
 end
 
wire [31:0] InstOut; 
assign InstOut = {mem[addr+3],mem[addr+2],mem[addr+1], mem[addr]}; //instruction
reg [31:0] data_out;


 
initial begin
//Data
mem[256]=8'd17;
mem[260]=8'd9;
mem[264]=8'd25;

// Instructions
mem[0]=8'h93; // addi x1, x0, 1  0x00100093
mem[1] = 8'h00;
mem[2] = 8'h10;
mem[3] = 8'h00;



// addi x6, x0, 0   ; sum = 0 0x00000313


mem[4]=8'h13; 
mem[5] = 8'h03;
mem[6] = 8'h00;
mem[7] = 8'h00;




 // addi x2, x0, 5   ; limit = 5  0x00500113

mem[8]=8'h13; 
mem[9] = 8'h01;
mem[10] = 8'h50;
mem[11] = 8'h00;




// loop: sum += i
 // add x6, x6, x1   ; sum = sum + i

//0x00130333

mem[12]=8'h33; 
mem[13] = 8'h03;
mem[14] = 8'h13;
mem[15] = 8'h00;




 // addi x1, x1, 1   ; i = i + 1
//0x00108093

mem[16]=8'h93; 
mem[17] = 8'h80;
mem[18] = 8'h10;
mem[19] = 8'h00;


// check if i <= 5 ? continue loop
 // sub x7, x1, x2   ; x7 = i - 5
//0x402083b3

mem[20]=8'hb3; 
mem[21] = 8'h83;
mem[22] = 8'h20;
mem[23] = 8'h40;



 // bge x0, x7, -12  ; if i < 5, branch back (to mem[3])
//0xfe705ae3

mem[24]=8'he3; 
mem[25] = 8'h5a;
mem[26] = 8'h70;
mem[27] = 8'hfe;

// end (loop done)


 // sw x6, 12(x0)    ; store sum (optional)
//0x00602623
mem[28]=8'h23; 
mem[29] = 8'h26;
mem[30] = 8'h60;
mem[31] = 8'h00;


 // lw x6, 12(x0)     ; reload sum
//0x00c02303


mem[32]=8'h03; 
mem[33] = 8'h23;
mem[34] = 8'hc0;
mem[35] = 8'h00;


//0x01400193   addi x3, x0,20

mem[36]=8'h93; 
mem[37] = 8'h01;
mem[38] = 8'h40;
mem[39] = 8'h01;



//addi x4, x0, 29   

//0x01d00213

mem[40]=8'h13; 
mem[41] = 8'h02;
mem[42] = 8'hd0;
mem[43] = 8'h01;

 //ecall to exit

mem[44]=8'h73; 
mem[45] = 8'h00;
mem[46] = 8'h00;
mem[47] = 8'h00;

end
always@ (posedge clk) begin
if(MemWrite)
case(func3)
3'b000:  mem[addr+256] <= data_in[7:0]; //sb
3'b001: {mem[addr+256+1], mem[addr+256]}<= data_in[15:0]; //shw
3'b010: {mem[addr+256+3], mem[addr+256+2], mem[addr+256+1], mem[addr+256]} <= data_in ; //sw
endcase
end
always@ (*) begin
if(MemRead)
case(func3)
 3'b000: data_out = {{ 24{mem[addr+256][7]}} ,mem[addr+256]};      //lb
 3'b001: data_out = {{16{mem[addr+256][7]}}, mem[addr+256], mem[addr+256]};           //lhw
 3'b010: data_out = { mem[addr+256+3], mem[addr+256+2], mem[addr+256+1], mem[addr+256]};  //LW
 3'b100: data_out = {24'b0, mem[addr+256]}; //lbu
 3'b101: data_out = {16'b0, mem[addr+256+1], mem[addr+256]};  //lhu
 default: data_out = 32'b0;
 endcase
end
assign Mem_out = (MemRead|MemWrite)?(data_out):(InstOut);
endmodule



