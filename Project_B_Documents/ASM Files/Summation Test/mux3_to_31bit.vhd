library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux3_to_31bit is
  port(  i_00 : in std_logic_vector(31 downto 0);
			i_01 : in std_logic_vector(31 downto 0);
			i_10 : in std_logic_vector(31 downto 0);
  		   i_sel : in std_logic_vector(1 downto 0);
  	    o_mux : out std_logic_vector(31 downto 0));
 end mux3_to_31bit;

architecture mixed of mux3_to_31bit is 

begin

with i_sel select
	o_mux <= 	i_00 when "00",
				   i_01 when "01",
			   	i_10 when others;
				

end mixed;