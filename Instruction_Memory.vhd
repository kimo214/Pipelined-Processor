LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.math_real.all;

ENTITY memory_instr IS
    GENERIC ( n : INTEGER := 16; m : INTEGER := 20 );     -- n -> CELL SIZE ; m -> ADDRESS SIZE   IN TERMS OF BITS
    PORT (
        CLK         : IN  STD_LOGIC;
        Address     : IN  STD_LOGIC_VECTOR(m-1 DOWNTO 0); 
	Dout1	    : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- IR1
	Dout2	    : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)  -- IR2
    );
END ENTITY;


ARCHITECTURE arch_memory_instr OF memory_instr IS

    TYPE memory IS ARRAY(0 TO (2**m)-1) OF STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    SIGNAL instruction_memory : memory :=  (OTHERS => (OTHERS => '0'));

BEGIN
	
	Dout1 <= instruction_memory(TO_INTEGER(UNSIGNED(Address)));   -- IR1
 	Dout2 <= instruction_memory(TO_INTEGER(UNSIGNED(Address))+1); -- IR2
    
END ARCHITECTURE;