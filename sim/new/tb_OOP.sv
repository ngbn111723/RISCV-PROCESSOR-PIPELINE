`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2024 06:38:19 PM
// Design Name: 
// Module Name: tb_OOP
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
class Packet;
    logic[6:0]  opcode;
    logic[4:0]  rd;
    logic[4:0]  rs1;
    logic[4:0]  rs2;
    logic[2:0]  funct3;
    logic[6:0]  funct7;
    logic[20:0] imm20;
    logic[11:0] imm12;
    logic[20:0] immjal;
    logic[4:0]  immbeq1;
    logic[6:0]  immbeq2;
    logic[4:0]  immsb1;
    logic[6:0]  immsb2;
    logic[31:0] instruction;
    string name;
    
    constraint opcode_c {
    
        opcode inside {7'b0110111, 7'b0010111, 7'b1101111, 7'b1100111, 7'b1100011, 7'b0000011, 7'b0100011, 7'b0010011, 7'b0110011};
    }
   constraint register_c {
        rd inside {[0:31]};
        rs1 inside {[0:31]};
        rs2 inside {[0:31]};
    }
    
    extern function new (string name, logic[6:0]  opcode, logic[4:0]  rd, logic[2:0] funct3, logic[4:0] rs1, logic[11:0] imm12, 
                         logic[6:0] funct7, logic[20:0] imm20, logic[20:0] immjal, logic[4:0] immbeq1, logic[6:0] immbeq2, 
                         logic[4:0] immsb1, logic[6:0] immsb2, logic[4:0]  rs2);
    extern function create();
    extern function display();
endclass

function Packet :: new (string name, logic[6:0]  opcode, logic[4:0]  rd, logic[2:0] funct3, logic[4:0] rs1, logic[11:0] imm12, 
                        logic[6:0] funct7, logic[20:0] imm20, logic[20:0] immjal, logic[4:0] immbeq1, logic[6:0] immbeq2, 
                        logic[4:0] immsb1, logic[6:0] immsb2, logic[4:0]  rs2);
    this.name       = name;
    this.opcode     = opcode;
    this.rd         = rd;
    this.rs1        = rs1;
    this.rs2        = rs2;
    this.funct3     = funct3;
    this.funct7     = funct7;
    this.imm20      = imm20;
    this.imm12      = imm12;
    this.immjal     = immjal;
    this.immbeq1    = immbeq1;
    this.immbeq2    = immbeq2;
    this.immsb1     = immsb1;
    this.immsb2     = immsb2;
endfunction

function Packet :: create ();
    case (this.opcode)
         	7'b0110111:  begin //lui
         	  this.instruction[6:0]    = this.opcode;
         	  this.instruction[11:7]   = this.rd;
         	  this.instruction[31:12]  = this.imm20;
         	end 
            7'b0010111:  begin //auipc
         	  this.instruction[6:0]    = this.opcode;
         	  this.instruction[11:7]   = this.rd;
         	  this.instruction[31:12]  = this.imm20;
            end
            7'b1101111:  begin //jal
                this.instruction[6:0]   = this.opcode;
                this.instruction[11:7]  = this.rd;
                this.instruction[31:12] = this.immjal;
            end
            7'b1100111:  begin //jalr
                this.instruction[6:0]   = this.opcode;
                this.instruction[11:7]  = this.rd;
                this.instruction[14:12] = this.funct3;
                this.instruction[19:15] = this.rs1;
                this.instruction[20:31] = this.imm12;
            end
            7'b1100011:  begin //branch 
                this.instruction[6:0]   = this.opcode;
                this.instruction[11:7]  = this.immbeq1;
                this.instruction[14:12] = this.funct3;
                this.instruction[19:15] = this.rs1;
                this.instruction[24:20] = this.rs2;
                this.instruction[31:25] = this.immbeq2;
            end   
            7'b0000011:  begin //load   
                this.instruction[6:0]       = this.opcode;
                this.instruction[11:7]      = this.rd;
                this.instruction[14:12]     = this.funct3;
                this.instruction[19:15]     = this.rs1;
                this.instruction[31:20]     = this.imm12;
            end                         
            7'b0100011:  begin //store  
                this.instruction[6:0]   = this.opcode;
                this.instruction[11:7]  = this.immsb1;
                this.instruction[14:12] = this.funct3;
                this.instruction[19:15] = this.rs1;
                this.instruction[24:20] = this.rs2;
                this.instruction[31:25] = this.immsb2;
            end       
            7'b0010011:  begin //I-format
                this.instruction[6:0]       = this.opcode;
                this.instruction[11:7]      = this.rd;
                this.instruction[14:12]     = this.funct3;
                this.instruction[19:15]     = this.rs1;
                this.instruction[31:20]     = this.imm12;
            end
            7'b0110011:  begin //R-type
                this.instruction[6:0]   = this.opcode;
                this.instruction[11:7]  = this.rd;
                this.instruction[14:12] = this.funct3;
                this.instruction[19:15] = this.rs1;
                this.instruction[24:20] = this.rs2;
                this.instruction[31:25] = this.funct7;
            end
            default: begin
            end
   endcase
endfunction  

function Packet :: display();
    $display (this.name, " %b", this.instruction);
endfunction 

interface processor_io(input bit clock);
    logic [31:0] Instructions;
    logic sys_rst;
    logic [31:0] dmem_rdata;
    logic [31:0] Ins_addr;
    logic [31:0] raddr_dmem;
    logic [31:0] waddr_dmem;
    logic [31:0] wdata_dmem;
    logic write_dmem;
    logic read_dmem;
    clocking cb @(posedge clock);
        output Instructions;
        output sys_rst;
        output dmem_rdata;
        input Ins_addr;
        input raddr_dmem; 
        input waddr_dmem; 
        input wdata_dmem; 
        input write_dmem; 
        input read_dmem; 
    endclocking 
    modport TB (clocking cb, output sys_rst);
endinterface

program automatic test (processor_io p_io);
    Packet pkt2send[15];
    logic  [31:0] ins_arr[15];
    integer j;
    initial begin
       top_io.sys_rst     = 1'b1;
       #5;
       top_io.sys_rst     = 1'b0;
       gen();
       driver();
       #350;
       
    end
     task driver();
        base_driver();
       #10 base_driver();
       #10 base_driver();
       #10 base_driver();
       #10 base_driver();
       #10 base_driver();
       #10 base_driver();
       #10 base_driver();
       #10 base_driver();
       #10 base_driver();
       #10 base_driver();
       #10 base_driver();
       #10 base_driver();
       #10 base_driver();
       #10 base_driver();
     endtask 
     task base_driver();
         case (top_io.Ins_addr)
            32'h00000000: top_io.Instructions= ins_arr[0]; 
            32'h00000004: top_io.Instructions= ins_arr[1];    
            32'h00000008: top_io.Instructions= ins_arr[2]; 
            32'h0000000c: top_io.Instructions= ins_arr[3];
            32'h00000010: top_io.Instructions= ins_arr[4]; 
            32'h00000014: top_io.Instructions= ins_arr[5];    
            32'h00000018: top_io.Instructions= ins_arr[6]; 
            32'h0000001c: top_io.Instructions= ins_arr[7];   
            32'h00000020: top_io.Instructions= ins_arr[8];
            32'h00000024: top_io.Instructions= ins_arr[9];   
            32'h00000028: top_io.Instructions= ins_arr[10];    
            32'h0000002c: top_io.Instructions= ins_arr[11]; 
            32'h00000030: top_io.Instructions= ins_arr[12];   
            32'h00000034: top_io.Instructions= ins_arr[13];
            32'h00000038: top_io.Instructions= ins_arr[14];  
            default: top_io.Instructions = 32'dz;       
        endcase
    endtask 
    task gen();
         // name opcode rd funct3 rs1 imm12 funct7 imm20 20immjal 5immbeq1 7immbeq2 5immsb1 7immsb2 rs2
         pkt2send[0]= new("addi x1, x0, 2", 7'b0010011, 5'b00001, 3'b000, 5'b00000, 12'b000000000010, 7'd0, 20'd0, 20'd0, 5'd0,  7'd0, 5'd0, 7'd0, 5'd0);
         pkt2send[1]= new("addi x2, x0, 1", 7'b0010011, 5'b00010, 3'b000, 5'b00000, 12'b000000000001, 7'd0, 20'd0, 20'd0, 5'd0,  7'd0, 5'd0, 7'd0, 5'd0);
         pkt2send[2]= new("addi x3, x0, 5", 7'b0010011, 5'b00011, 3'b000, 5'b00000, 12'b000000000101, 7'd0, 20'd0, 20'd0, 5'd0,  7'd0, 5'd0, 7'd0, 5'd0);
         pkt2send[3]= new("addi x4, x0, 2", 7'b0010011, 5'b00100, 3'b000, 5'b00000, 12'b000000000010, 7'd0, 20'd0, 20'd0, 5'd0,  7'd0, 5'd0, 7'd0, 5'd0);
         pkt2send[4]= new("addi x5, x0, 0", 7'b0010011, 5'b00101, 3'b000, 5'b00000, 12'b000000000000, 7'd0, 20'd0, 20'd0, 5'd0,  7'd0, 5'd0, 7'd0, 5'd0);
         pkt2send[5]= new("addi x6, x0, 3", 7'b0010011, 5'b00110, 3'b000, 5'b00000, 12'b000000000011, 7'd0, 20'd0, 20'd0, 5'd0,  7'd0, 5'd0, 7'd0, 5'd0);
         pkt2send[6]= new("addi x7, x0, 6", 7'b0010011, 5'b00111, 3'b000, 5'b00000, 12'b000000000110, 7'd0, 20'd0, 20'd0, 5'd0,  7'd0, 5'd0, 7'd0, 5'd0);
         pkt2send[7]= new("addi x8, x0, 6", 7'b0010011, 5'b01000, 3'b000, 5'b00000, 12'b000000000110, 7'd0, 20'd0, 20'd0, 5'd0,  7'd0, 5'd0, 7'd0, 5'd0);
         pkt2send[8]= new("sw   x8, 0(x0)", 7'b0100011, 5'd0, 3'b010, 5'b00000, 12'd0, 7'd0, 20'd0, 20'd0, 5'd0,  7'd0, 5'd0, 7'd0, 5'b01000);
         pkt2send[9]= new("lw   x9, 0(x0)", 7'b0000011, 5'b01001, 3'b010, 5'b00000, 12'b000000000000, 7'd0, 20'd0, 20'd0, 5'd0,  7'd0, 5'd0, 7'd0, 5'd0);
         pkt2send[10]= new("bne  x1, x2, lui", 7'b1100011, 5'd0, 3'b001, 5'b00001, 12'd0, 7'd0, 20'd0, 20'd0, 5'b01000,  7'b0000000, 5'd0, 7'd0, 5'b00010);
         pkt2send[11]= new("auipc x9, 0x1", 7'b0010111, 5'b01001, 3'd0, 5'd0, 12'd0, 7'd0, 20'b00000000000000000001, 20'd0, 5'd0,  7'd0, 5'd0, 7'd0, 5'd0);
         pkt2send[12]= new("lui: lui x10, 0x1",  7'b0110111, 5'b01010, 3'd0, 5'd0, 12'd0, 7'd0, 20'b00000000000000000001, 20'd0, 5'd0,  7'd0, 5'd0, 7'd0, 5'd0);
         pkt2send[13]= new("jal x12, End",  7'b1101111, 5'b01100, 3'd0, 5'd0, 12'd0, 7'd0, 20'd0, 20'b00000000100000000000, 5'd0,  7'd0, 5'd0, 7'd0, 5'd0);
         pkt2send[14]= new("add x11, x0, x1",  7'b0110011, 5'b01011, 3'b000, 5'b00000, 12'd0, 7'd0, 20'd0, 20'd0, 5'd0,  7'd0, 5'd0, 7'd0, 5'b00001);
         foreach  (pkt2send[i]) pkt2send[i].create();
         foreach  (ins_arr[i])  ins_arr[i]= pkt2send[i].instruction;
         foreach  (ins_arr[i])  $display (ins_arr[i]); //= pkt2send[i].instruction;
    endtask 

endprogram

module RiscVProcessor_test_top();
    parameter simulation_cycle= 10;
    bit SystemClock;
    processor_io top_io(SystemClock);
    test t (top_io);
    
    RiscV_processor DUT(
        .Instructions(top_io.Instructions),
        .clk         (top_io.clock),
        .sys_rst     (top_io.sys_rst),
        .dmem_rdata  (top_io.dmem_rdata),
        .Ins_addr    (top_io.Ins_addr),
        .raddr_dmem  (top_io.raddr_dmem),
        .waddr_dmem  (top_io.waddr_dmem),
        .wdata_dmem  (top_io.wdata_dmem),
        .write_dmem  (top_io.write_dmem),
        .read_dmem   (top_io.read_dmem)
    );
    
    DataMemory RAM(
        .wdata (top_io.wdata_dmem),
        .we (top_io.write_dmem),
        .re (top_io.read_dmem),
        .waddr (top_io.waddr_dmem),
        .raddr (top_io.raddr_dmem),
        .rdata (top_io.dmem_rdata) 
    );
    
    integer i;
    always #5 SystemClock=~SystemClock;
    initial begin
        SystemClock=0;
        for (i=0; i<32  ; i=i+1)  DUT.regf[i]=0;
        for (i=0; i<256 ; i=i+1) RAM.mem[i]=0;
        #350 
        for (i=0; i<32  ; i=i+1) $display("REG [",i,"]",DUT.regf[i]);
        $stop;
    end
endmodule

