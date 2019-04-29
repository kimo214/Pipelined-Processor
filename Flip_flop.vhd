LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.math_real.all;

ENTITY Flip_Flop IS
    PORT(
        CLK, RST, EN    : IN  STD_LOGIC;
        Din             : IN  STD_LOGIC;
        Dout            : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE arch_Flip_Flop OF Flip_Flop IS
BEGIN

    PROCESS(CLK, RST)
    BEGIN
	IF FALLING_EDGE(CLK) THEN
      	    IF RST = '1' THEN
                Dout <= '0';
            ELSIF EN = '1' THEN
                Dout <= Din;
            END IF;
  	END IF;
    END PROCESS;

END ARCHITECTURE;
