LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.math_real.all;

ENTITY Fetch IS
    GENERIC ( n : INTEGER := 16; m : INTEGER := 10);     
    PORT (
        EXT_CLK         : IN  STD_LOGIC;
        EXT_INTR	: IN  STD_LOGIC;
	EXT_RST		: IN  STD_LOGIC; 
	
	IR1	        : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- IR1
	IR2	        : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)  -- IR2
    );
END ENTITY;

ARCHITECTURE arch_Fetch OF Fetch IS

SIGNAL ZERO_VECTOR : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
SIGNAL TWO_VECTOR  : STD_LOGIC_VECTOR(31 DOWNTO 0) := ZERO_VECTOR(31 DOWNTO 2) & "10";

SIGNAL mem_data1   : STD_LOGIC_VECTOR(n-1 DOWNTO 0);
SIGNAL mem_data2   : STD_LOGIC_VECTOR(n-1 DOWNTO 0);

SIGNAL PC_IN       : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
SIGNAL PC_OUT      : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
 
BEGIN


-- PC Adder
PC_Adder:
ENTITY work.my_nadder
GENERIC MAP(n => 32)
PORT MAP(
	aa    => TWO_VECTOR,
	bb    => PC_OUT,
	c_cin => '0',
	ff    => PC_IN
);	

-- Program Counter Register
Prog_Counter:
ENTITY work.Register_Falling
GENERIC MAP(n => 32)
PORT MAP(
	CLK  => EXT_CLK,
	RST  => EXT_RST,
	EN   => '1',           -- <--- Stall
	Din  => PC_IN,
	Dout => PC_OUT
);

-- Instruction memory
Instruction_Memory:
ENTITY work.memory_instr
GENERIC MAP(n => 16, m => 10)
PORT MAP(
	EXT_CLK,
	PC_OUT(m-1 downto 0),
	mem_data1,
	mem_data2
);


PROCESS(EXT_CLK)
BEGIN
	-- Handle other cases where IR not from RAM (INTR)
	IF(RISING_EDGE(EXT_CLK)) THEN
		IR1 <= mem_data1;
		IR2 <= mem_data2;
	END IF;
END PROCESS;

END ARCHITECTURE;