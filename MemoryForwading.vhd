LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.math_real.all;

ENTITY MemoryForwarding IS
PORT(

-------------------------------------  Input Bits  ----------------------------------------
    IR1                    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    IR2                    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
------------------------------------- Output Bits  ----------------------------------------
    MEM_Forwarding         : OUT  STD_LOGIC
);
end MemoryForwarding;

architecture arch_MEM_Forwarding OF MemoryForwarding IS

begin
MEM_Forwarding <= '1' when (IR1(15 DOWNTO 10) = "100100"
    and ( --pop for previous channel 2
        (IR2(15 DOWNTO 12) = "1000" and IR2(2 DOWNTO 0) = IR1(2 DOWNTO 0)) or --not,inc,dec,push
        (IR2(15 DOWNTO 13) = "110" and (IR2(5 DOWNTO 3) = IR1(2 DOWNTO 0) or IR2(2 DOWNTO 0) = IR1(2 DOWNTO 0))) or --add,sub,and,or
        (IR2(15 DOWNTO 10) = "001100" and (IR2(5 DOWNTO 3) = IR1(2 DOWNTO 0) or IR2(2 DOWNTO 0) = IR1(2 DOWNTO 0))) or --std
        (IR2(15 DOWNTO 10) = "001011" and IR2(2 DOWNTO 0) = IR1(2 DOWNTO 0)) or --ldd
        (IR2(15 DOWNTO 10) = "001001" and IR2(5 DOWNTO 3) = IR1(2 DOWNTO 0)) or --out
        (IR2(15 DOWNTO 13) = "010" and IR2(2 DOWNTO 0) = IR1(2 DOWNTO 0)) or --jz,jn,jc,jmp
        (IR2(15 DOWNTO 10) = "100101" and IR2(2 DOWNTO 0) = IR1(2 DOWNTO 0)) or --call
        (IR2(15 DOWNTO 10) = "000010" and IR2(2 DOWNTO 0) = IR1(2 DOWNTO 0)) or --mov
        (IR2(15 DOWNTO 13) = "111" and IR2(2 DOWNTO 0) = IR1(2 DOWNTO 0)) --shl,shr
        )
    ) or (IR1(15 DOWNTO 10) = "001011"
    and ( --ldd for previous channel 2
        (IR2(15 DOWNTO 12) = "1000" and IR2(2 DOWNTO 0) = IR1(5 DOWNTO 3)) or --not,inc,dec,push
        (IR2(15 DOWNTO 13) = "110" and (IR2(5 DOWNTO 3) = IR1(5 DOWNTO 3) or IR2(2 DOWNTO 0) = IR1(5 DOWNTO 3))) or --add,sub,and,or
        (IR2(15 DOWNTO 10) = "001100" and (IR2(5 DOWNTO 3) = IR1(5 DOWNTO 3) or IR2(2 DOWNTO 0) = IR1(5 DOWNTO 3))) or --std
        (IR2(15 DOWNTO 10) = "001011" and IR2(2 DOWNTO 0) = IR1(5 DOWNTO 3)) or --ldd
        (IR2(15 DOWNTO 10) = "001001" and IR2(5 DOWNTO 3) = IR1(5 DOWNTO 3)) or --out
        (IR2(15 DOWNTO 13) = "010" and IR2(2 DOWNTO 0) = IR1(5 DOWNTO 3)) or --jz,jn,jc,jmp
        (IR2(15 DOWNTO 10) = "100101" and IR2(2 DOWNTO 0) = IR1(5 DOWNTO 3)) or --call
        (IR2(15 DOWNTO 10) = "000010" and IR2(2 DOWNTO 0) = IR1(5 DOWNTO 3)) or --mov
        (IR2(15 DOWNTO 13) = "111" and IR2(2 DOWNTO 0) = IR1(5 DOWNTO 3)) --shl,shr
        )
    )
    else '0'

end arch_MEM_Forwarding;
