LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY ALU IS
    GENERIC ( n : INTEGER := 32);     
    PORT (
        Operand1        : IN  STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        Operand2	: IN  STD_LOGIC_VECTOR(n-1 DOWNTO 0);
	Operation	: IN  STD_LOGIC_VECTOR(2 DOWNTO 0); 

	Carry_OUT	: OUT STD_LOGIC;
	ALU_OUTPUT	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
    );
END ENTITY;


ARCHITECTURE arch_ALU OF ALU IS

SIGNAL ZERO_VECTOR  		: STD_LOGIC_VECTOR(n-1 DOWNTO 0) := (others => '0');
SIGNAL Op2_Int 			: INTEGER range -(2**16)-1 to (2**16)-1;
SIGNAL Adder_subtractor_Op	: STD_LOGIC;
SIGNAL Carry			: STD_LOGIC;
SIGNAL Adder_Subtractor_OUT	: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
SIGNAL En			: STD_LOGIC;

SIGNAL Left_Part_SHL		: INTEGER range 0 to 20; -- Maximum shift bits = 4
SIGNAL Right_Part_SHR		: INTEGER range 0 to 20;

BEGIN

En  <= '0' WHEN Operation = "111"	                -- ALU Enable
	ELSE '1';

Op2_Int <= TO_INTEGER(UNSIGNED(Operand2));  		-- Operand2 as Integer

Left_Part_SHL <= TO_INTEGER(UNSIGNED(Operand1(16 - 1 DOWNTO 16 - Op2_Int)));   -- 16 since shift is done on 16 bit registers
Right_Part_SHR <= TO_INTEGER(UNSIGNED(Operand1(Op2_Int - 1 DOWNTO 0)));

Adder_subtractor_Op <= '1' WHEN  Operation = "110"      -- Adder_Subtractor Operation (Add or sub)
		       ELSE '0';

ADDER_SUBTRACTOR:
ENTITY work.adder_subtractor
GENERIC MAP(n => 32)
PORT MAP(
	A     => Operand1,
	B     => Operand2,
	Cin   => '0',
	Subtract => Adder_subtractor_Op,

	sum	=> Adder_Subtractor_OUT,
	cout	=> Carry
);

-- NOT	000 
-- SHR	001
-- And	010
-- Or	011
-- Add	100
-- SHL	101
-- Sub	110
-- NoP	111

ALU_OUTPUT  <=  Adder_Subtractor_OUT WHEN (Operation = "100" or Operation = "110") and En = '1'
	   	ELSE Operand1 AND Operand2 WHEN Operation = "010" and En = '1'
	   	ELSE Operand1 OR Operand2 WHEN Operation = "011" and En = '1'
		ELSE NOT(Operand1) WHEN Operation = "000" and En = '1'
		ELSE Operand1(n - Op2_Int - 1 DOWNTO 0) & ZERO_VECTOR(Op2_Int - 1 DOWNTO 0) WHEN Operation = "101" and Op2_Int > 0 and En = '1'
		ELSE ZERO_VECTOR(Op2_Int - 1 DOWNTO 0) & Operand1(n-1 DOWNTO Op2_Int) WHEN Operation = "001" and Op2_Int > 0 and En = '1'
		ELSE Operand1 WHEN En = '1';

Carry_OUT   <=  Carry WHEN Operation = "100" or Operation = "110"
		ELSE '1'  WHEN (Operation = "101" and Left_Part_SHL > 0) or (Operation = "001" and Right_Part_SHR > 0)
		ELSE '0';

END ARCHITECTURE;