LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.math_real.all;

ENTITY Decode IS
    PORT(

-------------------------------------  Input Bits  ----------------------------------------
            CLK,RST                             : IN  STD_LOGIC;                                                                          
            IR1_IN         		        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            IR2_IN         			: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            PC_IN             			: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            SP_IN             			: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            Flag_Register                       : IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);
            Reg1                                : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            Reg2                                : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            Reg3                                : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            Reg4                                : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            Reg5                                : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            Reg6                                : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            Reg7                                : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            Reg8                                : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            
-------------------------------------  Output Bits  ---------------------------------------
    
    -------------------------------------------------------------------------------- ID/EX
    
    ---- For Channel 1 -> ALU 1
            NOP1_OUT                            : OUT STD_LOGIC;
            Taken1_OUT			        : OUT STD_LOGIC;                              -- For Branch instructions = 1 if taken
            ALU1_OP_Code_OUT                    : OUT STD_LOGIC_VECTOR  (2 DOWNTO 0);         -- Add or Sub or Shift ...
            ALU1_Operand1_OUT                   : OUT STD_LOGIC_VECTOR  (31 DOWNTO 0);
            ALU1_Operand2_OUT                   : OUT STD_LOGIC_VECTOR  (31 DOWNTO 0);
            Two_Operand_Instr1_Flag_OUT         : OUT STD_LOGIC;                              -- is Instruction has 2 Opernad or not
            One_or_Two1_OUT                     : OUT STD_LOGIC;                   
            SETC1,CLRC1                         : OUT STD_LOGIC;

    ---- For Channel 2 -> ALU 2
            NOP2_OUT                            : OUT STD_LOGIC;
            Taken2_OUT				: OUT STD_LOGIC;		    	              -- For Branch instructions = 1 if taken
            ALU2_OP_Code_OUT   			: OUT STD_LOGIC_VECTOR  (2 DOWNTO 0);         -- Add or Sub or Shift ...
            ALU2_Operand1_OUT                   : OUT STD_LOGIC_VECTOR  (31 DOWNTO 0);
            ALU2_Operand2_OUT                   : OUT STD_LOGIC_VECTOR  (31 DOWNTO 0);
            Two_Operand_Instr2_Flag_OUT         : OUT STD_LOGIC;                              -- is Instruction has 2 Opernad or not
            One_or_Two2_OUT                     : OUT STD_LOGIC;                    
            SETC2,CLRC2                         : OUT STD_LOGIC;
    -------------------------------------------------------------------------------- EX/MEM
    ---- For Channel 1
            Memory_Read1_OUT	           	: OUT STD_LOGIC;
            Memory_Write1_OUT			: OUT STD_LOGIC;
            ALU_As_Address1_OUT	                : OUT STD_LOGIC;                              -- Take the Output of the ALU as address (pop instruction)
            SP_As_Address1_OUT		    	: OUT STD_LOGIC;                              -- Take original SP as address (Push Instruction)
            PC_As_Data1_OUT				            : OUT STD_LOGIC;			                  -- Use PC as Data to memory (Call instruction)
    
    ---- For Channel 2
            Memory_Read2_OUT  	                : OUT STD_LOGIC;
            Memory_Write2_OUT                   : OUT STD_LOGIC;
            ALU_As_Address2_OUT		        : OUT STD_LOGIC;                              -- Take the Output of the ALU as address (pop instruction)
            SP_As_Address2_OUT		        : OUT STD_LOGIC;                              -- Take original SP as address (Push Instruction)
            PC_As_Data2_OUT	                : OUT STD_LOGIC;			                  -- Use PC as Data to memry (Call instruction)
    
            Memory_Result_OUT	        	: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    
    --------------------------------------------------------------------------------- MEM/WB
    ---- For Channel 1
            Rsrc_Idx1_OUT	          	: OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            Rdst_Idx1_OUT	                : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            Enable_SP1_OUT			: OUT STD_LOGIC;                              -- To write in SP the ALU1 value	
            Enable_Reg1_OUT	                : OUT STD_LOGIC;			                  -- To Know if it will write to a general register
            Mem_or_ALU1_OUT			: OUT STD_LOGIC;                              -- To know which value to write (Memory or ALU 1)
        
        ---- For Channel 2
            Rsrc_Idx2_OUT			: OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            Rdst_Idx2_OUT			: OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            Enable_SP2_OUT			: OUT STD_LOGIC;                              -- To write in SP the ALU2 value	
            Enable_Reg2_OUT	                : OUT STD_LOGIC;			                  -- To Know if it will write to a general register
            Mem_or_ALU2_OUT			: OUT STD_LOGIC                               -- To know which value to write (Memory or ALU 2)
            
    );
END ENTITY;


ARCHITECTURE arch_decode OF Decode IS

Type reg_file is array (0 to 7) of STD_LOGIC_VECTOR(15 DOWNTO 0);
signal registerfile : reg_file;



BEGIN

    registerfile(0)<=reg1;
    registerfile(1)<=reg2; 
    registerfile(2)<=reg3;
    registerfile(3)<=reg4;
    registerfile(4)<=reg5;
    registerfile(5)<=reg6;
    registerfile(6)<=reg7;
    registerfile(7)<=reg8;
 
    PROCESS(CLK, RST)
    
    BEGIN
    IF RISING_EDGE(CLK) THEN


    ---------------------------------------------------------------------------------------------------------------
    ------------------------------------    C H A N N E L   1    --------------------------------------------------
    ---------------------------------------------------------------------------------------------------------------

    if (IR1_IN(15 DOWNTO 11) = "00000" or (IR1_IN(15 DOWNTO 11)="01000" and Flag_Register(0)='1')
                                       or (IR1_IN(15 DOWNTO 11)="01001" and Flag_Register(1)='1') 
                                       or (IR1_IN(15 DOWNTO 11)="01010" and Flag_Register(2)='1')) then
    NOP1_OUT <='1';
    else NOP1_OUT<='0';    
    end if;

    if ((IR1_IN(15 DOWNTO 11)="01000" and Flag_Register(0)='1')
        or (IR1_IN(15 DOWNTO 11)="01001" and Flag_Register(1)='1') 
        or (IR1_IN(15 DOWNTO 11)="01010" and Flag_Register(2)='1')) then
    Taken1_OUT <='1';
    else Taken1_OUT<='0';    
    end if;
    
    if (IR1_IN(15 DOWNTO 10)="100001" or IR1_IN(15 DOWNTO 10)="110000" 
        or IR1_IN(15 DOWNTO 10)="100100" or IR1_IN(15 DOWNTO 10)="100110" 
        or IR1_IN(15 DOWNTO 10)="100111") then
    ALU1_OP_Code_OUT <= "100";
    elsif (IR1_IN(15 DOWNTO 10)="100010" or IR1_IN(15 DOWNTO 10)="110010"
        or IR1_IN(15 DOWNTO 10)="100101" or IR1_IN(15 DOWNTO 10)="100011") then 
    ALU1_OP_Code_OUT <= "110";
    elsif(IR1_IN(15)='1') then 
    ALU1_OP_Code_OUT <= IR1_IN(13 DOWNTO 11);
    else ALU1_OP_Code_OUT <= "111";
    end if;

    if(IR1_IN(15 DOWNTO 10)="001010") then 
    ALU1_Operand1_OUT<=PC_IN;
    elsif(IR1_IN(15 DOWNTO 12)="1001" or IR1_IN(15 DOWNTO 10)="100011") then 
    ALU1_Operand1_OUT<=SP_IN;
    else ALU1_Operand1_OUT<="0000000000000000" & registerfile(to_integer(Unsigned(IR1_IN(2 DOWNTO 0))));
    end if;

    if(IR1_IN(15 DOWNTO 10)="111101" or IR1_IN(15 DOWNTO 10)="111001") then
    ALU1_Operand2_OUT<= "0000000000000000000000000" & IR1_IN(9 DOWNTO 3);
    elsif(IR1_IN(15 DOWNTO 13)="010" or IR1_IN(15 DOWNTO 10)="100101") then 
    ALU1_Operand2_OUT<=PC_IN;
    elsif(IR1_IN(15 DOWNTO 10)="100011" or IR1_IN(15 DOWNTO 10)="100100") then
    ALU1_Operand2_OUT<="0000000000000000" & registerfile(to_integer(Unsigned(IR1_IN(2 DOWNTO 0))));
    else ALU1_Operand2_OUT<="0000000000000000" & registerfile(to_integer(Unsigned(IR1_IN(5 DOWNTO 3))));
    end if;

    if(IR1_IN(15 DOWNTO 14)="11") then 
    Two_Operand_Instr1_Flag_OUT<='1';
    else Two_Operand_Instr1_Flag_OUT<='0';
    end if;

    if(IR1_IN(15 DOWNTO 10)="100101" or IR1_IN(15 DOWNTO 10)="100110" or IR1_IN(15 DOWNTO 10)="100111") then 
    One_or_Two1_OUT <= '1';
    else One_or_Two1_OUT<='0';
    end if;

    if(IR1_IN(15 DOWNTO 10)="000110") then 
    SETC1<='1';
    else SETC1<='0';
    end if; 

    if(IR1_IN(15 DOWNTO 10)="000100") then 
    CLRC1<='1';
    else CLRC1<='0';
    end if;

    if(IR1_IN(15 DOWNTO 10)="100100" or IR1_IN(15 DOWNTO 10)="001011") then 
    Memory_Read1_OUT<='1';
    else Memory_Read1_OUT<='0';
    end if;

    if(IR1_IN(15 DOWNTO 10)="001100" or IR1_IN(15 DOWNTO 10)="100011") then 
    Memory_Write1_OUT<='1';
    else Memory_Write1_OUT<='0';
    end if;

    if(IR1_IN(15 DOWNTO 10)="100100" or IR1_IN(15 DOWNTO 10)="100110" or IR1_IN(15 DOWNTO 10)="100111") then -- pop ret rti
    ALU_As_Address1_OUT<='1';
    else ALU_As_Address1_OUT<='0';
    end if;

    if(IR1_IN(15 DOWNTO 10)="100011" or IR1_IN(15 DOWNTO 10)="100101") then 
    SP_As_Address1_OUT<='1';
    else SP_As_Address1_OUT<='0';
    end if;

    if(IR1_IN(15 DOWNTO 10)="100101") then 
    PC_As_Data1_OUT<='1';
    else PC_As_Data1_OUT<='0';
    end if;

    if(IR1_IN(15 DOWNTO 14)="11" or IR1_IN(15 DOWNTO 14)="00") then 
    Rsrc_Idx1_OUT<=IR1_IN(2 DOWNTO 0);
    end if;

    if(IR1_IN(15 DOWNTO 13)="110" or IR1_IN(15 DOWNTO 13)="000" or IR1_IN(15 DOWNTO 13)="001") then 
    Rdst_Idx1_OUT<=IR1_IN(5 DOWNTO 3);
    elsif(IR1_IN(15 DOWNTO 13)="100" or IR1_IN(15 DOWNTO 13)="010") then 
    Rdst_Idx1_OUT<=IR1_IN(2 DOWNTO 0);
    end if;

    if(IR1_IN(15 DOWNTO 12)="1001" or IR1_IN(15 DOWNTO 10)="100011") then 
    Enable_SP1_OUT<='1';
    else Enable_SP1_OUT<='0';
    end if;

    if(IR1_IN(15 DOWNTO 11)="00101" or IR1_IN(15 DOWNTO 10)="100100") then 
    Mem_or_ALU1_OUT<='1';
    else Mem_or_ALU1_OUT<='0';
    end if;

    if(IR1_IN(15 DOWNTO 10)="000000" or IR1_IN(15 DOWNTO 10)="000110" or IR1_IN(15 DOWNTO 10)="000100" or IR1_IN(15 DOWNTO 10)="001001"
       or IR1_IN(15 DOWNTO 10)="100011" or IR1_IN(15 DOWNTO 10)="001100" or IR1_IN(15 DOWNTO 10)="100101" or IR1_IN(15 DOWNTO 11)="10011"
       or IR1_IN(15 DOWNTO 13)="010") then 
    Enable_Reg1_OUT<='0';
    else Enable_Reg1_OUT<='1';
    end if;
    


    ---------------------------------------------------------------------------------------------------------------
    ------------------------------------    C H A N N E L   2    --------------------------------------------------
    ---------------------------------------------------------------------------------------------------------------


    if(IR2_IN(15 DOWNTO 11) = "00000" or (IR2_IN(15 DOWNTO 11)="01000" and Flag_Register(0)='1')
                                       or (IR2_IN(15 DOWNTO 11)="01001" and Flag_Register(1)='1') 
                                       or (IR2_IN(15 DOWNTO 11)="01010" and Flag_Register(2)='1')) then
    NOP2_OUT <='1';
    else NOP2_OUT<='0';    
    end if;

    if((IR2_IN(15 DOWNTO 11)="01000" and Flag_Register(0)='1')
        or (IR2_IN(15 DOWNTO 11)="01001" and Flag_Register(1)='1') 
        or (IR2_IN(15 DOWNTO 11)="01010" and Flag_Register(2)='1')) then
    Taken2_OUT <='1';
    else Taken2_OUT<='0';    
    end if;
    
    if(IR2_IN(15 DOWNTO 10)="100001" or IR2_IN(15 DOWNTO 10)="110000" 
        or IR2_IN(15 DOWNTO 10)="100100" or IR2_IN(15 DOWNTO 10)="100110" 
        or IR2_IN(15 DOWNTO 10)="100111") then
    ALU2_OP_Code_OUT <= "100";
    elsif (IR2_IN(15 DOWNTO 10)="100010" or IR2_IN(15 DOWNTO 10)="110010"
        or IR2_IN(15 DOWNTO 10)="100101" or IR2_IN(15 DOWNTO 10)="100011") then 
    ALU2_OP_Code_OUT <= "110";
    elsif(IR2_IN(15)='1') then 
    ALU2_OP_Code_OUT <= IR2_IN(13 DOWNTO 11);
    else ALU2_OP_Code_OUT <= "111";
    end if;

    if(IR2_IN(15 DOWNTO 10)="001010") then 
    ALU2_Operand1_OUT<=PC_IN;
    elsif(IR2_IN(15 DOWNTO 12)="1001" or IR2_IN(15 DOWNTO 10)="100011") then 
    ALU2_Operand1_OUT<=SP_IN;
    else ALU2_Operand1_OUT<="0000000000000000" & registerfile(to_integer(Unsigned(IR2_IN(2 DOWNTO 0))));
    end if;

    if(IR2_IN(15 DOWNTO 10)="111101" or IR2_IN(15 DOWNTO 10)="111001") then
    ALU2_Operand2_OUT<= "0000000000000000000000000" & IR2_IN(9 DOWNTO 3);
    elsif(IR2_IN(15 DOWNTO 13)="010" or IR2_IN(15 DOWNTO 10)="100101") then 
    ALU2_Operand2_OUT<=PC_IN;
    elsif(IR2_IN(15 DOWNTO 10)="100011" or IR2_IN(15 DOWNTO 10)="100100") then
    ALU2_Operand2_OUT<="0000000000000000" & registerfile(to_integer(Unsigned(IR2_IN(2 DOWNTO 0))));
    else ALU2_Operand2_OUT<="0000000000000000" & registerfile(to_integer(Unsigned(IR2_IN(5 DOWNTO 3))));
    end if;
    
    if(IR2_IN(15 DOWNTO 14)="11") then 
    Two_Operand_Instr2_Flag_OUT<='1';
    else Two_Operand_Instr2_Flag_OUT<='0';
    end if;

    if(IR2_IN(15 DOWNTO 10)="100101" or IR2_IN(15 DOWNTO 10)="100110" or IR2_IN(15 DOWNTO 10)="100111") then 
    One_or_Two2_OUT <= '1';
    else One_or_Two2_OUT<='0';
    end if;

    if(IR2_IN(15 DOWNTO 10)="000110") then 
    SETC2<='1';
    else SETC2<='0';
    end if; 

    if(IR2_IN(15 DOWNTO 10)="000100") then 
    CLRC2<='1';
    else CLRC2<='0';
    end if;

    if(IR2_IN(15 DOWNTO 10)="100100" or IR2_IN(15 DOWNTO 10)="001011") then 
    Memory_Read2_OUT<='1';
    else Memory_Read2_OUT<='0';
    end if;

    if(IR2_IN(15 DOWNTO 10)="001100" or IR2_IN(15 DOWNTO 10)="100011") then 
    Memory_Write2_OUT<='1';
    else Memory_Write2_OUT<='0';
    end if;

    if(IR2_IN(15 DOWNTO 10)="100100" or IR2_IN(15 DOWNTO 10)="100110" or IR2_IN(15 DOWNTO 10)="100111") then -- pop ret rti
    ALU_As_Address2_OUT<='1';
    else ALU_As_Address2_OUT<='0';
    end if;

    if(IR2_IN(15 DOWNTO 10)="100011" or IR2_IN(15 DOWNTO 10)="100101") then 
    SP_As_Address2_OUT<='1';
    else SP_As_Address2_OUT<='0';
    end if;

    if(IR2_IN(15 DOWNTO 10)="100101") then 
    PC_As_Data2_OUT<='1';
    else PC_As_Data2_OUT<='0';
    end if;

    if(IR2_IN(15 DOWNTO 14)="11" or IR2_IN(15 DOWNTO 14)="00") then 
    Rsrc_Idx2_OUT<=IR2_IN(2 DOWNTO 0);
    end if;

    if(IR2_IN(15 DOWNTO 13)="110" or IR2_IN(15 DOWNTO 13)="000" or IR2_IN(15 DOWNTO 13)="001") then 
    Rdst_Idx2_OUT<=IR2_IN(5 DOWNTO 3);
    elsif(IR2_IN(15 DOWNTO 13)="100" or IR2_IN(15 DOWNTO 13)="010") then 
    Rdst_Idx2_OUT<=IR2_IN(2 DOWNTO 0);
    end if;

    if(IR2_IN(15 DOWNTO 12)="1001" or IR2_IN(15 DOWNTO 10)="100011") then 
    Enable_SP2_OUT<='1';
    else Enable_SP2_OUT<='0';
    end if;

    if(IR2_IN(15 DOWNTO 11)="00101" or IR2_IN(15 DOWNTO 10)="100100") then 
    Mem_or_ALU2_OUT<='1';
    else Mem_or_ALU2_OUT<='0';
    end if;

    if(IR2_IN(15 DOWNTO 10)="000000" or IR2_IN(15 DOWNTO 10)="000110" or IR2_IN(15 DOWNTO 10)="000100" or IR2_IN(15 DOWNTO 10)="001001"
       or IR2_IN(15 DOWNTO 10)="100011" or IR2_IN(15 DOWNTO 10)="001100" or IR2_IN(15 DOWNTO 10)="100101" or IR2_IN(15 DOWNTO 11)="10011"
       or IR2_IN(15 DOWNTO 13)="010") then 
    Enable_Reg2_OUT<='0';
    else Enable_Reg2_OUT<='1';
    end if;


    END IF;
    END PROCESS;

    
END ARCHITECTURE;
