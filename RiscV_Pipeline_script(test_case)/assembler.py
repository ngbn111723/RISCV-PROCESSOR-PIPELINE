address = {}
local=0
register= {
    'x0'    :  '00000',         'zero'  :   '00000',
    'x1'    :  '00001',         'ra'    :   '00001',
    'x2'    :  '00010',         'sp'    :   '00010',
    'x3'    :  '00011',         'gp'    :   '00011',
    'x4'    :  '00100',         'tp'    :   '00100',
    'x5'    :  '00101',         't0'    :   '00101',
    'x6'    :  '00110',         't1'    :   '00110',
    'x7'    :  '00111',         't2'    :   '00111',
    'x8'    :  '01000',         's0'    :   '01000',     'fp'    : '01000',
    'x9'    :  '01001',         's1'    :   '01001',
    'x10'   :  '01010',         'a0'    :   '01010',
    'x11'   :  '01011',         'a1'    :   '01011',
    'x12'   :  '01100',         'a2'    :   '01100',
    'x13'   :  '01101',         'a3'    :   '01101',
    'x14'   :  '01110',         'a4'    :   '01110',
    'x15'   :  '01111',         'a5'    :   '01111',
    'x16'   :  '10000',         'a6'    :   '10000',
    'x17'   :  '10001',         'a7'    :   '10001',
    'x18'   :  '10010',         's2'    :   '10010',
    'x19'   :  '10011',         's3'    :   '10011',
    'x20'   :  '10100',         's4'    :   '10100',
    'x21'   :  '10101',         's5'    :   '10101',
    'x22'   :  '10110',         's6'    :   '10110',
    'x23'   :  '10111',         's7'    :   '10111',
    'x24'   :  '11000',         's8'    :   '11000', 
    'x25'   :  '11001',         's9'    :   '11001',
    'x26'   :  '11010',         's10'   :   '11010',
    'x27'   :  '11011',         's11'   :   '11011',
    'x28'   :  '11100',         't3'    :   '11100',
    'x29'   :  '11101',         't4'    :   '11101',
    'x30'   :  '11110',         't5'    :   '11110',
    'x31'   :  '11111',         't6'    :   '11111'
}
FMT= {
    'lb'        : 'I',    'auipc' : 'U',    'addw'  : 'R',    'ecall' :   'I',
    'lh'        : 'I',    'addiw' : 'I' ,   'subw'  : 'R',    'ebreak':   'I',
    'lw'        : 'I',    'slliw' : 'I',    'sllw'  : 'R',    'CSRRW' :   'I',
    'ld'        : 'I',    'srliw' : 'I',    'srlw'  : 'R',    'CSRRC' :   'I',
    'lbu'       : 'I',    'sraiw' : 'I',    'sraw'  : 'R',    'CSRRWI':   'I',
    'lhu'       : 'I',                                        'CSRRSI':   'I',
    'lwu'       : 'I',    'sb'    : 'S',    'beq'   : 'SB',   'CSRRCI':   'I',
                          'sh'    : 'S',    'bne'   : 'SB',
    'fence'     : 'I',    'sw'    : 'S',    'blt'   : 'SB',
    'fence.i'   : 'I',    'sd'    : 'S',    'bge'   : 'SB',
                                            'bltu'  : 'SB',
    'addi'      : 'I',    'add'   : 'R',    'bgeu'  : 'SB',
    'slli'      : 'I',    'sub'   : 'R',        
    'slti'      : 'I',    'sll'   : 'R',    'jalr'  : 'I',
    'sltiu'     : 'I',    'slt'   : 'R',    'jal'   : 'UJ',    
    'xori'      : 'I',    'sltu'  : 'R',    
    'srli'      : 'I',    'xor'   : 'R',    
    'srai'      : 'I',    'srl'   : 'R',
    'ori'       : 'I',    'sra'   : 'R',
    'andi'      : 'I',    'or'    : 'R',
    'lui'       : 'U',    'and'   : 'R', 
}
OPCODE= {
    'lb'        : '0000011',    'auipc' : '0010111',    'addw'  : '0111011',    'ecall' :   '1110011',
    'lh'        : '0000011',    'addiw' : '0011011',    'subw'  : '0111011',    'ebreak':   '1110011',
    'lw'        : '0000011',    'slliw' : '0011011',    'sllw'  : '0111011',    'CSRRW' :   '1110011',
    'ld'        : '0000011',    'srliw' : '0011011',    'srlw'  : '0111011',    'CSRRC' :   '1110011',
    'lbu'       : '0000011',    'sraiw' : '0011011',    'sraw'  : '0111011',    'CSRRWI':   '1110011',
    'lhu'       : '0000011',                                                    'CSRRSI':   '1110011',
    'lwu'       : '0000011',    'sb'    : '0100011',    'beq'   : '1100011',    'CSRRCI':   '1110011',
                                'sh'    : '0100011',    'bne'   : '1100011',
    'fence'     : '0001111',    'sw'    : '0100011',    'blt'   : '1100011',
    'fence.i'   : '0001111',    'sd'    : '0100011',    'bge'   : '1100011',
                                                        'bltu'  : '1100011',
    'addi'      : '0010011',    'add'   : '0110011',    'bgeu'  : '1100011',
    'slli'      : '0010011',    'sub'   : '0110011',        
    'slti'      : '0010011',    'sll'   : '0110011',    'jalr'  : '1100111',
    'sltiu'     : '0010011',    'slt'   : '0110011',    'jal'   : '1101111',
    'xori'      : '0010011',    'sltu'  : '0110011',    
    'srli'      : '0010011',    'xor'   : '0110011',    
    'srai'      : '0010011',    'srl'   : '0110011',
    'ori'       : '0010011',    'sra'   : '0110011',
    'andi'      : '0010011',    'or'    : '0110011',
    'lui'       : '0110111',    'and'   : '0110011', 
}

FUNCT3= {
    'lb'        : '000',                            'addw'  : '000',    'ecall' :   '000',
    'lh'        : '001',    'addiw' : '000',        'subw'  : '000',    'ebreak':   '000',
    'lw'        : '010',    'slliw' : '001',        'sllw'  : '001',    'CSRRW' :   '001',
    'ld'        : '011',    'srliw' : '101',        'srlw'  : '101',    'CSRRC' :   '010',
    'lbu'       : '100',    'sraiw' : '101',        'sraw'  : '101',    'CSRRWI':   '101',
    'lhu'       : '101',                                                'CSRRSI':   '110',
    'lwu'       : '110',    'sb'    : '000',        'beq'   : '000',    'CSRRCI':   '111',
                            'sh'    : '001',        'bne'   : '001',
    'fence'     : '000',    'sw'    : '010',        'blt'   : '100',
    'fence.i'   : '001',    'sd'    : '011',        'bge'   : '101',
                                                    'bltu'  : '110',
    'addi'      : '000',    'add'   : '000',        'bgeu'  : '111',
    'slli'      : '001',    'sub'   : '000',        
    'slti'      : '010',    'sll'   : '001',        'jalr'  : '000',
    'sltiu'     : '011',    'slt'   : '010',    
    'xori'      : '100',    'sltu'  : '011',    
    'srli'      : '101',    'xor'   : '100',    
    'srai'      : '101',    'srl'   : '101',
    'ori'       : '110',    'sra'   : '101',
    'andi'      : '111',    'or'    : '110',
                            'and'   : '111', 
}

FUNCT7 ={
    'addw'  : '0000000',    'ecall' :   '000000000000',
    'subw'  : '0100000',    'ebreak':   '000000000001',
    'slliw' : '0000000',    'sllw'  :   '000000000000',    
    'srliw' : '0000000',    'srlw'  :   '0000000',   
    'sraiw' : '0100000',    'sraw'  :   '0100000',    
                                                                                  
    'add'   : '0000000',    
    'slli'  : '0000000',    'sub'   : '0100000',        
    'sll'   : '0000000',   
    'slt'   : '0000000',    
    'sltu'  : '0000000',    
    'srli'  : '0000000',    'xor'   : '0000000',    
    'srai'  : '0100000',    'srl'   : '0000000',
    'sra'   : '0100000',
    'or'    : '0000000',
    'and'   : '0000000', 
}
def handler_string (string) :
   
    if string.find("//") != -1 :
        string = string [0:string.find("//")]
    if string.find("#") != -1 :
        string = string [0:string.find("#")]
    string = string.replace('(', ' ', 100)
    string = string.replace(')', ' ', 100)
    string = string.replace(',', ' ', 100)
    string = string.strip()

    return string

def convert_hextodec (string) :
    string =string[2:]
    string= string.upper()
    temp =""
    for i in range (len(string)) :
        if string[i] == '0' :
            temp+='0000'
        if string[i] == '1' :
            temp+='0001'
        if string[i] == '2' :
            temp+='0010'
        if string[i] == '3' :
            temp+='0011'
        if string[i] == '4' :
            temp+='0100'
        if string[i] == '5' :
            temp+='0101'
        if string[i] == '6' :
            temp+='0110'
        if string[i] == '7' :
            temp+='0111'
        if string[i] == '8' :
            temp+='1000'
        if string[i] == '9' :
            temp+='1001'
        if string[i] == 'A' :
            temp+='1010'
        if string[i] == 'B' :
            temp+='1011'
        if string[i] == 'C' :
            temp+='1100'
        if string[i] == 'D' :
            temp+='1101'
        if string[i] == 'E' :
            temp+='1110'
        if string[i] == 'F' :
            temp+='1111'
    s=0
    temp = temp [::-1]
    for i in range (len(temp)) :
        if temp [i] =='1':
            s+= 2**i
    return s

def RType (string) :
    mlist = string.split()
    opcode = OPCODE [mlist[0]]
    funct3 = FUNCT3 [mlist[0]]
    funct7 = FUNCT7 [mlist[0]]
    rd = register [mlist[1]]
    rs1  = register[mlist[2]]
    rs2 = register[mlist[3]]
    return funct7+rs2+rs1+funct3+rd+opcode

def IType (string) :
    mlist = string.split()
    if mlist[0]=='lb' or mlist[0]=='lw' or mlist[0] == 'lh' or mlist[0] == 'ld' or mlist[0] =='lbu' or mlist[0] == 'lhu' or mlist[0] == 'lwu' :
        opcode = OPCODE [mlist[0]]
        funct3 = FUNCT3 [mlist[0]]
        rd = register [mlist[1]] 
        if mlist[2].startswith('0x'):
            mlist[2]=convert_hextodec(mlist[2])
        imm = bin(int(mlist[2]))[2:14].rjust(12,'0')
        if int(mlist[2]) <0 :
           imm= bin((1<<12) - - int(mlist[2]))
           imm = imm[2:]
        rs1 = register [mlist[3]]
        return imm+rs1+funct3+rd+opcode 
    
    if mlist[0] == 'slli' or mlist[0]=='srli' or mlist[0]=='srai' or mlist[0]=='slliw'or mlist[0]=='srliw' or mlist[0]=='sraiw':
         opcode = OPCODE [mlist[0]]
         funct3 = FUNCT3 [mlist[0]]
         rd = register [mlist[1]]
         funct7 = FUNCT7 [mlist[0]]
         if mlist[3].startswith('0x'):
             mlist[3]=convert_hextodec(mlist[3])
         
         imm = bin(int(mlist[3]))[2:7].rjust(5,'0')
         if int(mlist[3]) <0 :
             imm= bin((1<<12) - - int(mlist[3]))
             imm = imm [2:]
         rs1 = register [mlist[2]]
         return funct7+imm+rs1+funct3+rd+opcode 

    if mlist[0] == 'ecall' or mlist[0]== 'ebreak' :
         opcode = OPCODE [mlist[0]]
         funct3 = FUNCT3 [mlist[0]]
         rd = register [mlist[1]]
         funct7 = FUNCT7[mlist[0]]
         return funct7+rs1+funct3+rd+opcode

    opcode = OPCODE [mlist[0]]
    funct3 = FUNCT3 [mlist[0]]
    rd = register [mlist[1]]
    if mlist[3].startswith('0x'):
        mlist[3]=convert_hextodec(mlist[3])
    imm = bin(int(mlist[3]))[2:14].rjust(12,'0')
    if int(mlist[3]) <0 :
        imm= bin((1<<12) - - int(mlist[3]))
        imm = imm [2:]
    rs1 = register [mlist[2]]
    return imm+rs1+funct3+rd+opcode 

def UJType (string) :
    mlist = string.split()
    opcode = OPCODE [mlist[0]]
    rd = register [mlist[1]]
    if mlist[2].startswith('0x'):
        temp = convert_hextodec(mlist[2])
    else:
        if mlist[2].isdigit() :
            temp = int(mlist[2])
        else:
            temp = address[mlist[2]] - address[string]
    imm = bin(temp)[2:].rjust(21,'0')
    if int(temp) <0 :
        imm= bin((1<<21) - - temp)
        imm= imm[2:]
    imm = imm[0] + imm [10:20]+ imm [9] + imm[1:9]
    return imm+rd+opcode

def SType (string) :
    mlist = string.split()
    opcode = OPCODE [mlist[0]]
    rs2 = register [mlist[1]]
    if mlist[2].startswith('0x'):
        mlist[2]=convert_hextodec(mlist[2])
    imm = bin(int(mlist[2]))[2:14].rjust(12,'0')
    if int(mlist[2]) <0 :
        imm= bin((1<<12) - - int(mlist[2]))[2:]
    rs1= register[mlist[3]]
    return imm[0:-5]+rs2+rs1+FUNCT3[mlist[0]]+imm[-5:]+opcode

def SBType (string) :
    mlist = string.split()
    opcode = OPCODE [mlist[0]]
    rs1= register[mlist[1]]
    rs2 = register [mlist[2]]
    if mlist[3].startswith('0x'):
        temp = convert_hextodec(mlist[3])
    else:
        if mlist[3].isdigit() or (mlist[3][1:].isdigit() and mlist[3][0] == '-') :
            temp = int (mlist[3])
        else:
            temp = (address[mlist[3]] - address [string])
    imm = bin(temp)[2:13].rjust(13,'0')
    if int(temp) <0 :
        imm= bin((1<<13) - - temp)[2:]
    return  imm[0]+imm[2:8]+rs2+rs1+FUNCT3[mlist[0]]+imm[8:12]+imm[1]+opcode 

def UType (string) :
    mlist = string.split()
    opcode = OPCODE [mlist[0]]
    rd = register [mlist[1]]
    if mlist[2].startswith('0x'):
        temp = convert_hextodec(mlist[2])
    else:
        if mlist[2].isdigit() :
            temp = int(mlist[2])
        else:
            temp = address[mlist[2]]
    imm = bin(temp)[2:22].rjust(20,'0')
    if int(temp) <0 :
        imm= bin((1<<20) - - temp)
    return imm+rd+opcode

def assembler ():
    fi= open('Code_editor.txt', 'r')
    string= fi.read()
    fi.close()
    fo= open('Machine_code.txt', 'w')

    result = ''
    ins = string.split('\n')
    PC = 0
    pos = 0
    while pos <(len(ins))-1:
        ins[pos]= handler_string(ins[pos])
        if ins[pos] =='.text':
            break
        pos+=1

    for i in range (pos+1,len(ins)) :  
        ins[i]= handler_string(ins[i])
        if ins[i] == ' ' or ins[i]=='' or ins[i]=='\n':
            continue
        
        li = ins[i].split()
        if len(li) ==1 :
            while ins[i].find(':') != -1 :
                address[ins[i][:ins[i].find(':')]] = PC
                ins[i] = ins[i][ins[i].find(':')+1:]
       
        else :
            if ins[i].find(':') != -1 :
                label = ins[i] [:ins[i].find (':')].strip()
                instruction = ins[i] [ins[i].find (':')+1:].strip()
                address [label] = PC
                address [instruction] = PC 
                ins[i]=instruction
                PC+=4   
            else:
                ins[i]+=" "+ str (i)
                address[ins[i]] = PC
                PC+=4

    for i in range (pos+1,len(ins)) :
        ins[i]=handler_string(ins[i])
        t = ins[i].split()
        if len(t) <2:
            continue
        if FMT[t[0]] == "R":
            string= RType(ins[i])
        if FMT[t[0]] == "I":
            string= IType(ins[i])
        if FMT[t[0]] == "S":
            string= SType(ins[i])
        if FMT[t[0]] == "SB":
            string= SBType(ins[i])
        if FMT[t[0]] == "U":
            string= UType(ins[i])
        if FMT[t[0]] == "UJ":
            string= UJType(ins[i])
        result += (string + '\n')
    fo.write(result)
    fo.close()

assembler()