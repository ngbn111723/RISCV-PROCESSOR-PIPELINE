`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/02/2024 08:47:06 PM
// Design Name: 
// Module Name: DataMemory
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


module DataMemory(
    input [31:0] wdata,
    input we,
    input re,
    input [31:0] waddr,
    input [31:0] raddr,
    input half,
    input byte,
    input word,
    output [31:0] rdata
);
    
reg [31:0] rdata;
reg [7:0] mem [0:200];

//integer i;
//initial for (i=0;i<256;i=i+1) ram.mem[i]=0;
always @(*) begin
    if(re) 
        if (byte) rdata= mem[raddr];
        else if (half) rdata= {mem[raddr+1], mem[raddr]};
        else if (word) rdata= {mem[raddr+3], mem[raddr+2], mem[raddr+1], mem[raddr]};
end
always @(*) begin
    if(we) 
        if (byte) mem[waddr] = wdata;
        else if (half) {mem[waddr+1], mem[waddr]} = wdata;
        else if (word) {mem[waddr+3], mem[waddr+2], mem[waddr+1], mem[waddr]} = wdata;
    
end

endmodule
