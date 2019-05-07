library IEEE;
use IEEE.std_logic_1164.all;

entity WB is
port(
IR1_IN, IR2_IN  : IN std_logic_vector(15 DOWNTO 0);
ALU1,ALU2,SP : in std_logic_vector(31 downto 0);
MEM          : in std_logic_vector(31 downto 0);
InPort : in std_logic_vector(15 downto 0);
S1,S2,en1SP,en2SP,enWrite1,enWrite2 : in std_logic;
reg1Index,reg2Index : in std_logic_vector(2 downto 0);
Data1,Data2 : out std_logic_vector(15 downto 0);
SPout : out std_logic_vector(31 downto 0);
Write1out,Write2out : out std_logic;
index1,index2 : out std_logic_vector(2 downto 0)
);

end WB;

architecture WB_a of WB is

begin

Data1 <= InPort when IR1_IN(15 DOWNTO 10) = "001000" else ALU1(15 downto 0) when S1 = '0' else MEM(31 downto 16);
Data2 <= InPort when IR2_IN(15 DOWNTO 10) = "001000" else ALU2(15 downto 0) when S2 = '0' else MEM(31 downto 16);

SPout <= SP when en1SP = '0' and en2SP = '0' 
else ALU1 when en1SP = '1' and en2SP = '0'
else ALU2 when en1SP = '0' and en2SP = '1'
else SP; -- l mafrod d error 2n 2 intructions 3ayzen y3dlo fel SP(Hazard)

Write1out <= enWrite1;
Write2out <= enWrite2;

index1 <= reg1Index;
index2 <= reg2Index; 


end WB_a;