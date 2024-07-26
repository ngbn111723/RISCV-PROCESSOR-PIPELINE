`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/02/2024 08:34:25 PM
// Design Name: 
// Module Name: tb_RiscV
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


module tb_RiscV();
    reg clk, sys_rst;
    wire[31:0] prg_addr;
    wire[31:0] prg_data;
    wire[31:0] raddr;
    wire[31:0] waddr;
    wire[31:0] wdata;
    wire we;
    wire re;
    wire byte;
    wire half;
    wire word;
    wire[31:0] rdata; 
    integer i;
           
    RiscV_processor DUT (
    .Instructions (prg_data),
    .clk (clk),
    .sys_rst (sys_rst),
    .dmem_rdata (rdata),
    .Ins_addr (prg_addr),
    .raddr_dmem (raddr),//data memory
    .waddr_dmem (waddr),//data memory
    .wdata_dmem (wdata),//data memory
    .write_dmem (we),//data memory
    .read_dmem (re),//data memory
    .byte(byte),
    .half_word(half),
    .word(word)
    );
    
    InstructionsMemory ROM (
    .Address (prg_addr),
    .Instructions (prg_data)
    );
    
    DataMemory RAM(
    .wdata (wdata),
    .we (we),
    .re (re),
    .waddr (waddr),
    .raddr (raddr),
    .rdata (rdata),
    .byte(byte),
    .half(half),
    .word(word) 
    );
    
    parameter CLK_LO = 10;
    always #(CLK_LO) clk=~clk;
    initial begin
        for (i=0;i<32;i=i+1)  DUT.regf[i]=0;
        for (i=0;i<256;i=i+1) RAM.mem[i]=0;
//        DUT.Op1=0;
        //DUT.regf[1]=32'd8;
        sys_rst = 1'b1;
        clk = 1'b0;
        #5;
        sys_rst = 1'b0;
//        $monitor("opcode ", DUT.opcode, " funct3 ", DUT.funct3, " funct7 ", DUT.funct7);
//        $monitor("alu_src0 ", DUT.alu_src0, " alu_src1 ", DUT.alu_src1);
//        $monitor("Op1 %b", DUT.Op1, " Op2 %b", DUT.Op1, " Alu_result %b", DUT.Op1+DUT.Op2, " ALU_ control %b", DUT.ID_AluControl);
        
        #500;
        for (i=0;i<32;i=i+1) $display("REG[%d] : %d", i, DUT.regf[i]);
        #10000;
       // $stop;
    end

    
endmodule
