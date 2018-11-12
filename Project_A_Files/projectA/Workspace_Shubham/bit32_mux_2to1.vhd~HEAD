library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bit32_mux_2to1 is
  port( i_0, i_1 : in std_logic_vector(31 downto 0);
  		i_sel : in std_logic;
  	    o_mux : out std_logic_vector(31 downto 0));
 end bit32_mux_2to1;

architecture mixed of bit32_mux_2to1 is 

begin

with i_sel select
	o_mux <= 	i_1 when '1',
				i_0 when others;

end mixed;