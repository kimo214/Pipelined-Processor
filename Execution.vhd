LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.math_real.all;

ENTITY Execution IS
    GENERIC ( n : INTEGER := 16);
    PORT (
	
    IR1_IN         		                : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    IR2_IN         			            : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);

	SP					  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	IR1_IN_NXT							: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);		-- IR1 of the next packet
	INPUT_PORT							: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
-----------------------------------------------------------------------------------	
	Flag_Reg		:	IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
	dummy_CLK		:	IN  STD_LOGIC;
	ALU_As_Address1		:	IN  STD_LOGIC;
	SP_As_Address1		:	IN  STD_LOGIC;
	SET_Carry1		:	IN  STD_LOGIC;				--**** ADD TO BUFFER
	CLR_Carry1		:	IN  STD_LOGIC;				--**** ADD TO BUFFER

	ALU1_Operation_Code	:	IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);
	
	Operand1_ALU1		:	IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
	Operand2_ALU1		:	IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	Two_Operand_Flag1	:	IN  STD_LOGIC;
	One_Or_Two_Flag1	:	IN  STD_LOGIC;				-- 0 --> 1  or 1 --> 2
	

	ALU1_JMP_DST		:   OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	Taken1_OUT			:   INOUT STD_LOGIC;	
	ALU1_OUT		:	OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

------------------------------------------------------------------------------------
	ALU_As_Address2		:	IN  STD_LOGIC;
	SP_As_Address2		:	IN  STD_LOGIC;
	SET_Carry2		:	IN  STD_LOGIC;
	CLR_Carry2		:	IN  STD_LOGIC;

	ALU2_Operation_Code	:	IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);
	Operand1_ALU2		:	IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
	Operand2_ALU2		:	IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	Two_Operand_Flag2	:	IN  STD_LOGIC;
	One_Or_Two_Flag2	:	IN  STD_LOGIC;				-- 0 --> 1  or 1 --> 2

	ALU2_JMP_DST		:   OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	Taken2_OUT			:   OUT  STD_LOGIC;
	ALU2_OUT		:	OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

	OUT_PORT			: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	Flags_OUT		:	OUT STD_LOGIC_VECTOR( 2 DOWNTO 0)
    );
END ENTITY;


ARCHITECTURE arch_Execution OF Execution IS

SIGNAL ZERO_VECTOR	: STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');

SIGNAL ALU1_Operand1    : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
SIGNAL ALU2_Operand1    : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');

SIGNAL ALU1_Operand2	: STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
SIGNAL ALU2_Operand2	: STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');


SIGNAL ALU1_Cout	: STD_LOGIC;
SIGNAL ALU1_Result	: STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
SIGNAL ALU2_Cout	: STD_LOGIC;
SIGNAL ALU2_Result	: STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');

SIGNAL new_Flags	: STD_LOGIC_VECTOR( 2 DOWNTO 0) := "000";

SIGNAL ALU1_Enable	: STD_LOGIC;
SIGNAL ALU2_Enable	: STD_LOGIC;

SIGNAL Arithmatic_Shift1 : STD_LOGIC;          -- IF operation is aritmatic(add, sub) or shift
SIGNAL Arithmatic_Shift2 : STD_LOGIC;

BEGIN

ALU1_Enable <= '0' WHEN ALU1_Operation_Code = "111"
		ELSE '1';
ALU2_Enable <= '0' WHEN ALU2_Operation_Code = "111"
		ELSE '1';

Arithmatic_Shift1 <= '1' WHEN ALU1_Operation_Code = "001" or ALU1_Operation_Code = "100" or ALU1_Operation_Code = "101" or ALU1_Operation_Code = "110"
					ELSE '0';
Arithmatic_Shift2 <= '1' WHEN ALU2_Operation_Code = "001" or ALU2_Operation_Code = "100" or ALU2_Operation_Code = "101" or ALU2_Operation_Code = "110"
					ELSE '0';

ALU1:
ENTITY work.ALU
GENERIC MAP(n => 32)
PORT MAP(
	Operand1   => ALU1_Operand1,
	Operand2   => ALU1_Operand2,  
	Operation  => ALU1_Operation_Code,
	
	Carry_OUT  => ALU1_Cout,
	ALU_OUTPUT => ALU1_Result
);

ALU2:
ENTITY work.ALU
GENERIC MAP(n => 32)
PORT MAP(
	Operand1   => ALU2_Operand1,
	Operand2   => ALU2_Operand2,  
	Operation  => ALU2_Operation_Code,

	Carry_OUT  => ALU2_Cout,
	ALU_OUTPUT => ALU2_Result
);

	ALU1_Operand1 <= ZERO_VECTOR(15 DOWNTO 0) & IR2_IN when IR1_IN(15 DOWNTO 10) = "001010"
				else SP when SP_As_Address1 = '1' or ALU_As_Address1 = '1'
				else Operand1_ALU1;
	ALU2_Operand1 <= ZERO_VECTOR(15 DOWNTO 0) & IR1_IN_NXT when IR2_IN(15 DOWNTO 10) = "001010"
				else SP when SP_As_Address2 = '1' or ALU_As_Address2 = '1'
				else Operand1_ALU2;

	ALU1_Operand2 <= Operand2_ALU1 when Two_Operand_Flag1 = '1' 
		else ZERO_VECTOR(31 DOWNTO 2) & "10" when One_Or_Two_Flag1 = '1'
		else ZERO_VECTOR(31 DOWNTO 1) & '1' when One_Or_Two_Flag1 = '0';

	ALU2_Operand2 <= Operand2_ALU2 when Two_Operand_Flag2 = '1'
		else ZERO_VECTOR(31 DOWNTO 2) & "10" when One_Or_Two_Flag2 = '1'
		else ZERO_VECTOR(31 DOWNTO 1) & '1' when One_Or_Two_Flag2 = '0';


FLAGS_LOGIC:
PROCESS(dummy_CLK, ALU1_Enable, ALU2_Enable, ALU1_Cout, ALU2_Cout, ALU1_Result, ALU2_Result, SET_Carry1, SET_Carry2, CLR_Carry1, CLR_Carry2)
BEGIN
--	   2  1  0	
-- Flags   C  N  Z

	-- Check on Ch2 then check on Ch1
	-- SP isnt an operand because operations on SP dont affect flags 
	-- Zero Flag
	IF(SP_As_Address2 = '0' and ALU_As_Address2 = '0' and ALU2_Enable = '1' and ALU2_Result(15 downto 0) = ZERO_VECTOR(15 downto 0)) THEN  -- Result is 0
		new_Flags(0) <= '1';
	ELSIF(SP_As_Address2 = '0' and ALU_As_Address2 = '0' and ALU2_Enable = '1') THEN
		new_Flags(0) <= '0';      
	ELSIF(SP_As_Address1 = '0' and ALU_As_Address1 = '0' and ALU1_Enable = '1' and ALU1_Result(15 downto 0) = ZERO_VECTOR(15 downto 0)) THEN
		new_Flags(0) <= '1';
	ELSIF(SP_As_Address1 = '0' and ALU_As_Address1 = '0' and ALU1_Enable = '1') THEN
		new_Flags(0) <= '0';
	ELSE
		new_Flags(0) <= Flag_Reg(0);
	END IF;
	-- Negative FLag
	IF(SP_As_Address2 = '0' and ALU_As_Address2 = '0' and ALU2_Enable = '1' and ALU2_Result(31) = '1') THEN
		new_Flags(1) <= '1';
	ELSIF(SP_As_Address2 = '0' and ALU_As_Address2 = '0' and ALU2_Enable = '1') THEN
		new_Flags(1) <= '0';
	ELSIF(SP_As_Address1 = '0' and ALU_As_Address1 = '0' and ALU1_Enable = '1' and ALU1_Result(31) = '1') THEN
		new_Flags(1) <= '1';
	ELSIF(SP_As_Address1 = '0' and ALU_As_Address1 = '0' and ALU1_Enable = '1') THEN
		new_Flags(1) <= '0';
	ELSE
		new_Flags(1) <= Flag_Reg(1);
	END IF;
	-- Carry Flag
	IF((SP_As_Address2 = '0' and ALU_As_Address2 = '0' and Arithmatic_Shift2 = '1' and ALU2_Cout = '1') or SET_Carry2 = '1') THEN
		new_Flags(2) <= '1';
	ELSIF((SP_As_Address2 = '0' and ALU_As_Address2 = '0' and Arithmatic_Shift2 = '1' and ALU2_Cout = '0') or CLR_Carry2 = '1') THEN
		new_Flags(2) <= '0';
	ELSIF((SP_As_Address1 = '0' and ALU_As_Address1 = '0' and Arithmatic_Shift1 = '1' and ALU1_Cout = '1') or SET_Carry1 = '1') THEN
		new_Flags(2) <= '1';
	ELSIF((SP_As_Address1 = '0' and ALU_As_Address1 = '0' and Arithmatic_Shift1 = '1' and ALU1_Cout = '0') or CLR_Carry1 = '1') THEN
		new_Flags(2) <= '0';
	ELSE
		new_Flags(2) <= Flag_Reg(2);
	END IF;

END PROCESS;

-------------------------------------------------------------------------------------------------------------------------------
--- Jumps
ALU1_JMP_DST <= Operand1_ALU1(15 DOWNTO 0) when (IR1_IN(15 DOWNTO 11) = "01011")  -- Check on OLD FLAGS
			or ((IR1_IN(15 DOWNTO 11) = "01000") and Flag_Reg(0) = '1')		-- JZ  Instruction  
			or ((IR1_IN(15 DOWNTO 11) = "01001") and Flag_Reg(1) = '1')		-- JN  Instruction
			or ((IR1_IN(15 DOWNTO 11) = "01010") and Flag_Reg(2) = '1')		-- JC  Instruction
			else Operand2_ALU1(15 DOWNTO 0);								-- Call Instruction

Taken1_OUT <= '1' when (IR1_IN(15 DOWNTO 11) = "01011")   					-- JMP Instruction
		or ((IR1_IN(15 DOWNTO 11) = "01000") and Flag_Reg(0) = '1')			-- JZ  Instruction
		or ((IR1_IN(15 DOWNTO 11) = "01001") and Flag_Reg(1) = '1')			-- JN  Instruction
		or ((IR1_IN(15 DOWNTO 11) = "01010") and Flag_Reg(2) = '1')			-- JC  Instruction
		or (IR1_IN(15 DOWNTO 10) = "100101")								-- Call Instruction
		else '0';



ALU2_JMP_DST <= Operand1_ALU2(15 DOWNTO 0) when (IR2_IN(15 DOWNTO 11) = "01011")-- JMP Instruction 
			or ((IR2_IN(15 DOWNTO 11) = "01000") and new_Flags(0) = '1')		-- JZ  Instruction
			or ((IR2_IN(15 DOWNTO 11) = "01001") and new_Flags(1) = '1')		-- JN  Instruction
			or ((IR2_IN(15 DOWNTO 11) = "01010") and new_Flags(2) = '1')		-- JC  Instruction
			else Operand2_ALU2(15 DOWNTO 0);									-- Call Instruction

Taken2_OUT <= '1' when (IR2_IN(15 DOWNTO 11) = "01011")   				-- JMP Instruction
		or ((IR2_IN(15 DOWNTO 11) = "01000") and new_Flags(0) = '1')	-- JZ  Instruction
		or ((IR2_IN(15 DOWNTO 11) = "01001") and new_Flags(1) = '1')	-- JN  Instruction
		or ((IR2_IN(15 DOWNTO 11) = "01010") and new_Flags(2) = '1')	-- JC  Instruction
		or (IR2_IN(15 DOWNTO 10) = "100101")							-- Call Instruction
		else '0';

-------------------------------------------------------------------------------------------------------------------

OUT_PORT <= ALU2_Operand1(15 DOWNTO 0) when IR2_IN(15 DOWNTO 10) = "001001" and Taken1_OUT = '0'
			else ALU1_Operand1(15 DOWNTO 0) when IR1_IN(15 DOWNTO 10) = "001001" and IR2_IN(15 DOWNTO 10) /= "001001" 
			ELSE INPUT_PORT;
----------------------------------------------------------------------------------------------------------------------
Flags_OUT <= new_Flags;
ALU1_OUT <= ALU1_Result;
ALU2_OUT <= ALU2_Result;

END ARCHITECTURE;