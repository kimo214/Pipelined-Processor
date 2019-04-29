LIBRARY IEEE;
USE IEEE.std_logic_1164.all;


Entity my_nadder is
  generic(n:integer :=32);
    port( aa, bb :in std_logic_vector(n-1 downto 0);
          c_cin  :in std_logic; 
          ff     :out std_logic_vector(n-1 downto 0)
          );
end entity my_nadder;

architecture a_my_nadder of my_nadder is
    signal temp:std_logic_vector(n-1 downto 0);
    begin
      f0:entity work.my_adder PORT MAP(aa(0),bb(0),c_cin,ff(0),temp(0));
      loop1: FOR i in 1 to n-1 Generate
        fx:entity work.my_adder PORT MAP (aa(i),bb(i),temp(i-1),ff(i),temp(i));
      end Generate;
      --c_cout <= temp(n-1);  
end a_my_nadder;
