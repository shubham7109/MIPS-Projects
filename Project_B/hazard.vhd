library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity Hazard is -- DO NOT modify the interface (entity)
    Port ( 	
			control_jump	:	in STD_LOGIC;
			id_branch : in std_logic;
			branch_taken : in std_logic;
			id_ex_memRead : in std_logic;
			id_ex_regRt : in std_logic_vector(4 downto 0);
			if_id_regRs : in std_logic_vector(4 downto 0);
			if_id_regRt : in std_logic_vector(4 downto 0);
			ex_writRegSel : in std_logic_vector(4 downto 0);
			pc_stall 		: out STD_LOGIC;
			if_id_stall 	: out STD_LOGIC;
			if_id_flush		: out STD_LOGIC;
			id_ex_stall		: out STD_LOGIC;
			id_ex_flush		: out STD_LOGIC;
			ex_mem_stall	: out STD_LOGIC;
			ex_mem_flush	: out STD_LOGIC;
			mem_wb_stall	: out STD_LOGIC;
			mem_wb_flush	: out STD_LOGIC
			);
end Hazard;


architecture mixed of Hazard is 
signal temp_stall : std_logic;
begin	
			id_ex_stall		<= '0';
			ex_mem_stall	<= '0';
			ex_mem_flush	<= '0';
			mem_wb_stall	<= '0';
			mem_wb_flush	<= '0';


if_id_flush <= '1' when control_jump = '1' or (branch_taken = '1' and not (id_branch = '1' and (not (ex_writRegSel = "00000")) and ((ex_writRegSel = if_id_regRs) or (ex_writRegSel = if_id_regRt)))) else
					'0';
	
temp_stall <= '1' when (id_ex_memRead = '1' and (not (id_ex_regRt = "00000")) and ((id_ex_regRt = if_id_regRs) or (id_ex_regRt = if_id_regRt))) or (id_branch = '1' and (not (ex_writRegSel = "00000")) and ((ex_writRegSel = if_id_regRs) or (ex_writRegSel = if_id_regRt))) else
				'0';
				
pc_stall <= temp_stall;
if_id_stall <= temp_stall;
id_ex_flush <= temp_stall;				

end mixed;