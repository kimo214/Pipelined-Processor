LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.math_real.all;

ENTITY Register_Falling IS
    GENERIC(n: INTEGER := 16);
    PORT(
        CLK, RST, EN    : IN  STD_LOGIC;
        Din             : IN  STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        Dout            : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE arch_Register_Falling OF Register_Falling IS
BEGIN

    PROCESS(CLK, RST)
    BEGIN
        IF FALLING_EDGE(CLK) THEN
            IF RST = '1' THEN
                Dout <= (OTHERS => '0');
            ELSIF EN = '1' THEN
                Dout <= Din;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE;