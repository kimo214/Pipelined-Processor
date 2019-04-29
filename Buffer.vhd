LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.math_real.all;

ENTITY BUF IS
    PORT (
        EXT_CLK            			: IN  STD_LOGIC;
        EXT_RST					: IN  STD_LOGIC;

	Stall          				: IN  STD_LOGIC;                    -- Needed ?
        Flush          				: IN  STD_LOGIC; 	            -- Needed ?
-------------------------------------------------------------------------------- IF/ID
	IR1_IN         				: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
	IR2_IN         				: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC_IN             			: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        SP_IN             			: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        Flags_IN          			: IN  STD_LOGIC_VECTOR (3 DOWNTO 0);

-------------------------------------------------------------------------------- ID/EX

---- For Channel 1 -> ALU 1
        NOP1_IN                           	: IN STD_LOGIC;
	Taken1_IN				: IN STD_LOGIC;                              -- For Branch instructions = 1 if taken
        ALU1_OP_Code_IN   			: IN STD_LOGIC_VECTOR  (2 DOWNTO 0);         -- Add or Sub or Shift ...
        ALU1_Operand1_IN                        : IN STD_LOGIC_VECTOR  (31 DOWNTO 0);
        ALU1_Operand2_IN                        : IN STD_LOGIC_VECTOR  (31 DOWNTO 0);
	Two_Operand_Instr1_Flag_IN              : IN STD_LOGIC;                              -- is Instruction has 2 Opernad or not
        One_or_Two1_IN                          : IN STD_LOGIC;                              -- to add , sub 1 or 2 (sp + 2, INC, ...)
	ALU1_Result_IN				: IN STD_LOGIC_VECTOR  (31 DOWNTO 0);                        

---- For Channel 2 -> ALU 2
        NOP2_IN                                 : IN STD_LOGIC;
	Taken2_IN				: IN STD_LOGIC;				     -- For Branch instructions = 1 if taken
        ALU2_OP_Code_IN   			: IN STD_LOGIC_VECTOR  (2 DOWNTO 0);         -- Add or Sub or Shift ...
        ALU2_Operand1_IN                        : IN STD_LOGIC_VECTOR  (31 DOWNTO 0);
        ALU2_Operand2_IN                        : IN STD_LOGIC_VECTOR  (31 DOWNTO 0);
	Two_Operand_Instr2_Flag_IN              : IN STD_LOGIC;                              -- is Instruction has 2 Opernad or not
        One_or_Two2_IN                          : IN STD_LOGIC;
     	ALU2_Result_IN				: IN STD_LOGIC_VECTOR  (31 DOWNTO 0);                        

-------------------------------------------------------------------------------- EX/MEM
---- For Channel 1
	Memory_Read1_IN	           		: IN STD_LOGIC;
        Memory_Write1_IN			: IN STD_LOGIC;
	ALU_As_Address1_IN		        : IN STD_LOGIC;                              -- Take the Output of the ALU as address (pop instruction)
	SP_As_Address1_IN			: IN STD_LOGIC;                              -- Take original SP as address (Push Instruction)
	PC_As_Data1_IN				: IN STD_LOGIC;				     -- Use PC as data to write in memory (Call Instruction)	

---- For Channel 2
	Memory_Read2_IN  			: IN STD_LOGIC;
        Memory_Write2_IN			: IN STD_LOGIC;
	ALU_As_Address2_IN        		: IN STD_LOGIC;                              -- Take the Output of the ALU as address (pop instruction)
	SP_As_Address2_IN			: IN STD_LOGIC;                              -- Take original SP as address (Push Instruction)
	PC_As_Data2_IN				: IN STD_LOGIC;				     -- Use PC as data to write in memory (Call Instruction)	

	Memory_Result_IN	        	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);

--------------------------------------------------------------------------------- MEM/WB
---- For Channel 1
	Rsrc_Idx1_IN				: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
	Rdst_Idx1_IN				: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
	Enable_SP1_IN				: IN STD_LOGIC;                              -- To write in SP the ALU1 value	
	Enable_Reg1_IN	                        : IN STD_LOGIC;				     -- To Know if it will write to a general register
	Mem_or_ALU1_IN				: IN STD_LOGIC;                              -- To know which value to write (Memory or ALU 1)

---- For Channel 2
	Rsrc_Idx2_IN				: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
	Rdst_Idx2_IN				: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
	Enable_SP2_IN				: IN STD_LOGIC;                              -- To write in SP the ALU2 value	
	Enable_Reg2_IN	                        : IN STD_LOGIC;				     -- To Know if it will write to a general register
	Mem_or_ALU2_IN				: IN STD_LOGIC;                              -- To know which value to write (Memory or ALU 2)

--===============================================================================================================================================
--===============================================================================================================================================

	IR1_OUT         			: OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
	IR2_OUT         			: OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC_OUT             			: OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
        SP_OUT             			: OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
        Flags_OUT          			: OUT  STD_LOGIC_VECTOR (3 DOWNTO 0);

-------------------------------------------------------------------------------- ID/EX

---- For Channel 1 -> ALU 1
        NOP1_OUT                           	: OUT STD_LOGIC;
	Taken1_OUT				: OUT STD_LOGIC;                              -- For Branch instructions = 1 if taken
        ALU1_OP_Code_OUT   			: OUT STD_LOGIC_VECTOR  (2 DOWNTO 0);         -- Add or Sub or Shift ...
        ALU1_Operand1_OUT                       : OUT STD_LOGIC_VECTOR  (31 DOWNTO 0);
        ALU1_Operand2_OUT                       : OUT STD_LOGIC_VECTOR  (31 DOWNTO 0);
	Two_Operand_Instr1_Flag_OUT             : OUT STD_LOGIC;                              -- is Instruction has 2 Opernad or not
        One_or_Two1_OUT                         : OUT STD_LOGIC;
	ALU1_Result_OUT				: OUT STD_LOGIC_VECTOR  (31 DOWNTO 0);                        

---- For Channel 2 -> ALU 2
        NOP2_OUT                                : OUT STD_LOGIC;
	Taken2_OUT				: OUT STD_LOGIC;		    	      -- For Branch instructions = 1 if taken
        ALU2_OP_Code_OUT   			: OUT STD_LOGIC_VECTOR  (2 DOWNTO 0);         -- Add or Sub or Shift ...
        ALU2_Operand1_OUT                       : OUT STD_LOGIC_VECTOR  (31 DOWNTO 0);
        ALU2_Operand2_OUT                       : OUT STD_LOGIC_VECTOR  (31 DOWNTO 0);
	Two_Operand_Instr2_Flag_OUT             : OUT STD_LOGIC;                              -- is Instruction has 2 Opernad or not
        One_or_Two2_OUT                         : OUT STD_LOGIC;
     	ALU2_Result_OUT				: OUT STD_LOGIC_VECTOR  (31 DOWNTO 0);                        

-------------------------------------------------------------------------------- EX/MEM
---- For Channel 1
	Memory_Read1_OUT	           	: OUT STD_LOGIC;
        Memory_Write1_OUT			: OUT STD_LOGIC;
	ALU_As_Address1_OUT		        : OUT STD_LOGIC;                              -- Take the Output of the ALU as address (pop instruction)
	SP_As_Address1_OUT			: OUT STD_LOGIC;                              -- Take original SP as address (Push Instruction)
	PC_As_Data1_OUT				: OUT STD_LOGIC;			      -- Use PC as Data to memory (Call instruction)

---- For Channel 2
	Memory_Read2_OUT  			: OUT STD_LOGIC;
        Memory_Write2_OUT			: OUT STD_LOGIC;
	ALU_As_Address2_OUT		        : OUT STD_LOGIC;                              -- Take the Output of the ALU as address (pop instruction)
	SP_As_Address2_OUT			: OUT STD_LOGIC;                              -- Take original SP as address (Push Instruction)
	PC_As_Data2_OUT				: OUT STD_LOGIC;			      -- Use PC as Data to memry (Call instruction)

	Memory_Result_OUT	        	: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);

--------------------------------------------------------------------------------- MEM/WB
---- For Channel 1
	Rsrc_Idx1_OUT				: OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
	Rdst_Idx1_OUT				: OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
	Enable_SP1_OUT				: OUT STD_LOGIC;                              -- To write in SP the ALU1 value	
	Enable_Reg1_OUT	                        : OUT STD_LOGIC;			      -- To Know if it will write to a general register
	Mem_or_ALU1_OUT				: OUT STD_LOGIC;                              -- To know which value to write (Memory or ALU 1)

---- For Channel 2
	Rsrc_Idx2_OUT				: OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
	Rdst_Idx2_OUT				: OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
	Enable_SP2_OUT				: OUT STD_LOGIC;                              -- To write in SP the ALU2 value	
	Enable_Reg2_OUT	                        : OUT STD_LOGIC;			      -- To Know if it will write to a general register
	Mem_or_ALU2_OUT				: OUT STD_LOGIC                               -- To know which value to write (Memory or ALU 2)

    );
END ENTITY;

ARCHITECTURE arch_BUF OF BUF IS

   SIGNAL EN : STD_LOGIC := '1';

BEGIN

IR1_REG:
ENTITY work.Register_Falling GENERIC MAP(n => 16) PORT MAP( EXT_CLK, EXT_RST, '1', IR1_IN, IR1_OUT );

IR2_REG:
ENTITY work.Register_Falling GENERIC MAP(n => 16) PORT MAP( EXT_CLK, EXT_RST, '1', IR2_IN, IR2_OUT );

PC_REG:
ENTITY work.Register_Falling GENERIC MAP(n => 32) PORT MAP( EXT_CLK, EXT_RST, '1', PC_IN, PC_OUT );

SP_REG:
ENTITY work.Register_Falling GENERIC MAP(n => 32) PORT MAP( EXT_CLK, EXT_RST, '1', SP_IN, SP_OUT );

FLAG_REG:
ENTITY work.Register_Falling GENERIC MAP(n =>  4) PORT MAP( EXT_CLK, EXT_RST, '1', Flags_IN, Flags_OUT );

---------------------------------------------------------------------------------------------------------------------------

NOP1_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', NOP1_IN, NOP1_OUT );

Taken1_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', Taken1_IN, Taken1_OUT );

ALU1_OP_CODE_REG:
ENTITY work.Register_Falling GENERIC MAP(n =>  3) PORT MAP( EXT_CLK, EXT_RST, '1', ALU1_OP_Code_IN, ALU1_OP_Code_OUT );

ALU1_OPERAND1_REG:
ENTITY work.Register_Falling GENERIC MAP(n => 32) PORT MAP( EXT_CLK, EXT_RST, '1', ALU1_Operand1_IN, ALU1_Operand1_OUT );

ALU1_OPERAND2_REG:
ENTITY work.Register_Falling GENERIC MAP(n => 32) PORT MAP( EXT_CLK, EXT_RST, '1', ALU1_Operand2_IN, ALU1_Operand2_OUT );

TWO_OPERAND_INSTR1_FLAG_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', Two_Operand_Instr1_Flag_IN, Two_Operand_Instr1_Flag_OUT );

ONE_OR_TWO1_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', One_or_Two1_IN, One_or_Two1_OUT );

ALU1_Result_REG:
ENTITY work.Register_Falling GENERIC MAP(n => 32) PORT MAP( EXT_CLK, EXT_RST, '1', ALU1_Result_IN, ALU1_Result_OUT );

-------------------------------------------------------

NOP2_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', NOP2_IN, NOP2_OUT );

Taken2_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', Taken2_IN, Taken2_OUT );

ALU2_OP_CODE_REG:
ENTITY work.Register_Falling GENERIC MAP(n =>  3) PORT MAP( EXT_CLK, EXT_RST, '1', ALU2_OP_Code_IN, ALU2_OP_Code_OUT );

ALU2_OPERAND1_REG:
ENTITY work.Register_Falling GENERIC MAP(n => 32) PORT MAP( EXT_CLK, EXT_RST, '1', ALU2_Operand1_IN, ALU2_Operand1_OUT );

ALU2_OPERAND2_REG:
ENTITY work.Register_Falling GENERIC MAP(n => 32) PORT MAP( EXT_CLK, EXT_RST, '1', ALU2_Operand2_IN, ALU2_Operand2_OUT );

TWO_OPERAND_INSTR2_FLAG_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', Two_Operand_Instr2_Flag_IN, Two_Operand_Instr2_Flag_OUT );

ONE_OR_TWO2_REG:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', One_or_Two2_IN, One_or_Two2_OUT );

ALU2_Result_REG:
ENTITY work.Register_Falling GENERIC MAP(n => 32) PORT MAP( EXT_CLK, EXT_RST, '1', ALU2_Result_IN, ALU2_Result_OUT );

-------------------------------------------------------------------------------------------------------------------------

MEM_RD1_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', Memory_Read1_IN, Memory_Read1_OUT );

MEM_WR1_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', Memory_Write1_IN, Memory_Write1_OUT );

ALU_As_Address1_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', ALU_As_Address1_IN, ALU_As_Address1_OUT );

SP_As_Address1_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', SP_As_Address1_IN, SP_As_Address1_OUT );

PC_As_Data1_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', PC_As_Data1_IN, PC_As_Data1_OUT );

-------------------------------------------------------

MEM_RD2_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', Memory_Read2_IN, Memory_Read2_OUT );

MEM_WR2_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', Memory_Write2_IN, Memory_Write2_OUT );

ALU_As_Address2_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', ALU_As_Address2_IN, ALU_As_Address2_OUT );

SP_AS_Address2_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', SP_As_Address2_IN, SP_As_Address2_OUT );

PC_As_Data2_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', PC_As_Data2_IN, PC_As_Data2_OUT );


MEM_RES_REG:
ENTITY work.Register_Falling GENERIC MAP(n => 16) PORT MAP( EXT_CLK, EXT_RST, '1', Memory_Result_IN, Memory_Result_OUT );

---------------------------------------------------------------------------------------------------------------------------

Rsrc_Idx1_REG:
ENTITY work.Register_Falling GENERIC MAP(n =>  3) PORT MAP( EXT_CLK, EXT_RST, '1', Rsrc_Idx1_IN, Rsrc_Idx1_OUT );

Rdst_Idx1_REG:
ENTITY work.Register_Falling GENERIC MAP(n =>  3) PORT MAP( EXT_CLK, EXT_RST, '1', Rdst_Idx1_IN, Rdst_Idx1_OUT );

Enable_SP1_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', Enable_SP1_IN, Enable_SP1_OUT );

Enable_Reg1_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', Enable_Reg1_IN, Enable_Reg1_OUT );

Mem_or_ALU1_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', Mem_or_ALU1_IN, Mem_or_ALU1_OUT );

----------------------------------------------------------

Rsrc_Idx2_REG:
ENTITY work.Register_Falling GENERIC MAP(n =>  3) PORT MAP( EXT_CLK, EXT_RST, '1', Rsrc_Idx2_IN, Rsrc_Idx2_OUT );

Rdst_Idx2_REG:
ENTITY work.Register_Falling GENERIC MAP(n =>  3) PORT MAP( EXT_CLK, EXT_RST, '1', Rdst_Idx2_IN, Rdst_Idx2_OUT );

Enable_SP2_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', Enable_SP2_IN, Enable_SP2_OUT );

Enable_Reg2_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', Enable_Reg2_IN, Enable_Reg2_OUT );

Mem_or_ALU2_FF:
ENTITY work.Flip_Flop PORT MAP( EXT_CLK, EXT_RST, '1', Mem_or_ALU2_IN, Mem_or_ALU2_OUT );


END ARCHITECTURE;