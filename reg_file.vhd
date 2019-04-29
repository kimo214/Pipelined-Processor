library IEEE;
use IEEE.std_logic_1164.all;

entity reg_file is
generic (n: integer := 16);
port(
reg_output1,reg_output2 : out std_logic_vector(n-1 downto 0);
reg_input1,reg_input2 : in std_logic_vector(n-1 downto 0);
select_source1,select_source2,select_dest1,select_dest2 : in std_logic_vector(2 downto 0);
en_WB1,en_WB2,clk,rst : in std_logic
);
end reg_file;

architecture a_reg_file of reg_file is
signal output0  : std_logic_vector(n-1 downto 0);
signal output1  : std_logic_vector(n-1 downto 0);
signal output2  : std_logic_vector(n-1 downto 0);
signal output3  : std_logic_vector(n-1 downto 0);
signal output4  : std_logic_vector(n-1 downto 0);
signal output5  : std_logic_vector(n-1 downto 0);
signal output6  : std_logic_vector(n-1 downto 0);
signal output7  : std_logic_vector(n-1 downto 0);
signal dest_S   : std_logic_vector(7 downto 0);
signal dest_S1   : std_logic_vector(7 downto 0);
signal dest_S2   : std_logic_vector(7 downto 0);
signal reg0_in   : std_logic_vector(n-1 downto 0);
signal reg1_in   : std_logic_vector(n-1 downto 0);
signal reg2_in   : std_logic_vector(n-1 downto 0);
signal reg3_in   : std_logic_vector(n-1 downto 0);
signal reg4_in   : std_logic_vector(n-1 downto 0);
signal reg5_in   : std_logic_vector(n-1 downto 0);
signal reg6_in   : std_logic_vector(n-1 downto 0);
signal reg7_in   : std_logic_vector(n-1 downto 0);

component nRegister is
generic (n: integer := 16);
port(inputR : in std_logic_vector(n-1 downto 0);
outputR : out std_logic_vector(n-1 downto 0);
enR,clk,rstR : in std_logic
);
end component;

begin
reg_0 : nRegister generic map(n) port map(reg0_in,output0,dest_S(0),clk,rst);
reg_1 : nRegister generic map(n) port map(reg1_in,output1,dest_S(1),clk,rst);
reg_2 : nRegister generic map(n) port map(reg2_in,output2,dest_S(2),clk,rst);
reg_3 : nRegister generic map(n) port map(reg3_in,output3,dest_S(3),clk,rst);
reg_4 : nRegister generic map(n) port map(reg4_in,output4,dest_S(4),clk,rst);
reg_5 : nRegister generic map(n) port map(reg5_in,output5,dest_S(5),clk,rst);
reg_6 : nRegister generic map(n) port map(reg6_in,output6,dest_S(6),clk,rst);
reg_7 : nRegister generic map(n) port map(reg7_in,output7,dest_S(7),clk,rst);

-- Registers input
reg0_in <= reg_input1 when dest_S1(0) = '1' else reg_input2 when dest_S2(0) = '1';
reg1_in <= reg_input1 when dest_S1(1) = '1' else reg_input2 when dest_S2(1) = '1';
reg2_in <= reg_input1 when dest_S1(2) = '1' else reg_input2 when dest_S2(2) = '1';
reg3_in <= reg_input1 when dest_S1(3) = '1' else reg_input2 when dest_S2(3) = '1';
reg4_in <= reg_input1 when dest_S1(4) = '1' else reg_input2 when dest_S2(4) = '1';
reg5_in <= reg_input1 when dest_S1(5) = '1' else reg_input2 when dest_S2(5) = '1';
reg6_in <= reg_input1 when dest_S1(6) = '1' else reg_input2 when dest_S2(6) = '1';
reg7_in <= reg_input1 when dest_S1(7) = '1' else reg_input2 when dest_S2(7) = '1';

dest_S <= dest_S1 or dest_S2;

-- Channel_1 input
dest_S1 <= "00000001" when select_dest1 = "000" and en_WB1 = '1'
else "00000010" when select_dest1 = "001" and en_WB1 = '1'
else "00000100" when select_dest1 = "010" and en_WB1 = '1' 
else "00001000" when select_dest1 = "011" and en_WB1 = '1' 
else "00010000" when select_dest1 = "100" and en_WB1 = '1' 
else "00100000" when select_dest1 = "101" and en_WB1 = '1' 
else "01000000" when select_dest1 = "110" and en_WB1 = '1' 
else "10000000" when select_dest1 = "111" and en_WB1 = '1' 
else "00000000";

-- Channel_2 input
dest_S2 <= "00000001" when select_dest2 = "000" and en_WB2 = '1'
else "00000010" when select_dest2 = "001" and en_WB2 = '1'
else "00000100" when select_dest2 = "010" and en_WB2 = '1' 
else "00001000" when select_dest2 = "011" and en_WB2 = '1' 
else "00010000" when select_dest2 = "100" and en_WB2 = '1' 
else "00100000" when select_dest2 = "101" and en_WB2 = '1' 
else "01000000" when select_dest2 = "110" and en_WB2 = '1' 
else "10000000" when select_dest2 = "111" and en_WB2 = '1' 
else "00000000";

-- Channel_1 output
reg_output1 <= output0 when select_source1 = "000"
else output1 when select_source1 = "001"
else output2 when select_source1 = "010"
else output3 when select_source1 = "011"
else output4 when select_source1 = "100"
else output5 when select_source1 = "101"
else output6 when select_source1 = "110"
else output7 when select_source1 = "111";

-- Channel_2 output
reg_output2 <= output0 when select_source2 = "000"
else output1 when select_source2 = "001"
else output2 when select_source2 = "010"
else output3 when select_source2 = "011"
else output4 when select_source2 = "100"
else output5 when select_source2 = "101"
else output6 when select_source2 = "110"
else output7 when select_source2 = "111";

end a_reg_file;

