
TwoOp = ['SHR','SHL','LDM','ADD','SUB','AND','OR','MOV','LDD','STD']
OneOp = ['IN','OUT','NOT','INC','DEC','PUSH','POP','CALL','JZ','JN','JC','JMP']

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
    'JMP':'01011',
    }

def GetRegIdx(IDX):
    IDX = str("{0:b}".format(int(IDX)))
    IDX = IDX.rjust(3,'0')
    return IDX

file = open('input.txt','r')
#Out = open('Output.txt','w')
Out = open('Output.mem','w')
Out.write('// memory data file (do not edit the following line - required for mem load use)\n')
Out.write('// instance=/Project/my_ram/ram\n')
Out.write('// format=mti addressradix=d dataradix=b version=1.0 wordsperline=1\n')

lines = file.readlines()
i = 0
for L in lines:

    Instruction = ""
    Operand1 = ""
    Operand2 = ""
    IR = ""
    Value = ""
    L = L.replace(',',' ')
    L = L.replace(';',' ')
    L = L.replace('\n','')
    Words = L.split()
    if(len(Words) == 0):
        continue

    Instruction = Words[0].upper()
    if Instruction == ".ORG":
        MEMlocation = int(Words[1])
        while i != MEMlocation:
            Out.write(str(i)+': ' + "0" * 16 + '\n')
            i+=1
        continue

    try:        #Wrtiting value in the memory.
        Val = str("{0:b}".format(int(Words[0])))
        Val = Val.rjust(16,'0')
        Out.write(str(i)+': ' +Val+'\n')
        continue
    except:
        pass

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
        if(OneOp.index(Instruction) <= 1):
            IR = IR.ljust(10,'0')
            IR += GetRegIdx(Operand1[1])
            IR += '000'
        else:
            IR = IR.ljust(13,'0')
            IR += GetRegIdx(Operand1[1])
    else:
        IR = IR.ljust(16,'0') 

    #Write in the output file.
    Out.write(str(i)+': ')
    i += 1
    Out.write(IR)
    print(IR)
    Out.write('\n')
    if(Value != ""):
        Out.write(str(i)+': ')
        i += 1
        Out.write(Value)
        Out.write('\n')
    #-------------------------

file.close()
Out.close()