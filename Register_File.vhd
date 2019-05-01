LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.math_real.all;

ENTITY Register_File IS
    GENERIC ( n : INTEGER := 16);
    PORT (
        Reg_CLK         : IN  STD_LOGIC;
        Reg_RST		: IN  STD_LOGIC;

	EnWrite1	: IN  STD_LOGIC;
	EnWrite2	: IN  STD_LOGIC;
	Rdst_Idx1	: IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
	Rdst_Idx2	: IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
	Data1		: IN  STD_LOGIC_VECTOR(n-1 DOWNTO 0);
	Data2		: IN  STD_LOGIC_VECTOR(n-1 DOWNTO 0);

	Reg1_OUT	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
	Reg2_OUT	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
	Reg3_OUT	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
	Reg4_OUT	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
	Reg5_OUT	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
	Reg6_OUT	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
	Reg7_OUT	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
	Reg8_OUT	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE arch_register_file OF Register_File IS

    TYPE RegFIle IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    SIGNAL RegisterFile : RegFIle :=  (OTHERS => (OTHERS => '0'));

BEGIN

Write_Logic:	
PROCESS(Reg_CLK, Reg_RST)
BEGIN
	IF(Falling_Edge(Reg_CLK)) THEN
		IF(Reg_RST = '1') THEN
			RegisterFile <= (OTHERS => (OTHERS => '0'));
		ELSIF((EnWrite1 = '1' and EnWrite2 = '1' and Rdst_Idx1 = Rdst_Idx2) or (EnWrite1 = '0' and EnWrite2 = '1')) THEN
			RegisterFile(TO_INTEGER(UNSIGNED(Rdst_Idx2))) <= Data2;
		ELSIF(EnWrite1 = '1') THEN
			RegisterFile(TO_INTEGER(UNSIGNED(Rdst_Idx1))) <= Data1;
		END IF;
	END IF;

END PROCESS;

Reg1_OUT <= RegisterFile(0);
Reg2_OUT <= RegisterFile(1);
Reg3_OUT <= RegisterFile(2);
Reg4_OUT <= RegisterFile(3);
Reg5_OUT <= RegisterFile(4);
Reg6_OUT <= RegisterFile(5);
Reg7_OUT <= RegisterFile(6);
Reg8_OUT <= RegisterFile(7);
    
END ARCHITECTURE;