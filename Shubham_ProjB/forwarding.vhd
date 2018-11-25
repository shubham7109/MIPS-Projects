library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity forwarding is
  port(
  		ex_rs_sel : in std_logic_vector(4 downto 0);
      ex_rt_sel : in std_logic_vector(4 downto 0);
		mem_write_reg_sel : in std_logic_vector(4 downto 0);
		wb_write_reg_sel : in std_logic_vector(4 downto 0);
		wb_reg_write : in std_logic;
		mem_reg_write : in std_logic;
		rs_mux_sel : out std_logic_vector(1 downto 0);
		rt_mux_sel : out std_logic_vector(1 downto 0)
			);
 end forwarding;

architecture mixed of forwarding is 

begin

rs_mux_sel <= "10" when ((ex_rs_sel = mem_write_reg_sel) and (mem_reg_write = '1')	and (not (mem_write_reg_sel = "00000"))) else
				  "01" when ((ex_rs_sel = wb_write_reg_sel) and (wb_reg_write = '1') and (not (wb_write_reg_sel = "00000"))) else
							 "00";  -- special forwarding for wb stage, reg write does not happen until next clock cycle
							 							 
rt_mux_sel <= "10" when ((ex_rt_sel = mem_write_reg_sel) and (mem_reg_write = '1') and (not (mem_write_reg_sel = "00000"))) else
				  "01" when ((ex_rt_sel = wb_write_reg_sel) and (wb_reg_write = '1') and (not (wb_write_reg_sel = "00000"))) else
							 "00";

end mixed;