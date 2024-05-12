`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Information Technology
// Engineer: Nguyen Gia Bao Ngoc
// 
// Create Date: 04/30/2024 08:56:30 PM
// Design Name: RiscV Processor
// Module Name: RiscV_processor
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


module RiscV_processor(
    input [31:0] Instructions,
    input clk,
    input sys_rst,
    input[31:0] dmem_rdata,
    output [31:0] Ins_addr,
    output [31:0] raddr_dmem,//data memory
    output [31:0] waddr_dmem,//data memory
    output reg [31:0] wdata_dmem,//data memory
    output write_dmem,//data memory
    output read_dmem//data memory
    );
    
    wire[31:0] pc_incr4, pc_branch, pc_next, pc_shift1, pc_temp, pc_addRs1;
    reg pc_src1, pc_src2;
    reg [31:0] pc;
    wire [31:0] inst;
    reg rst;
    ////////////////////////////////////////////***IF STAGE***\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    assign pc_incr4 = pc+4;
    assign Ins_addr = pc;
    assign inst     = Instructions;
    always @(posedge clk or posedge sys_rst or posedge rst) 
        if (sys_rst) pc <= 0;
        else if (!rst) pc <= pc_next;
             else pc <= pc;
    always @(posedge sys_rst)  begin
        ID_AluSrc0 <= 0;
        ID_AluSrc1 <= 0;
        fwdA <=0;
        fwdB <=0;
    end  
    mux2to1 mux0(    
    .In0(pc_incr4),
    .In1(pc_shift1),
    .Sel(pc_src1),
    .Out(pc_temp)
    );  
    
     mux2to1 mux1(    
    .In0(pc_temp),
    .In1(pc_addRs1),
    .Sel(pc_src2),
    .Out(pc_next)
    );
    
    reg [31:0] IF_pc_incr4, IF_pc, IF_ins;
    always @(negedge clk or posedge rst) begin
            IF_pc_incr4 <= pc_incr4;
            IF_pc       <= pc;
            IF_ins      <= inst;
        end
//        if (rst||pc_src1) begin
//            IF_pc_incr4 = 32'd0;
//            IF_pc       = 32'd0;
//            IF_ins      = 32'd0;
//        end else begin
//            IF_pc_incr4 = pc_incr4;
//            IF_pc       = pc;
//            IF_ins      = inst;
//        end

    ////////////////////////////////////////////***ID STAGE***\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    //***********************CONTROLLER***********************\\
    reg[2:0] funct3;
    reg[6:0] funct7;
    wire[6:0] opcode;
    reg alu_src0, alu_src1, unsign, memtoreg, jump, regwrite, branch_access;
    reg[3:0] alu_control;
    reg [2:0] mem_read, mem_write;
    reg[4:0] rs1, rs2, rd;
    assign opcode= IF_ins[6:0];
    always @(*) begin
        if (opcode==7'b0010011||opcode==7'b0110011||opcode==7'b0000011||opcode==7'b0110111||opcode==7'b0010111||opcode==7'b1101111||opcode==7'b1100111)
        rd= IF_ins[11:7]; else rd= 5'dz;
        if (opcode==7'b1101111||opcode==7'b0010111 ||opcode==7'b0110111)  rs1= 5'dz; else rs1= IF_ins[19:15];
        if (opcode==7'b0110011 ||opcode==7'b0100011 ||opcode==7'b1100011) rs2= IF_ins[24:20]; else  rs2= 5'dz;
    end
    always @(*) begin
        if (opcode==7'b1101111||opcode==7'b0010111 ||opcode==7'b0110111)  funct3= 3'dz; else funct3= IF_ins[14:12];
        if (opcode==7'b0110011) funct7= IF_ins[31:25]; 
        else if (opcode==7'b0010011) 
                if (IF_ins[14:12]==3'b001||IF_ins[14:12]==3'b101) funct7= IF_ins[31:25];
                else funct7=7'dz;
             else funct7=7'dz;
    end
//    assign rs1= IF_ins[19:15];  //rs1
//    assign rs2= IF_ins[24:20]; //rs2
//    assign rd= IF_ins[11:7]; //rd
    
//    assign funct3= IF_ins[14:12];
//    assign funct7= IF_ins[31:25];

    
    always @(*)
        if (rst==1 || sys_rst ==1) begin
                alu_src0      = 1'b0; 
                alu_src1      = 1'b0;
                mem_write     = 3'b000;
                mem_read      = 3'b000;
                unsign        = 1'b0;
                memtoreg      = 1'b0;
                jump          = 1'b0;
                regwrite      = 1'b0;
                alu_control   = 4'b1111;
                branch_access = 1'b0; 
        end
        else begin
            case (opcode) 
            7'b0110111:  begin //lui
                alu_src0      = 1'b1;
                alu_src1      = 1'b1;
                mem_write     = 3'b000;
                mem_read      = 3'b000;
                unsign        = 1'b0;
                memtoreg      = 1'b0;
                jump          = 1'b0;
                regwrite      = 1'b1;
                alu_control   = 4'b0101;//lui
                branch_access = 1'b0;
            end
            7'b0010111: begin //auipc
                alu_src0      = 1'b1;
                alu_src1      = 1'b1;
                mem_write     = 3'b000;
                mem_read      = 3'b000;
                unsign        = 1'b0;
                memtoreg      = 1'b0;
                jump          = 1'b0;
                regwrite      = 1'b1;
                alu_control   = 4'b0110;//auipc
                branch_access = 1'b0;
            end
            7'b1101111: begin //jal
                alu_src0      = 1'b0;
                alu_src1      = 1'b0;
                mem_write     = 3'b000;
                mem_read      = 3'b000;
                unsign        = 1'b0;
                memtoreg      = 1'b0;
                jump          = 1'b1;
                regwrite      = 1'b1;
                alu_control   = 4'b1111;
                branch_access = 1'b1;
            end
            7'b1100111: begin //jalr
                alu_src0      = 1'b0;
                alu_src1      = 1'b0;
                mem_write     = 3'b000;
                mem_read      = 3'b000;
                unsign        = 1'b0;
                memtoreg      = 1'b0;
                jump          = 1'b1;
                regwrite      = 1'b1;
                alu_control   = 4'b1111;
                branch_access = 1'b1;
            end
            7'b1100011: begin //branch
                alu_src0      = 1'b0;
                alu_src1      = 1'b0;
                mem_write     = 3'b000;
                mem_read      = 3'b000;
                unsign        = 1'b0;
                memtoreg      = 1'b0;
                jump          = 1'b0;
                regwrite      = 1'b0;
                alu_control   = 4'b1111;
                branch_access = 1'b1;
            end
            7'b0000011: begin //load
                alu_src0      = 1'b0;
                alu_src1      = 1'b1;
                mem_write     = 3'b000;
                unsign        = 1'b0;
                memtoreg      = 1'b1;
                jump          = 1'b0;
                regwrite      = 1'b1;
                alu_control   = 4'b0010; //add
                branch_access = 1'b0;
                case (funct3) 
                    3'b000:  mem_read= 3'b011;     //lb                             
                    3'b001:  mem_read= 3'b010;    //lh
                    3'b010:  mem_read= 3'b001;   //lw
                    3'b100:  mem_read= 3'b111;  //lbu     
                    3'b101:  mem_read= 3'b110; //lhu      
                    default: mem_read= 3'b000;                                                                   
                    endcase
            end
            7'b0100011: begin //store
                alu_src0      = 1'b0; // 0-> REG[rs1], 1 -> PC
                alu_src1      = 1'b1; // 0 -> REG[rs2], 1 -> Imm
                if (funct3==3'b000) mem_write= 3'b011; else mem_write= funct3;
                mem_read      = 3'b000;
                unsign        = 1'b0;
                memtoreg      = 1'b0;
                jump          = 1'b0;
                regwrite      = 1'b0;
                alu_control   = 4'b0010;  //add
                branch_access = 1'b0;
            end
            7'b0010011: begin //I-format
                alu_src0      = 1'b0; // 0-> REG[rs1], 1 -> PC
                alu_src1      = 1'b1; // 0 -> REG[rs2], 1 -> Imm
                mem_write     = 3'b000;
                mem_read      = 3'b000;
                memtoreg      = 1'b0;
                jump          = 1'b0;
                regwrite      = 1'b1;
                branch_access = 1'b0;
                case (funct3) 
                    3'b000: begin //addi
                        unsign = 1'b0;
                        alu_control = 4'b0010; //add
                    end
                    3'b010: begin //slti
                        unsign = 1'b0;
                        alu_control = 4'b0100; //slt
                    end
                    3'b011: begin //sltiu
                        unsign = 1'b1;
                        alu_control = 4'b0100; //slt                       
                    end
                    3'b100: begin //xori
                        unsign = 1'b0;
                        alu_control = 4'b1010;  //xor                       
                    end
                    3'b110: begin //ori
                        unsign = 1'b0;
                        alu_control = 4'b0001;    //or                     
                    end
                    3'b111: begin //andi
                        unsign = 1'b0;
                        alu_control = 4'b0000;   //and                      
                    end
                    3'b001: begin //slli
                        unsign = 1'b0;
                        alu_control = 4'b0111; //sll
                    end
                    3'b101:  //sr
                        case (funct7) 
                        7'b0000000 :  begin //srli
                            unsign = 1'b0;
                            alu_control = 4'b1000;      //srl                   
                            end
                        7'b0100000 : begin //srai
                            unsign = 1'b0;
                            alu_control = 4'b1001; //srai
                            end
                        default: begin
                            unsign = 1'b0;
                            alu_control = 4'b1111;
                            end
                        endcase
                   default: begin
                            unsign = 1'b0;
                            alu_control = 4'b1111;
                            end 
                endcase
            end
            7'b0110011: begin //R-format
                alu_src0      = 1'b0;
                alu_src1      = 1'b0;
                mem_write     = 3'b000;
                mem_read      = 3'b000;
                memtoreg      = 1'b0;
                jump          = 1'b0;
                regwrite      = 1'b1;
                branch_access = 1'b0;
                case (funct3)
                    3'b000 : 
                        case (funct7)
                        7'b0000000: begin //add 
                            alu_control = 4'b0010;
                            unsign      = 1'b0;                        
                        end
                        7'b0100000: begin //sub
                            alu_control = 4'b0011;
                            unsign      = 1'b0;                        
                        end
                        default :  begin 
                            alu_control = 4'b1111;
                            unsign      = 1'b0;                        
                        end
                        endcase
                    3'b001 : begin //sll
                        alu_control = 4'b0111;
                        unsign      = 1'b0; 
                    end
                    3'b010 : begin //slt
                        alu_control = 4'b0100;
                        unsign      = 1'b0; 
                    end
                    3'b011 : begin //sltu
                        alu_control = 4'b0100;
                        unsign      = 1'b1; 
                    end
                    3'b100 : begin //xor
                        alu_control = 4'b1010;
                        unsign      = 1'b0; 
                    end
                    3'b101 : begin //sr
                        case (funct7)
                            7'b0000000: begin //srl
                                alu_control = 4'b1000;
                                unsign      = 1'b0;
                                end
                            7'b0100000: begin //sra
                                alu_control = 4'b1001;
                                unsign      = 1'b0;
                                end
                            default: begin
                                 alu_control = 4'b1111;
                                 unsign      = 1'b0;
                                end 
                        endcase
                    end
                    3'b110 : begin //or
                        alu_control = 4'b0001;
                        unsign      = 1'b0;
                    end
                    3'b111 : begin //and
                        alu_control = 4'b0000;
                        unsign      = 1'b0;
                    end
                default: begin
                    alu_control = 4'b1111;
                    unsign      = 1'b1;
                end
                endcase
            end
            default: begin 
                alu_src0      = 1'b0;
                alu_src1      = 1'b0;
                mem_write     = 3'b000;
                mem_read      = 3'b000;
                unsign        = 1'b0;
                memtoreg      = 1'b0;
                jump          = 1'b0;
                regwrite      = 1'b0;
                alu_control   = 4'b1111;
                branch_access = 1'b0;    
            end
            endcase
        end
     
     //***********************IMMIDIATE GENERATOR***********************\\  
     wire [11:0] imm ;
     //assign imm= IF_ins[31:20];
     reg [31:0] immOut;
     always @(*) 
        case (opcode) 
              7'b0110111: immOut = {{12{IF_ins[31]}}, IF_ins[31:12]};//lui
              7'b0010111: immOut = {{12{IF_ins[31]}}, IF_ins[31:12]};//auipc
              7'b1101111: immOut = {{12{IF_ins[31]}}, IF_ins[31], IF_ins[19:12], IF_ins[20], IF_ins[30:21]};//jal
              7'b1100111: immOut = {{20{IF_ins[31]}}, IF_ins[31:20]};//jalr
              7'b1100011: immOut = {{20{IF_ins[31]}}, IF_ins[31], IF_ins[7], IF_ins[30:25], IF_ins[11:8]}; //branch
              7'b0000011: immOut = {{20{IF_ins[31]}}, IF_ins[31:20]};//load
              7'b0100011: immOut = {{20{IF_ins[31]}}, IF_ins[31:25], IF_ins[11:7]};//store
              7'b0010011: immOut = {{20{IF_ins[31]}}, IF_ins[31:20]};//I-format
			  default: immOut = 32'd0;			  
        endcase
    
    //***********************REGISTER FILES***********************\\
     reg[31:0] regf_rdata1, regf_rdata2;
     reg[31:0] regf [31:0];
     always @(*) regf[0] = 32'd0;

     always @(*)
        if (WB_regwrite)  
             regf [WB_rd] = WB_wdata_regf;
     always @(*) begin
            regf_rdata1 = regf[rs1];
            regf_rdata2 = regf[rs2];
            end
    
    //***********************NEXT PC CALCULATOR***********************\\     
    assign pc_shift1 = IF_pc + (immOut<<1);
    //assign pc_addRs1 = IF_pc + regf_rdata1; //jalr
    reg[31:0] data_rs1;
    assign pc_addRs1 = immOut + data_rs1; //jalr
    //***********************BRANCH UNIT***********************\\  
    reg[4:0] ID_rd, EX_rd, WB_rd;
    reg[31:0]  EX_ALU_result, WB_data;
    reg[31:0] ID_pc4, EX_pc4;
    reg ID_jump, EX_jump, WB_jump;
    reg ID_memtoreg, EX_memtoreg;
    reg ID_regwrite, EX_regwrite;
    reg[2:0] ID_mem_read, EX_mem_read;
    reg taken, taken1;
    //always @(rs1, rs2, ID_rd, EX_rd, WB_rd, memtoreg, jump, regwrite, mem_read, branch_access, funct3, funct7) begin
    always @(*) begin
        if (branch_access==1'b0) begin // khong nhay
            pc_src1=1'b0; 
            pc_src2=1'b0;
        end
        else if (jump==1'b1) begin //nhay khong can dieu kien => jal or jalr
            pc_src1= 1'b1; 
            if (opcode==7'b1100111) begin
                     pc_src2=1;
                     //if (rs1==ID_rd||rs1==MEM_rd||rs1==WB_rd) //jalr
                     if (rs1==ID_rd) //jalr
                        if (ID_jump==1'b1) data_rs1= ID_pc4;
                        else data_rs1= ALU_result;
                      else if (rs1==MEM_rd) 
                                if (MEM_jump==1'b1) data_rs1= MEM_pc4;
                                else data_rs1= MEM_ALU_result;
                           else if (rs1==WB_rd) data_rs1= WB_wdata_regf;
                                else data_rs1= regf_rdata1;
                end else begin pc_src2=1'b0; data_rs1= regf_rdata1; end
        end
            else begin // branch_access==1 but jump!=1 => beq instructions
                 pc_src2=1'b0;
                 taken= ((rs1!==ID_rd)&&(rs2!==ID_rd)&&(rs1!==MEM_rd)&&(rs2!==MEM_rd)&&(rs1!==WB_rd)&&(rs2!==WB_rd));
                 if ((rs1!==ID_rd)&&(rs2!==ID_rd)&&(rs1!==MEM_rd)&&(rs2!==MEM_rd)&&(rs1!==WB_rd)&&(rs2!==WB_rd)) begin
                    case (funct3)
                                3'b000: pc_src1= (regf_rdata1==regf_rdata2);//beq
                                3'b001: pc_src1= (regf_rdata1!=regf_rdata2);//bne
                                3'b100:  if (regf_rdata1 && !regf_rdata2) pc_src1 = 1'b1; //op1 am op2 duong => op1 < op2
                                         else if (!regf_rdata1 && regf_rdata2)pc_src1 = 1'b0; //op1 duong op2 am => op1 > op2
                                         else pc_src1 = (regf_rdata1 < regf_rdata2) ? 1'b1 : 1'b0; //blt
                                3'b101:  if (regf_rdata1 && !regf_rdata2) pc_src1 = 1'b0; //op1 am op2 duong => op1 < op2
                                         else if (!regf_rdata1 && regf_rdata2)pc_src1 = 1'b1; //op1 duong op2 am => op1 >  op2
                                         else pc_src1 = (regf_rdata1 >= regf_rdata2) ? 1'b1 : 1'b0; //bge
                                3'b110:  pc_src1 = (regf_rdata1 < regf_rdata2) ? 1'b1 : 1'b0; // bltu
                                3'b111:  pc_src1 = (regf_rdata1 >= regf_rdata2) ? 1'b1 : 1'b0; //bgeu
                            default: pc_src1 = 1'b0;
                    endcase
                 end        
                 else
                 if (rs1==ID_rd||rs2==ID_rd) begin // xung dot tai giai doan EX
                 //if (ID_jump==1'b0) taken= 1'b1;
                 if (ID_jump==1'b1) begin // jal jalr -> rd=Pc+4 lenh truoc lenh beq la jal hoac jalr -> gia tri can la pc+4
                        
                        if (rs1==ID_rd) // neu rs1 trung voi rd tai giai doan EX => so sanh REG[rs2] voi ID_pc+4
                            case (funct3)
                                3'b000: pc_src1= (ID_pc4==regf_rdata2);//beq
                                3'b001: pc_src1= (ID_pc4!=regf_rdata2);//bne
                                3'b100:  if (ID_pc4 && !regf_rdata2) pc_src1 = 1'b1; //op1 am op2 duong => op1 < op2
                                         else if (!ID_pc4 && regf_rdata2)pc_src1 = 1'b0; //op1 duong op2 am => op1 > op2
                                         else pc_src1 = (ID_pc4 < regf_rdata2) ? 1'b1 : 1'b0; //blt
                                3'b101:  if (ID_pc4 && !regf_rdata2) pc_src1 = 1'b0; //op1 am op2 duong => op1 < op2
                                         else if (!ID_pc4 && regf_rdata2)pc_src1 = 1'b1; //op1 duong op2 am => op1 >  op2
                                         else pc_src1 = (ID_pc4 >= regf_rdata2) ? 1'b1 : 1'b0; //bge
                                3'b110:  pc_src1 = (ID_pc4 < regf_rdata2) ? 1'b1 : 1'b0; // bltu
                                3'b111:  pc_src1 = (ID_pc4 >= regf_rdata2) ? 1'b1 : 1'b0; //bgeu
                            default: pc_src1 = 1'b0;
                            endcase
                        else if (rs2==ID_rd) begin // neu rs2 trung voi rd tai giai doan EX => so sanh REG[rs1] voi ID_pc+
                            
                            case (funct3)
                                3'b000: pc_src1= (ID_pc4==regf_rdata1);//beq
                                3'b001: pc_src1= (ID_pc4!=regf_rdata1);//bne
                                3'b100:  if (ID_pc4 && !regf_rdata1) pc_src1 = 1'b1; //op1 am op2 duong => op1 < op2
                                         else if (!ID_pc4 && regf_rdata1)pc_src1 = 1'b0; //op1 duong op2 am
                                         else pc_src1 = (ID_pc4 < regf_rdata1) ? 1'b1 : 1'b0; //blt
                                3'b101:  if (ID_pc4 && !regf_rdata1) pc_src1 = 1'b0; //op1 am op2 duong => op1 < op2
                                         else if (!ID_pc4 && regf_rdata1) pc_src1 = 1'b1; //op1 duong op2 am => op1 >  op2
                                         else pc_src1 = (ID_pc4 >= regf_rdata1) ? 1'b1 : 1'b0; //bge
                                3'b110:  pc_src1 = (ID_pc4 < regf_rdata1) ? 1'b1 : 1'b0; // bltu
                                3'b111:  pc_src1 = (ID_pc4 >= regf_rdata1) ? 1'b1 : 1'b0; //bgeu
                            default: pc_src1 = 1'b0;
                            endcase end else pc_src1 = 1'b0;
                            
                 end else begin //xung dot ALU_result -> gia tri can la ALU_result
                        
                        if (rs1==ID_rd) begin // neu rs1 trung voi rd tai giai doan EX => so sanh REG[rs2] voi ALU_result
                            //if (funct3==3'b000&&ALU_result==regf_rdata2&&ID_jump==1'b0) taken= 1'b1;
                            taken= 1'b1;
                            case (funct3)
                                3'b000: pc_src1= (ALU_result==regf_rdata2);//beq 
                                3'b001: pc_src1= (ALU_result!=regf_rdata2);//bne
                                3'b100:  if (ALU_result && !regf_rdata2) pc_src1 = 1'b1; //op1 am op2 duong => op1 < op2
                                         else if (!ALU_result && regf_rdata2) pc_src1 = 1'b0; //op1 duong op2 am
                                         else pc_src1 = (ALU_result < regf_rdata2) ? 1'b1 : 1'b0; //blt
                                3'b101:  if (ALU_result && !regf_rdata2) pc_src1 = 1'b0; //op1 am op2 duong => op1 < op2
                                         else if (!ALU_result && regf_rdata2) pc_src1 = 1'b1; //op1 duong op2 am => op1 >  op2
                                         else pc_src1 = (ALU_result >= regf_rdata2) ? 1'b1 : 1'b0; //bge
                                3'b110:  pc_src1 = (ALU_result < regf_rdata2) ? 1'b1 : 1'b0; // bltu
                                3'b111:  pc_src1 = (ALU_result >= regf_rdata2) ? 1'b1 : 1'b0; //bgeu
                            default: pc_src1 = 1'b0;
                            endcase
                            end
                            else if (rs2==ID_rd) // neu rs2 trung voi rd tai giai doan EX => so sanh REG[rs1] voi ALU_result
                                    case (funct3)
                                        3'b000: pc_src1= (ALU_result==regf_rdata1);//beq
                                        3'b001: pc_src1= (ALU_result!=regf_rdata1);//bne
                                        3'b100:  if (ALU_result && !regf_rdata1) pc_src1 = 1'b1; //op1 am op2 duong => op1 < op2
                                                 else if (!ALU_result && regf_rdata1) pc_src1 = 1'b0; //op1 duong op2 am
                                                 else pc_src1 = (ALU_result < regf_rdata1) ? 1'b1 : 1'b0; //blt
                                        3'b101:  if (ALU_result && !regf_rdata1) pc_src1 = 1'b0; //op1 am op2 duong => op1 < op2
                                                 else if (!ALU_result && regf_rdata1) pc_src1 = 1'b1; //op1 duong op2 am => op1 >  op2
                                                 else pc_src1 = (ALU_result >= regf_rdata1) ? 1'b1 : 1'b0; //bge
                                        3'b110:  pc_src1 = (ALU_result < regf_rdata1) ? 1'b1 : 1'b0; // bltu
                                        3'b111:  pc_src1 = (ALU_result >= regf_rdata1) ? 1'b1 : 1'b0; //bgeu
                                    default: pc_src1 = 1'b0;
                                    endcase else pc_src1= 1'b0;
                                     
                                    end
                 end
            else if (rs1==MEM_rd||rs2==MEM_rd) begin // xung dot tai giai doan MEM
                if (MEM_jump==1) begin // jal jalr -> rd=Pc+4 lenh truoc lenh beq la jal hoac jalr -> gia tri can la pc+4
                        if (rs1==MEM_rd) begin // rs1==MEM_rd
                            case (funct3)
                                3'b000: pc_src1= (MEM_pc4==regf_rdata2);//beq
                                3'b001: pc_src1= (MEM_pc4!=regf_rdata2);//bne
                                3'b100:  if (MEM_pc4 && !regf_rdata2) pc_src1 = 1'b1; //op1 am op2 duong => op1 < op2
                                         else if (!MEM_pc4 && regf_rdata2) pc_src1 = 1'b0; //op1 duong op2 am => op1 > op2 always
                                         else pc_src1 = (MEM_pc4 < regf_rdata2) ? 1'b1 : 1'b0; //blt
                                3'b101:  if (MEM_pc4 && !regf_rdata2) pc_src1 = 1'b0; //op1 am op2 duong => op1 < op2
                                         else if (!MEM_pc4 && regf_rdata2) pc_src1 = 1'b1; //op1 duong op2 am => op1 >  op2
                                         else pc_src1 = (MEM_pc4 >= regf_rdata2) ? 1'b1 : 1'b0; //bge
                                3'b110:  pc_src1 = (MEM_pc4 < regf_rdata2) ? 1'b1 : 1'b0; // bltu
                                3'b111:  pc_src1 = (MEM_pc4 >= regf_rdata2) ? 1'b1 : 1'b0; //bgeu
                            default: pc_src1 = 1'b0;
                            endcase
                         end else if (rs2==MEM_rd) begin // rs2==MEM_rd
                             case (funct3)
                                3'b000: pc_src1= (MEM_pc4==regf_rdata1);//beq
                                3'b001: pc_src1= (MEM_pc4!=regf_rdata1);//bne
                                3'b100:  if (MEM_pc4 && !regf_rdata1) pc_src1 = 1'b1; //op1 am op2 duong => op1 < op2
                                         else if (!MEM_pc4 && regf_rdata1)pc_src1 = 1'b0; //op1 duong op2 am
                                         else pc_src1 = (MEM_pc4 < regf_rdata1) ? 1'b1 : 1'b0; //blt
                                3'b101:  if (MEM_pc4 && !regf_rdata1) pc_src1 = 1'b0; //op1 am op2 duong => op1 < op2
                                         else if (!MEM_pc4 && regf_rdata1)pc_src1 = 1'b1; //op1 duong op2 am => op1 >  op2
                                         else pc_src1 = (MEM_pc4 >= regf_rdata1) ? 1'b1 : 1'b0; //bge
                                3'b110:  pc_src1 = (MEM_pc4 < regf_rdata1) ? 1'b1 : 1'b0; // bltu
                                3'b111:  pc_src1 = (MEM_pc4 >= regf_rdata1) ? 1'b1 : 1'b0; //bgeu
                            default: pc_src1 = 1'b0;
                            endcase  
                         end else pc_src1 = 1'b0;
                 end else begin //xung dot ALU_result
                        if (rs1==MEM_rd) begin // rs1 == MEM_rd
                            case (funct3)
                                3'b000: pc_src1= (MEM_ALU_result==regf_rdata2);//beq
                                3'b001: pc_src1= (MEM_ALU_result!=regf_rdata2);//bne
                                3'b100:  if (MEM_ALU_result && !regf_rdata2) pc_src1 = 1'b1; //op1 am op2 duong => op1 < op2
                                         else if (!MEM_ALU_result && regf_rdata2)pc_src1 = 1'b0; //op1 duong op2 am => op1 >op2
                                         else pc_src1 = (MEM_ALU_result < regf_rdata2) ? 1'b1 : 1'b0; //blt
                                3'b101:  if (MEM_ALU_result && !regf_rdata2) pc_src1 = 1'b0; //op1 am op2 duong => op1 < op2
                                         else if (!MEM_ALU_result && regf_rdata2) pc_src1 = 1'b1; //op1 duong op2 am => op1 >  op2
                                         else pc_src1 = (MEM_ALU_result >= regf_rdata2) ? 1'b1 : 1'b0; //bge
                                3'b110:  pc_src1 = (MEM_ALU_result < regf_rdata2) ? 1'b1 : 1'b0; // bltu
                                3'b111:  pc_src1 = (MEM_ALU_result >= regf_rdata2) ? 1'b1 : 1'b0; //bgeu
                            default: pc_src1 = 1'b0;
                            endcase
                             end else if (rs2==MEM_rd) begin
                                     case (funct3)
                                        3'b000: pc_src1= (MEM_ALU_result==regf_rdata1);//beq
                                        3'b001: pc_src1= (MEM_ALU_result!=regf_rdata1);//bne
                                        3'b100:  if (MEM_ALU_result && !regf_rdata1) pc_src1 = 1'b1; //op1 am op2 duong => op1 < op2
                                                 else if (!MEM_ALU_result && regf_rdata1)pc_src1 = 1'b0; //op1 duong op2 am
                                                 else pc_src1 = (MEM_ALU_result < regf_rdata1) ? 1'b1 : 1'b0; //blt
                                        3'b101:  if (MEM_ALU_result && !regf_rdata1) pc_src1 = 1'b0; //op1 am op2 duong => op1 < op2
                                                 else if (!MEM_ALU_result && regf_rdata1)pc_src1 = 1'b1; //op1 duong op2 am => op1 >  op2
                                                 else pc_src1 = (MEM_ALU_result >= regf_rdata1) ? 1'b1 : 1'b0; //bge
                                        3'b110:  pc_src1 = (MEM_ALU_result < regf_rdata1) ? 1'b1 : 1'b0; // bltu
                                        3'b111:  pc_src1 = (MEM_ALU_result >= regf_rdata1) ? 1'b1 : 1'b0; //bgeu
                                    default: pc_src1 = 1'b0;
                                    endcase
                                     end
                 end //wdata_regf
                 end
            else if (rs1==WB_rd||rs2==WB_rd) begin // xung dot tai giai doan WB
                 if  (rs1==WB_rd) begin // rs1==WB_rd
                             case (funct3)
                                3'b000: pc_src1= (WB_wdata_regf==regf_rdata2);//beq
                                3'b001: pc_src1= (WB_wdata_regf!=regf_rdata2);//bne
                                3'b100:  if (WB_wdata_regf && !regf_rdata2) pc_src1 = 1'b1; //op1 am op2 duong => op1 < op2
                                         else if (!WB_wdata_regf && regf_rdata2) pc_src1 = 1'b0; //op1 duong op2 am
                                         else pc_src1 = (WB_wdata_regf < regf_rdata2) ? 1'b1 : 1'b0; //blt
                                3'b101:  if (WB_wdata_regf && !regf_rdata2) pc_src1 = 1'b0; //op1 am op2 duong => op1 < op2
                                         else if (!WB_wdata_regf && regf_rdata2) pc_src1 = 1'b1; //op1 duong op2 am => op1 >  op2
                                         else pc_src1 = (WB_wdata_regf >= regf_rdata2) ? 1'b1 : 1'b0; //bge
                                3'b110:  pc_src1 = (WB_wdata_regf < regf_rdata2) ? 1'b1 : 1'b0; // bltu
                                3'b111:  pc_src1 = (WB_wdata_regf >= regf_rdata2) ? 1'b1 : 1'b0; //bgeu
                            default: pc_src1 = 1'b0;
                            endcase
                         end else if (rs2==WB_rd) begin
                             case (funct3)
                                3'b000: pc_src1= (WB_wdata_regf==regf_rdata1);//beq
                                3'b001: pc_src1= (WB_wdata_regf!=regf_rdata1);//bne
                                3'b100:  if (WB_wdata_regf && !regf_rdata1) pc_src1 = 1'b1; //op1 am op2 duong => op1 < op2
                                         else if (!WB_wdata_regf && regf_rdata1) pc_src1 = 1'b0; //op1 duong op2 am
                                         else pc_src1 = (WB_wdata_regf < regf_rdata1) ? 1'b1 : 1'b0; //blt
                                3'b101:  if (WB_wdata_regf && !regf_rdata1) pc_src1 = 1'b0; //op1 am op2 duong => op1 < op2
                                         else if (!WB_wdata_regf && regf_rdata1) pc_src1 = 1'b1; //op1 duong op2 am => op1 >  op2
                                         else pc_src1 = (WB_wdata_regf >= regf_rdata1) ? 1'b1 : 1'b0; //bge
                                3'b110:  pc_src1 = (WB_wdata_regf < regf_rdata1) ? 1'b1 : 1'b0; // bltu
                                3'b111:  pc_src1 = (WB_wdata_regf >= regf_rdata1) ? 1'b1 : 1'b0; //bgeu
                            default: pc_src1 = 1'b0;
                            endcase
                         end else pc_src1= 1'b1;
            end
                 end  
end


    //***********************HAZARD DETECTION UNIT***********************\\
    wire MemRead;
    
    assign MemRead= (ID_MemRead!=3'b000);
    always @(*) begin
        if (MemRead==1 && (rs1==ID_rd||rs2==ID_rd)) rst =1'b1;
        else rst=1'b0;
    end
    
    //***********************ID REG***********************\\
    reg ID_RegWrite, ID_jump, ID_MemtoReg;
    reg[2:0] ID_MemWrite, ID_MemRead;
    reg ID_unsigned;
    reg ID_AluSrc0, ID_AluSrc1;
    reg[3:0]  ID_AluControl;
    reg[31:0] ID_pc4;
    reg[31:0] ID_pc;
    reg[31:0] ID_ReadData1;
    reg[31:0] ID_ReadData2;
    reg[31:0] ID_Imm_out;
    reg[4:0]  ID_rs1, ID_rs2, ID_rd;
    
    always @(posedge clk) begin
        ID_RegWrite <= regwrite;
        ID_jump     <= jump;
        ID_MemtoReg <= memtoreg;
        ID_MemWrite <= mem_write;
        ID_MemRead  <= mem_read;
        ID_unsigned <= unsign;
        ID_AluSrc0  <= alu_src0;
        ID_AluSrc1  <= alu_src1;
        ID_AluControl <= alu_control;
        ID_pc4        <= IF_pc_incr4;
        ID_pc         <= IF_pc;
        ID_ReadData1  <= regf_rdata1;
        ID_ReadData2  <= regf_rdata2;
        ID_Imm_out    <= immOut;
        ID_rs1        <= rs1;
        ID_rs2        <= rs2;
        ID_rd         <= rd;
    end
    ////////////////////////////////////////////***EX STAGE***\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    //***********************ALU***********************\\
    reg  [31:0] ALU_result; 
    reg [31:0] Op1, Op2;
    //always @(ID_AluControl, ID_unsigned) begin
    always @(*) begin
        case (ID_AluControl) 
            4'b0000: ALU_result= Op1&Op2; //and
            4'b0001: ALU_result= Op1|Op2; //or
            4'b0010: ALU_result= Op1+Op2; //add
            4'b0011: ALU_result= Op1-Op2; //sub
            4'b0100: if (ID_unsigned==1'b0) // slt
                        if (Op1[31] && !Op2[31]) ALU_result = 32'd1; //op1 am op2 duong
                        else if (!Op1[31] && Op2[31])ALU_result = 32'd0; //op1 duong op2 am
                             else  ALU_result = (Op1 < Op2) ? 32'd1 : 32'd0;
                     else   ALU_result = (Op1 < Op2) ? 32'd1 : 32'd0; //sltu
            4'b0101: ALU_result= Op2 <<12; // lui
            4'b0110: ALU_result= Op1 + (Op2 <<12); //auipc
            4'b0111: ALU_result= Op1 << (Op2&32'b00000000000000000000000000011111); //sll  }
            4'b1000: ALU_result= Op1 >> (Op2&32'b00000000000000000000000000011111); //srl  } => do chi shift 5 bit 
            4'b1001: ALU_result= Op1 >>>(Op2&32'b00000000000000000000000000011111); //srai }
            4'b1010: ALU_result= Op1 ^ Op2; //srai
            default: ALU_result= 32'dz;
        endcase
    end
    //***********************Forwarding Unit***********************\\
    reg[1:0] fwdA, fwdB;
    //always@(ID_rs1, ID_rs2, EX_rd, WB_rd, EX_regwrite, WB_regwrite)
    always @(*) begin
        if (MEM_RegWrite&&(MEM_rd != 0)&&(MEM_rd == ID_rs1)) // hazard EX-MEM
            if (ID_jump) fwdA = 2'b10; // Pc4 => REG[rs1] 
            else fwdA= 2'b01; //ALU_result => REG[rs1]
        else if (WB_regwrite &&(WB_rd != 0)&&(WB_rd == ID_rs1) && // data write back
                (!(MEM_RegWrite &&(MEM_rd != 0)&&(MEM_rd == ID_rs1)))) fwdA = 2'b11;  
             else fwdA = 2'b00; // non hazard;
          
        if (MEM_RegWrite&&(MEM_rd != 0)&&(MEM_rd == ID_rs2)) // hazard EX-MEM
            if (ID_jump) fwdB = 2'b10; // Pc4
            else fwdB= 2'b01; //ALU_result
        else if (WB_regwrite &&(WB_rd != 0)&&(WB_rd == ID_rs2) && // data write back
                (!(MEM_RegWrite &&(MEM_rd != 0)&&(MEM_rd == ID_rs2)))) fwdB = 2'b11;  
             else fwdB = 2'b00; // non hazard;
    end
    
    wire[31:0] temp_op1, temp_op2;
    mux4to1 mux2(
    .In0(ID_ReadData1),
    .In1(MEM_ALU_result),
    .In2(MEM_pc4),
    .In3(WB_wdata_regf),
    .Sel(fwdA),
    .Out(temp_op1)
    );
    mux4to1 mux3(
    .In0(ID_ReadData2),
    .In1(MEM_ALU_result),
    .In2(MEM_pc4),
    .In3(WB_wdata_regf),
    .Sel(fwdB),
    .Out(temp_op2)
    );
    
    wire [31:0] tmp_Op1;
    mux2to1 mux4 (
    .In0(temp_op1),
    .In1(ID_pc),
    .Sel(ID_AluSrc0),
    .Out(tmp_Op1)
    );
    always @ (*) Op1 = tmp_Op1;
    
    wire [31:0] tmp_Op2;
     mux2to1 mux5 (
    .In0(temp_op2),
    .In1(ID_Imm_out),
    .Sel(ID_AluSrc1),
    .Out(tmp_Op2)
    );
    always @ (*) Op2 = tmp_Op2;
    //***********************EX REG***********************\\
    reg MEM_RegWrite, MEM_jump, MEM_MemtoReg;
    reg [2:0] MEM_MemWrite, MEM_MemRead, MEM_unsigned;
    reg [31:0] MEM_pc4, MEM_ALU_result, MEM_ReadData2;
    reg [4:0]  MEM_rd;
    always @(posedge clk) begin
        MEM_RegWrite    <= ID_RegWrite;
        MEM_jump        <= ID_jump;
        MEM_MemtoReg    <= ID_MemtoReg;
        MEM_MemWrite    <= ID_MemWrite;
        MEM_MemRead     <= ID_MemRead;
        MEM_unsigned    <= ID_unsigned;
        MEM_pc4         <= ID_pc4;
        MEM_ALU_result  <= ALU_result;
        MEM_ReadData2   <= temp_op2;
        MEM_rd          <= ID_rd;
    end
    ////////////////////////////////////////////***MEM STAGE***\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\  
    
    reg [31:0] temp_WB_dmem_rdata;
    wire wData, rData;
    //***********************Data Memory***********************\\
    assign wData=  (MEM_MemWrite!=3'b000);
    assign rData=  (MEM_MemRead !=3'b000);
    assign raddr_dmem = MEM_ALU_result;
    assign waddr_dmem = MEM_ALU_result;
    //assign wdata_dmem = MEM_ReadData2;
    //always @(MEM_MemWrite) begin
    always @(*) begin
        case (MEM_MemWrite)
            3'b011: wdata_dmem= {{24{1'b0}},MEM_ReadData2[7:0]}; // sb     
            3'b001: wdata_dmem= {{16{1'b0}},MEM_ReadData2[15:0]}; // sh
            3'b010: wdata_dmem= MEM_ReadData2; //sw
        default: wdata_dmem= 32'd0;
        endcase
    end
    assign write_dmem = wData;
    assign read_dmem  = rData;
   //***********************Unsigned Unit***********************\\
    always @ (*) begin
        case (MEM_MemRead)
            3'b001: temp_WB_dmem_rdata= dmem_rdata; //lw
            3'b010: temp_WB_dmem_rdata= {{16{dmem_rdata[15]}},dmem_rdata[15:0]}; //lh
            3'b011: temp_WB_dmem_rdata= {{24{dmem_rdata[7]}},dmem_rdata[7:0]}; //lb
            3'b110: temp_WB_dmem_rdata= {{16{1'b0}},dmem_rdata[15:0]}; //lhu
            3'b111: temp_WB_dmem_rdata= {{24{1'b0}},dmem_rdata[7:0]};//lbu
            default: temp_WB_dmem_rdata= 32'd0;
        endcase
    end
//***********************MEM REG***********************\\ 
    reg [31:0] WB_dmem_rdata, WB_alu_result, WB_pc4, WB_wdata_regf;
    reg [4:0]  WB_rd;
    reg WB_mem_to_reg, WB_jump;
    reg WB_regwrite;
    always @(posedge clk) begin
        WB_dmem_rdata <= temp_WB_dmem_rdata;
        WB_alu_result <= MEM_ALU_result;
        WB_rd         <= MEM_rd;
        WB_mem_to_reg <= MEM_MemtoReg;
        WB_jump       <= MEM_jump;
        WB_pc4        <= MEM_pc4;
        WB_regwrite   <= MEM_RegWrite;
    end
////////////////////////////////////////////***WRITE BACK STAGE***\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\    
     wire[31:0] wb_tmp;
     
     mux2to1 mux6 (
    .In0(WB_alu_result),
    .In1(WB_dmem_rdata),
    .Sel(WB_mem_to_reg),
    .Out(wb_tmp)
    );   
    
    wire[31:0] tmp_WB_wdata_regf;
     mux2to1 mux7 (
    .In0(wb_tmp),
    .In1(WB_pc4),
    .Sel(WB_jump),
    .Out(tmp_WB_wdata_regf)
    ); 
    
    always @(*)  WB_wdata_regf= tmp_WB_wdata_regf;
    
endmodule
// output [31:0] raddr_dmem,//data memory
//    output [31:0] waddr_dmem,//data memory
//    output [31:0] wdata_dmem,//data memory
//    output write_dmem,//data memory
//    output read_dmem//data memory
//dmem_rdata



















