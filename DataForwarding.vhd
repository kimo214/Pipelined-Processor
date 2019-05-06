LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.math_real.all;

ENTITY DataForwarding IS
    PORT(
        IR_last, IR_crnt                    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rdst_last, Rsrc_crnt, Rdst_crnt     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        ALU_Forward, FirstOperand, SecondOperand : OUT STD_LOGIC
    );
END ENTITY;


ARCHITECTURE flow OF DataForwarding IS
signal First, Second : STD_LOGIC;
BEGIN

    First <= '1' when (
        ((  IR_last(15 DOWNTO 14)="11" or IR_last(15 DOWNTO 11)="00001"
            or IR_last(15 DOWNTO 10)="001011" or IR_last(15 DOWNTO 10)="001100") and Rsrc_crnt=Rdst_last)
        
        or ((   (IR_last(15 DOWNTO 12)="1000" and IR_last(11 DOWNTO 10)/="11") 
                or IR_last(15 DOWNTO 13)="010" ) and Rdst_crnt=Rdst_last) 
    )
    else '0';

    Second <= '1' when (
        (IR_last(15 DOWNTO 13)="110" or IR_last(15 DOWNTO 10)="100011" or IR_last(15 DOWNTO 11)="10010") and Rdst_crnt=Rdst_last 
    )
    else '0';


    ALU_Forward <= '1' when (
        -- LAST INSTRUCTION WAS WRITING IN RDST
        ( ( IR_last(15 DOWNTO 13)="111" and IR_last(11 DOWNTO 10)="01" )
        or ( IR_last(15 DOWNTO 13)="110" and IR_last(10)='0' )
        or ( IR_last(15 DOWNTO 12)="1000" and IR_last(11 DOWNTO 10)/="11" ) 
        or IR_last(15 DOWNTO 11)="00001"
        or IR_last(15 DOWNTO 10)="001000")
        
        and (First='1' or Second='1')
    )
    else '0';

    FirstOperand <= First;
    SecondOperand <= Second;


END ARCHITECTURE;
