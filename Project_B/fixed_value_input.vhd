library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fixed_value_input is
  port(Val_4_Adder : out std_logic_vector(31 downto 0);
		 imem_wren : out std_logic;
  	    data : out std_logic_vector(31 downto 0);
		 byteena : out std_logic_vector(3 downto 0));
 end fixed_value_input;

architecture mixed of fixed_value_input is 

begin

Val_4_Adder <= x"00000004";
imem_wren <= '0';
data <= (others => '0');
byteena <= (others => '0');

end mixed;