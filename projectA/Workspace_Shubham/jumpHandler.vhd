library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity jumpHandler is
  port(
		i_shifted_j_addr : in std_logic_vector(31 downto 0);
		i_PCplusFour31_28 : in std_logic_vector(3 downto 0);
  	   o_J_Addr : out std_logic_vector(31 downto 0));
 end jumpHandler;

architecture mixed of jumpHandler is 

begin
	o_J_Addr(27 downto 0) <= i_shifted_j_addr(27 downto 0);
	o_J_Addr(31 downto 28) <= i_PCplusFour31_28(3 downto 0);
end mixed;