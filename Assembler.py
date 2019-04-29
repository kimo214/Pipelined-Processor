
TwoOp = ['SHR','SHL','LDM','ADD','SUB','AND','OR','MOV','LDD','STD']
OneOp = ['NOT','INC','DEC','PUSH','POP','CALL','IN','OUT','JZ','JN','JC','JMP']

#Commands = ['SHR','SHL','ADD','SUB','AND','OR','MOV','LDM','LDD','STD',,'RET','RTI','NOP','CLRC','SETC']
OpCode = {
    'SHR':'111001',
    'SHL':'111101',
    'ADD':'110000',
    'SUB':'110010',
    'AND':'110100',
    'OR':'110110',
    'NOT':'100000',
    'INC':'100001',
    'DEC':'100010',
    'PUSH':'100011',
    'POP':'100100',
    'CALL':'100101',
    'RET':'100110',
    'RTI':'100111',
    'NOP':'00000',
    'MOV':'00001',
    'CLRC':'00010',
    'SETC':'00011',
    'IN':'001000',
    'OUT':'001001',
    'LDM':'001010',
    'LDD':'001011' ,
    'STD':'001100',
    'JZ':'01000',
    'JN':'01001',
    'JC':'01010',
    'JMP':'01011'
    }

def GetRegIdx(IDX):
    IDX = str("{0:b}".format(int(IDX)))
    IDX = IDX.rjust(3,'0')
    return IDX

file = open('input.txt','r')
Out = open('Output.txt','w')

lines = file.readlines()

for L in lines:

    Instruction = ""
    Operand1 = ""
    Operand2 = ""
    IR = ""
    Value = ""
    L = L.replace(',',' ')
    L = L.replace(';',' ')
    Words = L.split(' ')
    Instruction = Words[0].upper()
    
    if(not OpCode.__contains__(Instruction)):
        continue
    
    IR+=OpCode[Instruction]
    if TwoOp.count(Instruction) > 0:
        Operand1 = Words[1].upper()
        Operand2 = Words[2].upper()

        if(TwoOp.index(Instruction) < 2):       #SHL or SHR
            IMM = str("{0:b}".format(int(Operand2)))
            IMM = IMM.rjust(7,'0')
            IR += IMM
            IR += GetRegIdx(Operand1[1])

        elif(TwoOp.index(Instruction) == 2):     #LDM
            #Ask The bitches.
            IR = IR.ljust(10,'0')
            IR += GetRegIdx(Operand1[1])
            IR = IR.ljust(16,'0')
            Value = str("{0:b}".format(int(Operand2)))
            Value = Value.rjust(16,'0')
            
        else:
            IR = IR.ljust(10,'0')
            IR += GetRegIdx(Operand2[1])
            IR += GetRegIdx(Operand1[1])

    elif OneOp.count(Instruction) > 0:
        Operand1 = Words[1].upper()
        IR = IR.ljust(13,'0')
        IR += GetRegIdx(Operand1[1])
    else:
        IR = IR.ljust(16,'0') 

    #Write in the output file.
    Out.write(IR)
    Out.write('\n')
    if(Value != ""):
        Out.write(Value)
        Out.write('\n')
    #-------------------------

file.close()
Out.close()