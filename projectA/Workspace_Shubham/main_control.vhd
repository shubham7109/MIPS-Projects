library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity main_control is
  port( i_instruction : in std_logic_vector(31 downto 0);
  	    o_reg_dest : out std_logic;
  	    o_jump : out std_logic;
  	    o_branch : out std_logic;
  	    o_mem_to_reg : out std_logic;
  	    o_ALU_op : out std_logic_vector(3 downto 0);
  	    o_mem_write : out std_logic;
  	    o_ALU_src : out std_logic;
  	    o_reg_write : out std_logic
  	    );
 end main_control;

architecture mixed of main_control is 


	signal op_code : std_logic_vector(5 downto 0);
	signal func_code : std_logic_vector(5 downto 0);

begin


op_code <= i_instruction(31 downto 26);
func_code <= i_instruction(5 downto 0);

process(op_code, func_code)
begin

	case op_code is -- select instruction cases based on the instruction's OP code
	
		when "000000" => -- R-Type (must check function code)
			case func_code is
				when "100000" => -- ADD
					o_reg_dest <= '1'; -- write to rd
			  	    o_jump <= '0';
			  	    o_branch <= '0'; 
			  	    o_mem_to_reg <= '0'; -- write ALU output to reg file
			  	    o_ALU_op <= "0000"; -- addition operation in ALU
			  	    o_mem_write <= '0'; -- don't write to memory
			  	    o_ALU_src <= '0'; -- select rt data as second input to ALU
			  	    o_reg_write <= '1'; -- write enable to write register file (write rd)

			  	when others => -- any other cases are unimplemented R-type instructions (defaults to NOOP)
					o_reg_dest <= '0';
			  	    o_jump <= '0';
			  	    o_branch <= '0';
			  	    o_mem_to_reg <= '0';
			  	    o_ALU_op <= "0000";
			  	    o_mem_write <= '0';
			  	    o_ALU_src <= '0';
			  	    o_reg_write <= '0';
			end case;			  	
		when "001000" => -- ADDI
			o_reg_dest <= '0'; -- write to target
			o_jump <= '0'; -- not a jump
	  	    o_branch <= '0';  -- not a branch
		  	o_mem_to_reg <= '0'; -- write ALU output to reg file
		  	o_ALU_op <= "0000"; -- addition operation in ALU
	  	    o_mem_write <= '0'; -- don't write to memory
		    o_ALU_src <= '1'; -- select immediate as second input to ALU
	  	    o_reg_write <= '1'; -- write enable to write register file (write rd)

		when "100011" => -- LW
			o_reg_dest <= '0'; -- write to target
			o_jump <= '0'; -- not a jump
	  	    o_branch <= '0';  -- not a branch
		  	o_mem_to_reg <= '1'; -- write memory output to register
		  	o_ALU_op <= "0000"; -- addition operation in ALU
	  	    o_mem_write <= '0'; -- don't write to memory
		    o_ALU_src <= '1'; -- select immediate as second input to ALU
	  	    o_reg_write <= '1'; -- write enable to write register file (write rd)

		when "101011" => -- SW
			o_reg_dest <= '0'; -- read from target
			o_jump <= '0'; -- not a jump
	  	    o_branch <= '0';  -- not a branch
		  	o_mem_to_reg <= '0'; -- no writing done, only saving. Can be 1 too
		  	o_ALU_op <= "0000"; -- addition operation in ALU
	  	    o_mem_write <= '1'; -- selected register is written onto addressed memory
		    o_ALU_src <= '1'; -- select immediate as second input to ALU
	  	    o_reg_write <= '0'; -- disable writing, registers are read, not written onto

		when "000100" => -- BEQ
			o_reg_dest <= '0'; -- not used
			o_jump <= '0'; --not a jump
	  	    o_branch <= '1';  -- branch to offset instruction
		  	o_mem_to_reg <= '0'; -- not used
		  	o_ALU_op <= "0001"; -- substraction operation in ALU (to check equality)
	  	    o_mem_write <= '0'; -- not used
		    o_ALU_src <= '0'; -- select rt as register to compare onto
	  	    o_reg_write <= '0'; -- not used

		when "000010" => -- J
			o_reg_dest <= '0'; -- not used
			o_jump <= '1'; -- jump to address instruction
	  	    o_branch <= '0';  -- not a branch
		  	o_mem_to_reg <= '0'; -- not used
		  	o_ALU_op <= "0000"; -- not used
	  	    o_mem_write <= '0'; -- not used
		    o_ALU_src <= '0'; -- not used
	  	    o_reg_write <= '0'; -- not used

	  	when others => -- any other cases are unimplemented instructions (defaults them to NOOP)
			o_reg_dest <= '0';
	  	    o_jump <= '0';
	  	    o_branch <= '0';
	  	    o_mem_to_reg <= '0';
	  	    o_ALU_op <= "0000";
	  	    o_mem_write <= '0';
	  	    o_ALU_src <= '0';
	  	    o_reg_write <= '0';
	end case;

end process;

end mixed;