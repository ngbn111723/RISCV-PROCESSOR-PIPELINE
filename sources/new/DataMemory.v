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
    output [31:0] rdata
);
    
reg [31:0] rdata;
reg [31:0] mem [0:2045];

//integer i;
//initial for (i=0;i<256;i=i+1) ram.mem[i]=0;
always @(*) begin
    if(re) rdata = mem[raddr];
end
always @(*) begin
    if(we) mem[waddr] = wdata;
end

endmodule
