`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2024 03:35:00 PM
// Design Name: 
// Module Name: mux4to1
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


module mux4to1(
    input [31:0] In0,
    input [31:0] In1,
    input [31:0] In2,
    input [31:0] In3,
    input [1:0] Sel,
    output reg [31:0] Out
    );
    always @(*) begin
        case (Sel)
            2'b00: Out = In0;
            2'b01: Out = In1;
            2'b10: Out = In2;
            2'b11: Out = In3;
            default:  Out= In0;
        endcase
    end 
endmodule
