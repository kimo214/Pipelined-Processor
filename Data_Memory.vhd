LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.math_real.all;

ENTITY memory_data IS
    GENERIC ( n : INTEGER := 16; m : INTEGER := 10 );     -- n -> CELL SIZE ; m -> ADDRESS SIZE   IN TERMS OF BITS
    PORT (
        CLK         : IN  STD_LOGIC;
	RD	    : IN  STD_LOGIC;           			-- Read Enable
	WR	    : IN  STD_LOGIC;				-- Write Enable
        PC_Data	    : IN  STD_LOGIC;				-- IF I need to Write PC to memory (32 bit)

	Address     : IN  STD_LOGIC_VECTOR(m-1 DOWNTO 0); 
	WriteData   : IN  STD_LOGIC_VECTOR( 31 DOWNTO 0);

	ReadData    : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0)
    );
END ENTITY;


ARCHITECTURE arch_memory_data OF memory_data IS

    TYPE memory IS ARRAY(0 TO (2**m)-1) OF STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    SIGNAL data_memory : memory :=  (OTHERS => (OTHERS => '0'));

BEGIN
	
PROCESS(CLK, RD, WR)
BEGIN
	IF(Rising_EDGE(CLK) and WR ='1') THEN          		  				-- Write in Falling Edge
		IF(PC_Data = '1') THEN									-- Little Endian 
			data_memory(TO_INTEGER(UNSIGNED(Address)))   <= WriteData(31 DOWNTO 16);        -- Higher Byte of PC 
			data_memory(TO_INTEGER(UNSIGNED(Address))-1) <= WriteData(15 DOWNTO  0);	-- Lower Byte of PC
		ELSE
			data_memory(TO_INTEGER(UNSIGNED(Address)))   <= WriteData(15 DOWNTO  0);        -- Normal Write 16 bits
		END IF;
		ReadData <= (others => '0');
	ELSIF(RD = '1') THEN
		ReadData(15 DOWNTO  0) <= data_memory(TO_INTEGER(UNSIGNED(Address)));
		ReadData(31 DOWNTO 16) <= data_memory(TO_INTEGER(UNSIGNED(Address))+1);
	ELSE
		ReadData <= (others => '0');
	END IF;
END PROCESS;

END ARCHITECTURE;