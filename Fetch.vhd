LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.math_real.all;

ENTITY Fetch IS
    GENERIC ( n : INTEGER := 16; m : INTEGER := 10);     
    PORT (
        EXT_CLK        		: IN  STD_LOGIC;
        EXT_INTR		: IN  STD_LOGIC;
		
	PC_IN			: IN STD_LOGIC_VECTOR(31 DOWNTO 0);

	IR1	       	 	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- IR1
	IR2	       	 	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)  -- IR2
    );
END ENTITY;

ARCHITECTURE arch_Fetch OF Fetch IS

SIGNAL ZERO_VECTOR : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');

SIGNAL mem_data1   : STD_LOGIC_VECTOR(n-1 DOWNTO 0);
SIGNAL mem_data2   : STD_LOGIC_VECTOR(n-1 DOWNTO 0);
 
BEGIN

-- Instruction memory
Instruction_Memory:
ENTITY work.memory_instr
GENERIC MAP(n => 16, m => 10)
PORT MAP(
	EXT_CLK,
	PC_IN(m-1 downto 0),
	mem_data1,
	mem_data2
);


IR1 <= mem_data1;
IR2 <= mem_data2;

END ARCHITECTURE;