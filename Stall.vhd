LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.math_real.all;

ENTITY stall IS
PORT(

-------------------------------------  Input Bits  ----------------------------------------
    IR1_CURR     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    IR1_PREV        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    IR2_CURR     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    IR2_PREV        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    PC_IN           : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);

------------------------------------- Output Bits  ----------------------------------------

    IR1_OUT         : OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
    IR2_OUT         : OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
    PC_OUT          : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)

);
end stall;

architecture arch_stall of stall IS

signal RdstLast,RsrcCur,RdstCur : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal dummy,ALU_Stall : STD_LOGIC;

begin


RdstLast <= IR1_CURR(5 DOWNTO 3) when IR1_CURR(15 DOWNTO 13)="110" or IR1_CURR(15 DOWNTO 13)="000" or IR1_CURR(15 DOWNTO 13)="001"
    else IR1_CURR(2 DOWNTO 0) when IR1_CURR(15 DOWNTO 10)="111001" or IR1_CURR(15 DOWNTO 10)="111101" --shift
    else IR1_CURR(2 DOWNTO 0) when IR1_CURR(15 DOWNTO 13)="100" or IR1_CURR(15 DOWNTO 13)="010"; 

RsrcCur <= IR2_CURR(2 DOWNTO 0) when IR2_CURR(15 DOWNTO 14)="11" or IR2_CURR(15 DOWNTO 14)="00";

RdstCur <= IR2_CURR(5 DOWNTO 3) when IR2_CURR(15 DOWNTO 13)="110" or IR2_CURR(15 DOWNTO 13)="000" or IR2_CURR(15 DOWNTO 13)="001"
    else IR2_CURR(2 DOWNTO 0) when IR2_CURR(15 DOWNTO 10)="111001" or IR2_CURR(15 DOWNTO 10)="111101" --shift
    else IR2_CURR(2 DOWNTO 0) when IR2_CURR(15 DOWNTO 13)="100" or IR2_CURR(15 DOWNTO 13)="010"; 
    

ALU_Stall_Detect:
ENTITY work.DataForwarding
GENERIC MAP(n => 16, m => 10)
PORT MAP(
        IR_last         => IR1_CURR,
        IR_crnt         => IR2_CURR,         
        Rdst_last       => RdstLast,
        Rsrc_crnt       => RsrcCur,
        Rdst_crnt       => RdstCur,
        ALU_Forward     => ALU_Stall,
        FirstOperand    => dummy,
        SecondOperand   => dummy
);

    ------------------------------------------------------------------------IR1------------------------------------------------------------------------
    IR1_OUT <= (others => '0') when IR2_PREV(15 DOWNTO 10) /= "001010" and ( (IR1_PREV(15 DOWNTO 10) = "100100"
    and ( --pop for previous channel 1
        (IR1_CURR(15 DOWNTO 12) = "1000" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0)) or --not,inc,dec,push
        (IR1_CURR(15 DOWNTO 13) = "110" and (IR1_CURR(5 DOWNTO 3) = IR1_PREV(2 DOWNTO 0) or IR1_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0))) or --add,sub,and,or
        (IR1_CURR(15 DOWNTO 10) = "001100" and (IR1_CURR(5 DOWNTO 3) = IR1_PREV(2 DOWNTO 0) or IR1_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0))) or --std
        (IR1_CURR(15 DOWNTO 10) = "001011" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0)) or --ldd
        (IR1_CURR(15 DOWNTO 10) = "001001" and IR1_CURR(5 DOWNTO 3) = IR1_PREV(2 DOWNTO 0)) or --out
        (IR1_CURR(15 DOWNTO 13) = "010" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0)) or --jz,jn,jc,jmp
        (IR1_CURR(15 DOWNTO 10) = "100101" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0)) or --call
        (IR1_CURR(15 DOWNTO 10) = "000010" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0)) or --mov
        (IR1_CURR(15 DOWNTO 13) = "111" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0)) --shl,shr
        )
    ) or (IR1_PREV(15 DOWNTO 10) = "001011"
    and ( --ldd for previous channel 1
        (IR1_CURR(15 DOWNTO 12) = "1000" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3)) or --not,inc,dec,push
        (IR1_CURR(15 DOWNTO 13) = "110" and (IR1_CURR(5 DOWNTO 3) = IR1_PREV(5 DOWNTO 3) or IR1_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3))) or --add,sub,and,or
        (IR1_CURR(15 DOWNTO 10) = "001100" and (IR1_CURR(5 DOWNTO 3) = IR1_PREV(5 DOWNTO 3) or IR1_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3))) or --std
        (IR1_CURR(15 DOWNTO 10) = "001011" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3)) or --ldd
        (IR1_CURR(15 DOWNTO 10) = "001001" and IR1_CURR(5 DOWNTO 3) = IR1_PREV(5 DOWNTO 3)) or --out
        (IR1_CURR(15 DOWNTO 13) = "010" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3)) or --jz,jn,jc,jmp
        (IR1_CURR(15 DOWNTO 10) = "100101" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3)) or --call
        (IR1_CURR(15 DOWNTO 10) = "000010" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3)) or --mov
        (IR1_CURR(15 DOWNTO 13) = "111" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3)) --shl,shr
        )
    ) or ( IR2_PREV(15 DOWNTO 10) = "100100"
    and ( --pop for previous channel 2
        (IR1_CURR(15 DOWNTO 12) = "1000" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0)) or --not,inc,dec,push
        (IR1_CURR(15 DOWNTO 13) = "110" and (IR1_CURR(5 DOWNTO 3) = IR2_PREV(2 DOWNTO 0) or IR1_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0))) or --add,sub,and,or
        (IR1_CURR(15 DOWNTO 10) = "001100" and (IR1_CURR(5 DOWNTO 3) = IR2_PREV(2 DOWNTO 0) or IR1_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0))) or --std
        (IR1_CURR(15 DOWNTO 10) = "001011" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0)) or --ldd
        (IR1_CURR(15 DOWNTO 10) = "001001" and IR1_CURR(5 DOWNTO 3) = IR2_PREV(2 DOWNTO 0)) or --out
        (IR1_CURR(15 DOWNTO 13) = "010" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0)) or --jz,jn,jc,jmp
        (IR1_CURR(15 DOWNTO 10) = "100101" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0)) or --call
        (IR1_CURR(15 DOWNTO 10) = "000010" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0)) or --mov
        (IR1_CURR(15 DOWNTO 13) = "111" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0)) --shl,shr
        )
    ) or (IR2_PREV(15 DOWNTO 10) = "001011"
    and ( --ldd for previous channel 2
        (IR1_CURR(15 DOWNTO 12) = "1000" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3)) or --not,inc,dec,push
        (IR1_CURR(15 DOWNTO 13) = "110" and (IR1_CURR(5 DOWNTO 3) = IR2_PREV(5 DOWNTO 3) or IR1_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3))) or --add,sub,and,or
        (IR1_CURR(15 DOWNTO 10) = "001100" and (IR1_CURR(5 DOWNTO 3) = IR2_PREV(5 DOWNTO 3) or IR1_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3))) or --std
        (IR1_CURR(15 DOWNTO 10) = "001011" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3)) or --ldd
        (IR1_CURR(15 DOWNTO 10) = "001001" and IR1_CURR(5 DOWNTO 3) = IR2_PREV(5 DOWNTO 3)) or --out
        (IR1_CURR(15 DOWNTO 13) = "010" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3)) or --jz,jn,jc,jmp
        (IR1_CURR(15 DOWNTO 10) = "100101" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3)) or --call
        (IR1_CURR(15 DOWNTO 10) = "000010" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3)) or --mov
        (IR1_CURR(15 DOWNTO 13) = "111" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3)) --shl,shr
        )
<<<<<<< HEAD
    ) or ( IR1_CURR(15 DOWNTO 10) = "100011" and ( IR1_PREV(15 DOWNTO 10) = "100011" or IR2_PREV(15 DOWNTO 10) = "100011"  ) ) ) 
=======
    ) )
>>>>>>> c8b0e41e45bf23b105f5b76965e58871a90eb4f6
    else IR1_CURR;


    ------------------------------------------------------------------------IR2------------------------------------------------------------------------
    IR2_OUT <= (others => '0') when IR1_CURR(15 DOWNTO 10) /= "001010" and ( (IR1_PREV(15 DOWNTO 10) = "100100"
    and ( --pop for previous channel 1
        (IR2_CURR(15 DOWNTO 12) = "1000" and IR2_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0)) or --not,inc,dec,push
        (IR2_CURR(15 DOWNTO 13) = "110" and (IR2_CURR(5 DOWNTO 3) = IR1_PREV(2 DOWNTO 0) or IR2_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0))) or --add,sub,and,or
        (IR2_CURR(15 DOWNTO 10) = "001100" and (IR2_CURR(5 DOWNTO 3) = IR1_PREV(2 DOWNTO 0) or IR2_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0))) or --std
        (IR2_CURR(15 DOWNTO 10) = "001011" and IR2_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0)) or --ldd
        (IR2_CURR(15 DOWNTO 10) = "001001" and IR2_CURR(5 DOWNTO 3) = IR1_PREV(2 DOWNTO 0)) or --out
        (IR2_CURR(15 DOWNTO 13) = "010" and IR2_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0)) or --jz,jn,jc,jmp
        (IR2_CURR(15 DOWNTO 10) = "100101" and IR2_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0)) or --call
        (IR2_CURR(15 DOWNTO 10) = "000010" and IR2_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0)) or --mov
        (IR2_CURR(15 DOWNTO 13) = "111" and IR2_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0)) --shl,shr
        )
    ) or (IR1_PREV(15 DOWNTO 10) = "001011"
    and ( --ldd for previous channel 1
        (IR2_CURR(15 DOWNTO 12) = "1000" and IR2_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3)) or --not,inc,dec,push
        (IR2_CURR(15 DOWNTO 13) = "110" and (IR2_CURR(5 DOWNTO 3) = IR1_PREV(5 DOWNTO 3) or IR2_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3))) or --add,sub,and,or
        (IR2_CURR(15 DOWNTO 10) = "001100" and (IR2_CURR(5 DOWNTO 3) = IR1_PREV(5 DOWNTO 3) or IR2_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3))) or --std
        (IR2_CURR(15 DOWNTO 10) = "001011" and IR2_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3)) or --ldd
        (IR2_CURR(15 DOWNTO 10) = "001001" and IR2_CURR(5 DOWNTO 3) = IR1_PREV(5 DOWNTO 3)) or --out
        (IR2_CURR(15 DOWNTO 13) = "010" and IR2_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3)) or --jz,jn,jc,jmp
        (IR2_CURR(15 DOWNTO 10) = "100101" and IR2_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3)) or --call
        (IR2_CURR(15 DOWNTO 10) = "000010" and IR2_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3)) or --mov
        (IR2_CURR(15 DOWNTO 13) = "111" and IR2_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3)) --shl,shr
        )
    ) or ( IR2_PREV(15 DOWNTO 10) = "100100"
    and ( --pop for previous channel 2
        (IR2_CURR(15 DOWNTO 12) = "1000" and IR2_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0)) or --not,inc,dec,push
        (IR2_CURR(15 DOWNTO 13) = "110" and (IR2_CURR(5 DOWNTO 3) = IR2_PREV(2 DOWNTO 0) or IR2_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0))) or --add,sub,and,or
        (IR2_CURR(15 DOWNTO 10) = "001100" and (IR2_CURR(5 DOWNTO 3) = IR2_PREV(2 DOWNTO 0) or IR2_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0))) or --std
        (IR2_CURR(15 DOWNTO 10) = "001011" and IR2_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0)) or --ldd
        (IR2_CURR(15 DOWNTO 10) = "001001" and IR2_CURR(5 DOWNTO 3) = IR2_PREV(2 DOWNTO 0)) or --out
        (IR2_CURR(15 DOWNTO 13) = "010" and IR2_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0)) or --jz,jn,jc,jmp
        (IR2_CURR(15 DOWNTO 10) = "100101" and IR2_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0)) or --call
        (IR2_CURR(15 DOWNTO 10) = "000010" and IR2_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0)) or --mov
        (IR2_CURR(15 DOWNTO 13) = "111" and IR2_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0)) --shl,shr
        )
    ) or (IR2_PREV(15 DOWNTO 10) = "001011"
    and ( --ldd for previous channel 2
        (IR2_CURR(15 DOWNTO 12) = "1000" and IR2_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3)) or --not,inc,dec,push
        (IR2_CURR(15 DOWNTO 13) = "110" and (IR2_CURR(5 DOWNTO 3) = IR2_PREV(5 DOWNTO 3) or IR2_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3))) or --add,sub,and,or
        (IR2_CURR(15 DOWNTO 10) = "001100" and (IR2_CURR(5 DOWNTO 3) = IR2_PREV(5 DOWNTO 3) or IR2_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3))) or --std
        (IR2_CURR(15 DOWNTO 10) = "001011" and IR2_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3)) or --ldd
        (IR2_CURR(15 DOWNTO 10) = "001001" and IR2_CURR(5 DOWNTO 3) = IR2_PREV(5 DOWNTO 3)) or --out
        (IR2_CURR(15 DOWNTO 13) = "010" and IR2_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3)) or --jz,jn,jc,jmp
        (IR2_CURR(15 DOWNTO 10) = "100101" and IR2_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3)) or --call
        (IR2_CURR(15 DOWNTO 10) = "000010" and IR2_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3)) or --mov
        (IR2_CURR(15 DOWNTO 13) = "111" and IR2_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3)) --shl,shr
        )
    ) or ( IR1_CURR(15 DOWNTO 10) = "100100"
    and ( --pop for previous channel 2
        (IR2_CURR(15 DOWNTO 12) = "1000" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(2 DOWNTO 0)) or --not,inc,dec,push
        (IR2_CURR(15 DOWNTO 13) = "110" and (IR2_CURR(5 DOWNTO 3) = IR1_CURR(2 DOWNTO 0) or IR2_CURR(2 DOWNTO 0) = IR1_CURR(2 DOWNTO 0))) or --add,sub,and,or
        (IR2_CURR(15 DOWNTO 10) = "001100" and (IR2_CURR(5 DOWNTO 3) = IR1_CURR(2 DOWNTO 0) or IR2_CURR(2 DOWNTO 0) = IR1_CURR(2 DOWNTO 0))) or --std
        (IR2_CURR(15 DOWNTO 10) = "001011" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(2 DOWNTO 0)) or --ldd
        (IR2_CURR(15 DOWNTO 10) = "001001" and IR2_CURR(5 DOWNTO 3) = IR1_CURR(2 DOWNTO 0)) or --out
        (IR2_CURR(15 DOWNTO 13) = "010" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(2 DOWNTO 0)) or --jz,jn,jc,jmp
        (IR2_CURR(15 DOWNTO 10) = "100101" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(2 DOWNTO 0)) or --call
        (IR2_CURR(15 DOWNTO 10) = "000010" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(2 DOWNTO 0)) or --mov
        (IR2_CURR(15 DOWNTO 13) = "111" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(2 DOWNTO 0)) --shl,shr
        )
    ) or (IR1_CURR(15 DOWNTO 10) = "001011"
    and ( --ldd for previous channel 2
        (IR2_CURR(15 DOWNTO 12) = "1000" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(5 DOWNTO 3)) or --not,inc,dec,push
        (IR2_CURR(15 DOWNTO 13) = "110" and (IR2_CURR(5 DOWNTO 3) = IR1_CURR(5 DOWNTO 3) or IR2_CURR(2 DOWNTO 0) = IR1_CURR(5 DOWNTO 3))) or --add,sub,and,or
        (IR2_CURR(15 DOWNTO 10) = "001100" and (IR2_CURR(5 DOWNTO 3) = IR1_CURR(5 DOWNTO 3) or IR2_CURR(2 DOWNTO 0) = IR1_CURR(5 DOWNTO 3))) or --std
        (IR2_CURR(15 DOWNTO 10) = "001011" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(5 DOWNTO 3)) or --ldd
        (IR2_CURR(15 DOWNTO 10) = "001001" and IR2_CURR(5 DOWNTO 3) = IR1_CURR(5 DOWNTO 3)) or --out
        (IR2_CURR(15 DOWNTO 13) = "010" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(5 DOWNTO 3)) or --jz,jn,jc,jmp
        (IR2_CURR(15 DOWNTO 10) = "100101" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(5 DOWNTO 3)) or --call
        (IR2_CURR(15 DOWNTO 10) = "000010" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(5 DOWNTO 3)) or --mov
        (IR2_CURR(15 DOWNTO 13) = "111" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(5 DOWNTO 3)) --shl,shr
        )
    ) or ALU_Stall = '1'    --DATA HAZARD
    or (IR1_CURR(15 DOWNTO 10) = "001000" and IR2_CURR(15 DOWNTO 10) = "001000")    --Two consictive IN.
    or (IR1_CURR(15 DOWNTO 10) = "100011" and IR2_CURR(15 DOWNTO 10) = "100100")    --Strucural Hazard [PUSH -> POP]
    or (IR1_CURR(15 DOWNTO 10) = "100100" and IR2_CURR(15 DOWNTO 10) = "100011")    --Strucural Hazard [POP -> PUSH]
    or (IR1_CURR(15 DOWNTO 10) = "001011" and IR2_CURR(15 DOWNTO 10) = "001100")    --Strucural Hazard [LDD -> STD]
    or (IR1_CURR(15 DOWNTO 10) = "001100" and IR2_CURR(15 DOWNTO 10) = "001011")    --Strucural Hazard [STD -> LDD]

    or (IR1_CURR(15 DOWNTO 10) = "100011" and IR2_CURR(15 DOWNTO 10) = "100011")    --Strucural Hazard [PUSH -> PUSH]
    or (IR1_CURR(15 DOWNTO 10) = "100100" and IR2_CURR(15 DOWNTO 10) = "100100")    --Strucural Hazard [POP -> POP]
    or (IR1_CURR(15 DOWNTO 10) = "001011" and IR2_CURR(15 DOWNTO 10) = "001011")    --Strucural Hazard [LDD -> LDD]
    or (IR1_CURR(15 DOWNTO 10) = "001100" and IR2_CURR(15 DOWNTO 10) = "001100")    --Strucural Hazard [STD -> STD]
    
    -- Strucural Hazard:  PUSH or POP or LDD or STD  -> CALL or RET or RTI
    or ( (IR1_CURR(15 DOWNTO 10) = "100011" or IR1_CURR(15 DOWNTO 10) = "100100" or IR1_CURR(15 DOWNTO 10) = "001100" or IR1_CURR(15 DOWNTO 10) = "001011") 
    and (IR2_CURR(15 DOWNTO 10) = "100101" or IR2_CURR(15 DOWNTO 10) = "100110" or IR2_CURR(15 DOWNTO 10) = "100111") )
<<<<<<< HEAD
    or ( IR1_CURR(15 DOWNTO 10) = "100011" and ( IR1_PREV(15 DOWNTO 10) = "100011" or IR2_PREV(15 DOWNTO 10) = "100011"  ) ) ) 
=======
    )
>>>>>>> c8b0e41e45bf23b105f5b76965e58871a90eb4f6
    
    else IR2_CURR;



    ------------------------------------------------------------------------PC------------------------------------------------------------------------
    PC_OUT <= std_logic_vector(unsigned(PC_IN) + 1) when IR1_CURR(15 DOWNTO 10) /= "001010" and ( (IR1_CURR(15 DOWNTO 10) = "100100"              -- Stall 2 times
    and ( --pop for previous channel 2
        (IR2_CURR(15 DOWNTO 12) = "1000" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(2 DOWNTO 0)) or --not,inc,dec,push
        (IR2_CURR(15 DOWNTO 13) = "110" and (IR2_CURR(5 DOWNTO 3) = IR1_CURR(2 DOWNTO 0) or IR2_CURR(2 DOWNTO 0) = IR1_CURR(2 DOWNTO 0))) or --add,sub,and,or
        (IR2_CURR(15 DOWNTO 10) = "001100" and (IR2_CURR(5 DOWNTO 3) = IR1_CURR(2 DOWNTO 0) or IR2_CURR(2 DOWNTO 0) = IR1_CURR(2 DOWNTO 0))) or --std
        (IR2_CURR(15 DOWNTO 10) = "001011" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(2 DOWNTO 0)) or --ldd
        (IR2_CURR(15 DOWNTO 10) = "001001" and IR2_CURR(5 DOWNTO 3) = IR1_CURR(2 DOWNTO 0)) or --out
        (IR2_CURR(15 DOWNTO 13) = "010" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(2 DOWNTO 0)) or --jz,jn,jc,jmp
        (IR2_CURR(15 DOWNTO 10) = "100101" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(2 DOWNTO 0)) or --call
        (IR2_CURR(15 DOWNTO 10) = "000010" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(2 DOWNTO 0)) or --mov
        (IR2_CURR(15 DOWNTO 13) = "111" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(2 DOWNTO 0)) --shl,shr
        )
    ) or (IR1_CURR(15 DOWNTO 10) = "001011"
    and ( --ldd for previous channel 2
        (IR2_CURR(15 DOWNTO 12) = "1000" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(5 DOWNTO 3)) or --not,inc,dec,push
        (IR2_CURR(15 DOWNTO 13) = "110" and (IR2_CURR(5 DOWNTO 3) = IR1_CURR(5 DOWNTO 3) or IR2_CURR(2 DOWNTO 0) = IR1_CURR(5 DOWNTO 3))) or --add,sub,and,or
        (IR2_CURR(15 DOWNTO 10) = "001100" and (IR2_CURR(5 DOWNTO 3) = IR1_CURR(5 DOWNTO 3) or IR2_CURR(2 DOWNTO 0) = IR1_CURR(5 DOWNTO 3))) or --std
        (IR2_CURR(15 DOWNTO 10) = "001011" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(5 DOWNTO 3)) or --ldd
        (IR2_CURR(15 DOWNTO 10) = "001001" and IR2_CURR(5 DOWNTO 3) = IR1_CURR(5 DOWNTO 3)) or --out
        (IR2_CURR(15 DOWNTO 13) = "010" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(5 DOWNTO 3)) or --jz,jn,jc,jmp
        (IR2_CURR(15 DOWNTO 10) = "100101" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(5 DOWNTO 3)) or --call
        (IR2_CURR(15 DOWNTO 10) = "000010" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(5 DOWNTO 3)) or --mov
        (IR2_CURR(15 DOWNTO 13) = "111" and IR2_CURR(2 DOWNTO 0) = IR1_CURR(5 DOWNTO 3)) --shl,shr
        )
    ) or ALU_Stall = '1'        --Data Hazard.
    or (IR1_CURR(15 DOWNTO 10) = "001000" and IR2_CURR(15 DOWNTO 10) = "001000")  --Two consictive IN.
    or (IR1_CURR(15 DOWNTO 10) = "100011" and IR2_CURR(15 DOWNTO 10) = "100100")    --Strucural Hazard [PUSH -> POP]
    or (IR1_CURR(15 DOWNTO 10) = "100100" and IR2_CURR(15 DOWNTO 10) = "100011")    --Strucural Hazard [POP -> PUSH]
    or (IR1_CURR(15 DOWNTO 10) = "001011" and IR2_CURR(15 DOWNTO 10) = "001100")    --Strucural Hazard [LDD -> STD]
    or (IR1_CURR(15 DOWNTO 10) = "001100" and IR2_CURR(15 DOWNTO 10) = "001011")    --Strucural Hazard [STD -> LDD]

    or (IR1_CURR(15 DOWNTO 10) = "100011" and IR2_CURR(15 DOWNTO 10) = "100011")    --Strucural Hazard [PUSH -> PUSH]
    or (IR1_CURR(15 DOWNTO 10) = "100100" and IR2_CURR(15 DOWNTO 10) = "100100")    --Strucural Hazard [POP -> POP]
    or (IR1_CURR(15 DOWNTO 10) = "001011" and IR2_CURR(15 DOWNTO 10) = "001011")    --Strucural Hazard [LDD -> LDD]
    or (IR1_CURR(15 DOWNTO 10) = "001100" and IR2_CURR(15 DOWNTO 10) = "001100")    --Strucural Hazard [STD -> STD]

    -- Strucural Hazard:  PUSH or POP or LDD or STD  -> CALL or RET or RTI
    or ( (IR1_CURR(15 DOWNTO 10) = "100011" or IR1_CURR(15 DOWNTO 10) = "100100" or IR1_CURR(15 DOWNTO 10) = "001100" or IR1_CURR(15 DOWNTO 10) = "001011") 
    and (IR2_CURR(15 DOWNTO 10) = "100101" or IR2_CURR(15 DOWNTO 10) = "100110" or IR2_CURR(15 DOWNTO 10) = "100111") )
<<<<<<< HEAD
    or ( IR2_CURR(15 DOWNTO 10) = "100011" and ( IR1_PREV(15 DOWNTO 10) = "100011" or IR2_PREV(15 DOWNTO 10) = "100011"  ) )
    ) 
=======
    )
>>>>>>> c8b0e41e45bf23b105f5b76965e58871a90eb4f6

    else PC_IN when IR2_PREV(15 DOWNTO 10) /= "001010" and ( (IR1_PREV(15 DOWNTO 10) = "100100"                 -- Stall 1 time
    and ( --pop for previous channel 1
        (IR1_CURR(15 DOWNTO 12) = "1000" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0)) or --not,inc,dec,push
        (IR1_CURR(15 DOWNTO 13) = "110" and (IR1_CURR(5 DOWNTO 3) = IR1_PREV(2 DOWNTO 0) or IR1_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0))) or --add,sub,and,or
        (IR1_CURR(15 DOWNTO 10) = "001100" and (IR1_CURR(5 DOWNTO 3) = IR1_PREV(2 DOWNTO 0) or IR1_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0))) or --std
        (IR1_CURR(15 DOWNTO 10) = "001011" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0)) or --ldd
        (IR1_CURR(15 DOWNTO 10) = "001001" and IR1_CURR(5 DOWNTO 3) = IR1_PREV(2 DOWNTO 0)) or --out
        (IR1_CURR(15 DOWNTO 13) = "010" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0)) or --jz,jn,jc,jmp
        (IR1_CURR(15 DOWNTO 10) = "100101" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0)) or --call
        (IR1_CURR(15 DOWNTO 10) = "000010" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0)) or --mov
        (IR1_CURR(15 DOWNTO 13) = "111" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(2 DOWNTO 0)) --shl,shr
        )
    ) or (IR1_PREV(15 DOWNTO 10) = "001011"
    and ( --ldd for previous channel 1
        (IR1_CURR(15 DOWNTO 12) = "1000" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3)) or --not,inc,dec,push
        (IR1_CURR(15 DOWNTO 13) = "110" and (IR1_CURR(5 DOWNTO 3) = IR1_PREV(5 DOWNTO 3) or IR1_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3))) or --add,sub,and,or
        (IR1_CURR(15 DOWNTO 10) = "001100" and (IR1_CURR(5 DOWNTO 3) = IR1_PREV(5 DOWNTO 3) or IR1_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3))) or --std
        (IR1_CURR(15 DOWNTO 10) = "001011" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3)) or --ldd
        (IR1_CURR(15 DOWNTO 10) = "001001" and IR1_CURR(5 DOWNTO 3) = IR1_PREV(5 DOWNTO 3)) or --out
        (IR1_CURR(15 DOWNTO 13) = "010" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3)) or --jz,jn,jc,jmp
        (IR1_CURR(15 DOWNTO 10) = "100101" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3)) or --call
        (IR1_CURR(15 DOWNTO 10) = "000010" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3)) or --mov
        (IR1_CURR(15 DOWNTO 13) = "111" and IR1_CURR(2 DOWNTO 0) = IR1_PREV(5 DOWNTO 3)) --shl,shr
        )
    ) or ( IR2_PREV(15 DOWNTO 10) = "100100"
    and ( --pop for previous channel 2
        (IR1_CURR(15 DOWNTO 12) = "1000" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0)) or --not,inc,dec,push
        (IR1_CURR(15 DOWNTO 13) = "110" and (IR1_CURR(5 DOWNTO 3) = IR2_PREV(2 DOWNTO 0) or IR1_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0))) or --add,sub,and,or
        (IR1_CURR(15 DOWNTO 10) = "001100" and (IR1_CURR(5 DOWNTO 3) = IR2_PREV(2 DOWNTO 0) or IR1_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0))) or --std
        (IR1_CURR(15 DOWNTO 10) = "001011" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0)) or --ldd
        (IR1_CURR(15 DOWNTO 10) = "001001" and IR1_CURR(5 DOWNTO 3) = IR2_PREV(2 DOWNTO 0)) or --out
        (IR1_CURR(15 DOWNTO 13) = "010" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0)) or --jz,jn,jc,jmp
        (IR1_CURR(15 DOWNTO 10) = "100101" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0)) or --call
        (IR1_CURR(15 DOWNTO 10) = "000010" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0)) or --mov
        (IR1_CURR(15 DOWNTO 13) = "111" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(2 DOWNTO 0)) --shl,shr
        )
    ) or (IR2_PREV(15 DOWNTO 10) = "001011"
    and ( --ldd for previous channel 2
        (IR1_CURR(15 DOWNTO 12) = "1000" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3)) or --not,inc,dec,push
        (IR1_CURR(15 DOWNTO 13) = "110" and (IR1_CURR(5 DOWNTO 3) = IR2_PREV(5 DOWNTO 3) or IR1_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3))) or --add,sub,and,or
        (IR1_CURR(15 DOWNTO 10) = "001100" and (IR1_CURR(5 DOWNTO 3) = IR2_PREV(5 DOWNTO 3) or IR1_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3))) or --std
        (IR1_CURR(15 DOWNTO 10) = "001011" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3)) or --ldd
        (IR1_CURR(15 DOWNTO 10) = "001001" and IR1_CURR(5 DOWNTO 3) = IR2_PREV(5 DOWNTO 3)) or --out
        (IR1_CURR(15 DOWNTO 13) = "010" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3)) or --jz,jn,jc,jmp
        (IR1_CURR(15 DOWNTO 10) = "100101" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3)) or --call
        (IR1_CURR(15 DOWNTO 10) = "000010" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3)) or --mov
        (IR1_CURR(15 DOWNTO 13) = "111" and IR1_CURR(2 DOWNTO 0) = IR2_PREV(5 DOWNTO 3)) --shl,shr
        )
<<<<<<< HEAD
    ) or ( IR1_CURR(15 DOWNTO 10) = "100011" and ( IR1_PREV(15 DOWNTO 10) = "100011" or IR2_PREV(15 DOWNTO 10) = "100011"  ) ) ) 
=======
    ) )
>>>>>>> c8b0e41e45bf23b105f5b76965e58871a90eb4f6
    else std_logic_vector(unsigned(PC_IN) + 2);         -- No Stall





end arch_stall;



