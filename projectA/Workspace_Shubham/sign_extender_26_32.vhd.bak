library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sign_extender_26_32 is
  port(i_to_extend : in std_logic_vector(25 downto 0);
  	   o_extended : out std_logic_vector(31 downto 0));
 end sign_extender_26_32;

architecture mixed of sign_extender_26_32 is 

begin

o_extended(25 downto 0) <= i_to_extend;

with i_to_extend(25) select
	o_extended(31 downto 26) <= 	"111111" when '1',
					"000000" when others;

end mixed;