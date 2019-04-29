LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

Entity my_adder is
    port( a,b,cin :in std_logic;
          f   :out std_logic;
          cout:out std_logic);
end entity my_adder;

architecture a_my_adder of my_adder is
    begin
        f <= a xor b xor cin;
        cout <= (a and b) or (cin and (a xor b));
    end a_my_adder;