library IEEE;
use IEEE.std_logic_1164.all;

-- Generic mux used as an 32bit 2to1 mux

entity mux_bit32_2to1 is
  generic(N : integer := 32);
  port(
    i_Ain  : in std_logic_vector(N-1 downto 0);
    i_Bin  : in std_logic_vector(N-1 downto 0);
    i_Xin  : in std_logic;
    o_YD  : out std_logic_vector(N-1 downto 0));
end mux_bit32_2to1;

architecture structure of mux_bit32_2to1 is
signal xNOT : std_logic;
signal aX : std_logic_vector(N-1 downto 0);
signal bX : std_logic_vector(N-1 downto 0);
begin
  G1: for j in 0 to N-1 generate
    xNOT  <= not i_Xin;
    aX(j)  <= i_Ain(j) and xNOT;
    bX(j)  <= i_Bin(j) and i_Xin;
    o_YD(j)  <= aX(j) or bX(j);
  end generate;  
end structure;
