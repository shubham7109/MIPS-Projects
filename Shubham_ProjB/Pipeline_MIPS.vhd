-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 18.0.0 Build 614 04/24/2018 SJ Standard Edition"
-- CREATED		"Sun Nov 25 17:49:51 2018"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY Pipeline_MIPS IS 
	PORT
	(
		clock :  IN  STD_LOGIC;
		reset_PC_reg :  IN  STD_LOGIC;
		ALU_zero :  OUT  STD_LOGIC;
		wb_reg_dest :  OUT  STD_LOGIC;
		wb_instruction :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		wb_pc_plus_4 :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END Pipeline_MIPS;

ARCHITECTURE bdf_type OF Pipeline_MIPS IS 

COMPONENT register_file
	PORT(CLK : IN STD_LOGIC;
		 w_en : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 rs_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 rt_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 w_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 w_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 rs_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 rt_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT hazard
	PORT(control_jump : IN STD_LOGIC;
		 id_branch : IN STD_LOGIC;
		 branch_taken : IN STD_LOGIC;
		 id_ex_memRead : IN STD_LOGIC;
		 ex_writRegSel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 id_ex_regRt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 if_id_regRs : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 if_id_regRt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 pc_stall : OUT STD_LOGIC;
		 if_id_stall : OUT STD_LOGIC;
		 if_id_flush : OUT STD_LOGIC;
		 id_ex_stall : OUT STD_LOGIC;
		 id_ex_flush : OUT STD_LOGIC;
		 ex_mem_stall : OUT STD_LOGIC;
		 ex_mem_flush : OUT STD_LOGIC;
		 mem_wb_stall : OUT STD_LOGIC;
		 mem_wb_flush : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT jumphandler
	PORT(i_PCplusFour31_28 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 i_shifted_j_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_J_Addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pc_reg
	PORT(CLK : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 stall : IN STD_LOGIC;
		 i_next_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_PC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT adder_32
	PORT(i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT imem
GENERIC (depth_exp_of_2 : INTEGER;
			mif_filename : STRING
			);
	PORT(clock : IN STD_LOGIC;
		 wren : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 byteena : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT if_id
	PORT(CLK : IN STD_LOGIC;
		 id_flush : IN STD_LOGIC;
		 id_stall : IN STD_LOGIC;
		 ifid_reset : IN STD_LOGIC;
		 if_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 if_pc_plus_4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_pc_plus_4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT fixed_value_input
	PORT(		 reset_if_id : OUT STD_LOGIC;
		 imem_wren : OUT STD_LOGIC;
		 reg_file_reset : OUT STD_LOGIC;
		 byteena : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 Val_4_Adder : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT main_control
	PORT(i_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_reg_dest : OUT STD_LOGIC;
		 o_jump : OUT STD_LOGIC;
		 o_branch : OUT STD_LOGIC;
		 o_mem_to_reg : OUT STD_LOGIC;
		 o_mem_write : OUT STD_LOGIC;
		 o_ALU_src : OUT STD_LOGIC;
		 o_reg_write : OUT STD_LOGIC;
		 o_ALU_op : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux21_5bit
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sign_extender_26_32
	PORT(i_to_extend : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
		 o_extended : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sign_extender_16_32
	PORT(i_to_extend : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 o_extended : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sll_2
	PORT(i_to_shift : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_shifted : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT branch_comparator
	PORT(i_rs_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_rt_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_equal : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT id_ex
	PORT(CLK : IN STD_LOGIC;
		 ex_flush : IN STD_LOGIC;
		 ex_stall : IN STD_LOGIC;
		 idex_reset : IN STD_LOGIC;
		 id_reg_dest : IN STD_LOGIC;
		 id_branch : IN STD_LOGIC;
		 id_mem_to_reg : IN STD_LOGIC;
		 id_mem_write : IN STD_LOGIC;
		 id_ALU_src : IN STD_LOGIC;
		 id_reg_write : IN STD_LOGIC;
		 id_ALU_op : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 id_extended_immediate : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_pc_plus_4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_rd_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 id_rs_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_rs_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 id_rt_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_rt_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 ex_reg_dest : OUT STD_LOGIC;
		 ex_branch : OUT STD_LOGIC;
		 ex_mem_to_reg : OUT STD_LOGIC;
		 ex_mem_write : OUT STD_LOGIC;
		 ex_ALU_src : OUT STD_LOGIC;
		 ex_reg_write : OUT STD_LOGIC;
		 ex_ALU_op : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 ex_extended_immediate : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_pc_plus_4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_rd_sel : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		 ex_rs_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_rs_sel : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		 ex_rt_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_rt_sel : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT alu
	PORT(ALU_OP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 zero : OUT STD_LOGIC;
		 ALU_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux21_32bit
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux3_to_31bit
	PORT(i_00 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_01 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_10 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ex_mem
	PORT(CLK : IN STD_LOGIC;
		 mem_flush : IN STD_LOGIC;
		 mem_stall : IN STD_LOGIC;
		 exmem_reset : IN STD_LOGIC;
		 ex_reg_dest : IN STD_LOGIC;
		 ex_mem_to_reg : IN STD_LOGIC;
		 ex_mem_write : IN STD_LOGIC;
		 ex_reg_write : IN STD_LOGIC;
		 ex_ALU_out : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_pc_plus_4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_rt_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_write_reg_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 mem_reg_dest : OUT STD_LOGIC;
		 mem_mem_to_reg : OUT STD_LOGIC;
		 mem_mem_write : OUT STD_LOGIC;
		 mem_reg_write : OUT STD_LOGIC;
		 mem_ALU_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_pc_plus_4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_rt_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_write_reg_sel : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT forwarding
	PORT(wb_reg_write : IN STD_LOGIC;
		 mem_reg_write : IN STD_LOGIC;
		 ex_rs_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 ex_rt_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 mem_write_reg_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 wb_write_reg_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 rs_mux_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 rt_mux_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT dmem
GENERIC (depth_exp_of_2 : INTEGER;
			mif_filename : STRING
			);
	PORT(clock : IN STD_LOGIC;
		 wren : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 byteena : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mem_wb
	PORT(CLK : IN STD_LOGIC;
		 wb_flush : IN STD_LOGIC;
		 wb_stall : IN STD_LOGIC;
		 memwb_reset : IN STD_LOGIC;
		 mem_reg_dest : IN STD_LOGIC;
		 mem_mem_to_reg : IN STD_LOGIC;
		 mem_reg_write : IN STD_LOGIC;
		 mem_ALU_out : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_dmem_out : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_pc_plus_4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_write_reg_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 wb_reg_dest : OUT STD_LOGIC;
		 wb_mem_to_reg : OUT STD_LOGIC;
		 wb_reg_write : OUT STD_LOGIC;
		 wb_ALU_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 wb_dmem_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 wb_instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 wb_pc_plus_4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 wb_write_reg_sel : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	id_instruction :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	id_pc_plus_4 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	mem_ALU_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	o_PC :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_97 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_98 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_99 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_100 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_101 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_102 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_103 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_104 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_105 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_11 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_12 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_13 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_14 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_106 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_16 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_17 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_18 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_107 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_20 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_108 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_109 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_24 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_25 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_110 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_111 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_28 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_29 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_30 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_32 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_34 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_35 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_36 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_37 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_38 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_112 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_44 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_45 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_46 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_47 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_48 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_113 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_50 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_51 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_53 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_54 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_56 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_59 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_61 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_62 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_63 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_64 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_68 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_69 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_70 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_71 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_72 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_114 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_77 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_115 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_81 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_83 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_84 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_85 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_87 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_88 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_90 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_91 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_92 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_94 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_95 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_96 :  STD_LOGIC_VECTOR(31 DOWNTO 0);


BEGIN 



b2v_inst : register_file
PORT MAP(CLK => clock,
		 w_en => SYNTHESIZED_WIRE_97,
		 reset => SYNTHESIZED_WIRE_1,
		 rs_sel => id_instruction(25 DOWNTO 21),
		 rt_sel => id_instruction(20 DOWNTO 16),
		 w_data => SYNTHESIZED_WIRE_98,
		 w_sel => SYNTHESIZED_WIRE_99,
		 rs_data => SYNTHESIZED_WIRE_110,
		 rt_data => SYNTHESIZED_WIRE_111);


b2v_inst12 : hazard
PORT MAP(control_jump => SYNTHESIZED_WIRE_100,
		 id_branch => SYNTHESIZED_WIRE_101,
		 branch_taken => SYNTHESIZED_WIRE_102,
		 id_ex_memRead => SYNTHESIZED_WIRE_103,
		 ex_writRegSel => SYNTHESIZED_WIRE_104,
		 id_ex_regRt => SYNTHESIZED_WIRE_105,
		 if_id_regRs => id_instruction(25 DOWNTO 21),
		 if_id_regRt => id_instruction(20 DOWNTO 16),
		 pc_stall => SYNTHESIZED_WIRE_11,
		 if_id_stall => SYNTHESIZED_WIRE_18,
		 if_id_flush => SYNTHESIZED_WIRE_17,
		 id_ex_stall => SYNTHESIZED_WIRE_30,
		 id_ex_flush => SYNTHESIZED_WIRE_29,
		 ex_mem_stall => SYNTHESIZED_WIRE_64,
		 ex_mem_flush => SYNTHESIZED_WIRE_63,
		 mem_wb_stall => SYNTHESIZED_WIRE_85,
		 mem_wb_flush => SYNTHESIZED_WIRE_84);


b2v_inst123 : jumphandler
PORT MAP(i_PCplusFour31_28 => id_pc_plus_4(31 DOWNTO 28),
		 i_shifted_j_addr => SYNTHESIZED_WIRE_10,
		 o_J_Addr => SYNTHESIZED_WIRE_62);


b2v_inst13 : pc_reg
PORT MAP(CLK => clock,
		 reset => reset_PC_reg,
		 stall => SYNTHESIZED_WIRE_11,
		 i_next_PC => SYNTHESIZED_WIRE_12,
		 o_PC => o_PC);


b2v_inst14 : adder_32
PORT MAP(i_A => o_PC,
		 i_B => SYNTHESIZED_WIRE_13,
		 o_F => SYNTHESIZED_WIRE_108);


b2v_inst17 : imem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "imem.mif"
			)
PORT MAP(clock => clock,
		 wren => SYNTHESIZED_WIRE_14,
		 address => o_PC(11 DOWNTO 2),
		 byteena => SYNTHESIZED_WIRE_106,
		 data => SYNTHESIZED_WIRE_16,
		 q => SYNTHESIZED_WIRE_20);


b2v_inst18 : if_id
PORT MAP(CLK => clock,
		 id_flush => SYNTHESIZED_WIRE_17,
		 id_stall => SYNTHESIZED_WIRE_18,
		 ifid_reset => SYNTHESIZED_WIRE_107,
		 if_instruction => SYNTHESIZED_WIRE_20,
		 if_pc_plus_4 => SYNTHESIZED_WIRE_108,
		 id_instruction => id_instruction,
		 id_pc_plus_4 => id_pc_plus_4);


b2v_inst2 : fixed_value_input
PORT MAP(		 reset_if_id => SYNTHESIZED_WIRE_107,
		 imem_wren => SYNTHESIZED_WIRE_14,
		 reg_file_reset => SYNTHESIZED_WIRE_1,
		 byteena => SYNTHESIZED_WIRE_106,
		 data => SYNTHESIZED_WIRE_16,
		 Val_4_Adder => SYNTHESIZED_WIRE_13);


b2v_inst20 : main_control
PORT MAP(i_instruction => id_instruction,
		 o_reg_dest => SYNTHESIZED_WIRE_32,
		 o_jump => SYNTHESIZED_WIRE_100,
		 o_branch => SYNTHESIZED_WIRE_101,
		 o_mem_to_reg => SYNTHESIZED_WIRE_34,
		 o_mem_write => SYNTHESIZED_WIRE_35,
		 o_ALU_src => SYNTHESIZED_WIRE_36,
		 o_reg_write => SYNTHESIZED_WIRE_37,
		 o_ALU_op => SYNTHESIZED_WIRE_38);


b2v_inst22 : mux21_5bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_109,
		 i_0 => SYNTHESIZED_WIRE_105,
		 i_1 => SYNTHESIZED_WIRE_24,
		 o_mux => SYNTHESIZED_WIRE_104);


b2v_inst23 : sign_extender_26_32
PORT MAP(i_to_extend => id_instruction(25 DOWNTO 0),
		 o_extended => SYNTHESIZED_WIRE_25);


b2v_inst25 : sign_extender_16_32
PORT MAP(i_to_extend => id_instruction(15 DOWNTO 0),
		 o_extended => SYNTHESIZED_WIRE_112);


b2v_inst26 : sll_2
PORT MAP(i_to_shift => SYNTHESIZED_WIRE_25,
		 o_shifted => SYNTHESIZED_WIRE_10);


b2v_inst27 : branch_comparator
PORT MAP(i_rs_data => SYNTHESIZED_WIRE_110,
		 i_rt_data => SYNTHESIZED_WIRE_111,
		 o_equal => SYNTHESIZED_WIRE_44);


b2v_inst31 : adder_32
PORT MAP(i_A => SYNTHESIZED_WIRE_28,
		 i_B => id_pc_plus_4,
		 o_F => SYNTHESIZED_WIRE_59);


b2v_inst32 : id_ex
PORT MAP(CLK => clock,
		 ex_flush => SYNTHESIZED_WIRE_29,
		 ex_stall => SYNTHESIZED_WIRE_30,
		 idex_reset => SYNTHESIZED_WIRE_107,
		 id_reg_dest => SYNTHESIZED_WIRE_32,
		 id_branch => SYNTHESIZED_WIRE_101,
		 id_mem_to_reg => SYNTHESIZED_WIRE_34,
		 id_mem_write => SYNTHESIZED_WIRE_35,
		 id_ALU_src => SYNTHESIZED_WIRE_36,
		 id_reg_write => SYNTHESIZED_WIRE_37,
		 id_ALU_op => SYNTHESIZED_WIRE_38,
		 id_extended_immediate => SYNTHESIZED_WIRE_112,
		 id_instruction => id_instruction,
		 id_pc_plus_4 => id_pc_plus_4,
		 id_rd_sel => id_instruction(15 DOWNTO 11),
		 id_rs_data => SYNTHESIZED_WIRE_110,
		 id_rs_sel => id_instruction(25 DOWNTO 21),
		 id_rt_data => SYNTHESIZED_WIRE_111,
		 id_rt_sel => id_instruction(20 DOWNTO 16),
		 ex_reg_dest => SYNTHESIZED_WIRE_109,
		 ex_mem_to_reg => SYNTHESIZED_WIRE_103,
		 ex_mem_write => SYNTHESIZED_WIRE_68,
		 ex_ALU_src => SYNTHESIZED_WIRE_48,
		 ex_reg_write => SYNTHESIZED_WIRE_69,
		 ex_ALU_op => SYNTHESIZED_WIRE_45,
		 ex_extended_immediate => SYNTHESIZED_WIRE_50,
		 ex_instruction => SYNTHESIZED_WIRE_71,
		 ex_pc_plus_4 => SYNTHESIZED_WIRE_72,
		 ex_rd_sel => SYNTHESIZED_WIRE_24,
		 ex_rs_data => SYNTHESIZED_WIRE_51,
		 ex_rs_sel => SYNTHESIZED_WIRE_77,
		 ex_rt_data => SYNTHESIZED_WIRE_54,
		 ex_rt_sel => SYNTHESIZED_WIRE_105);


b2v_inst33 : sll_2
PORT MAP(i_to_shift => SYNTHESIZED_WIRE_112,
		 o_shifted => SYNTHESIZED_WIRE_28);


SYNTHESIZED_WIRE_102 <= SYNTHESIZED_WIRE_101 AND SYNTHESIZED_WIRE_44;


b2v_inst36 : alu
PORT MAP(ALU_OP => SYNTHESIZED_WIRE_45,
		 i_A => SYNTHESIZED_WIRE_46,
		 i_B => SYNTHESIZED_WIRE_47,
		 shamt => id_instruction(10 DOWNTO 6),
		 zero => ALU_zero,
		 ALU_out => SYNTHESIZED_WIRE_70);


b2v_inst37 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_48,
		 i_0 => SYNTHESIZED_WIRE_113,
		 i_1 => SYNTHESIZED_WIRE_50,
		 o_mux => SYNTHESIZED_WIRE_47);


b2v_inst39 : mux3_to_31bit
PORT MAP(i_00 => SYNTHESIZED_WIRE_51,
		 i_01 => SYNTHESIZED_WIRE_98,
		 i_10 => mem_ALU_out,
		 i_sel => SYNTHESIZED_WIRE_53,
		 o_mux => SYNTHESIZED_WIRE_46);


b2v_inst40 : mux3_to_31bit
PORT MAP(i_00 => SYNTHESIZED_WIRE_54,
		 i_01 => SYNTHESIZED_WIRE_98,
		 i_10 => mem_ALU_out,
		 i_sel => SYNTHESIZED_WIRE_56,
		 o_mux => SYNTHESIZED_WIRE_113);


b2v_inst41 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_102,
		 i_0 => SYNTHESIZED_WIRE_108,
		 i_1 => SYNTHESIZED_WIRE_59,
		 o_mux => SYNTHESIZED_WIRE_61);


b2v_inst43 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_100,
		 i_0 => SYNTHESIZED_WIRE_61,
		 i_1 => SYNTHESIZED_WIRE_62,
		 o_mux => SYNTHESIZED_WIRE_12);


b2v_inst45 : ex_mem
PORT MAP(CLK => clock,
		 mem_flush => SYNTHESIZED_WIRE_63,
		 mem_stall => SYNTHESIZED_WIRE_64,
		 exmem_reset => SYNTHESIZED_WIRE_107,
		 ex_reg_dest => SYNTHESIZED_WIRE_109,
		 ex_mem_to_reg => SYNTHESIZED_WIRE_103,
		 ex_mem_write => SYNTHESIZED_WIRE_68,
		 ex_reg_write => SYNTHESIZED_WIRE_69,
		 ex_ALU_out => SYNTHESIZED_WIRE_70,
		 ex_instruction => SYNTHESIZED_WIRE_71,
		 ex_pc_plus_4 => SYNTHESIZED_WIRE_72,
		 ex_rt_data => SYNTHESIZED_WIRE_113,
		 ex_write_reg_sel => SYNTHESIZED_WIRE_104,
		 mem_reg_dest => SYNTHESIZED_WIRE_87,
		 mem_mem_to_reg => SYNTHESIZED_WIRE_88,
		 mem_mem_write => SYNTHESIZED_WIRE_81,
		 mem_reg_write => SYNTHESIZED_WIRE_114,
		 mem_ALU_out => mem_ALU_out,
		 mem_instruction => SYNTHESIZED_WIRE_91,
		 mem_pc_plus_4 => SYNTHESIZED_WIRE_92,
		 mem_rt_data => SYNTHESIZED_WIRE_83,
		 mem_write_reg_sel => SYNTHESIZED_WIRE_115);


b2v_inst46 : forwarding
PORT MAP(wb_reg_write => SYNTHESIZED_WIRE_97,
		 mem_reg_write => SYNTHESIZED_WIRE_114,
		 ex_rs_sel => SYNTHESIZED_WIRE_77,
		 ex_rt_sel => SYNTHESIZED_WIRE_105,
		 mem_write_reg_sel => SYNTHESIZED_WIRE_115,
		 wb_write_reg_sel => SYNTHESIZED_WIRE_99,
		 rs_mux_sel => SYNTHESIZED_WIRE_53,
		 rt_mux_sel => SYNTHESIZED_WIRE_56);


b2v_inst47 : dmem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "dmem.mif"
			)
PORT MAP(clock => clock,
		 wren => SYNTHESIZED_WIRE_81,
		 address => mem_ALU_out(11 DOWNTO 2),
		 byteena => SYNTHESIZED_WIRE_106,
		 data => SYNTHESIZED_WIRE_83,
		 q => SYNTHESIZED_WIRE_90);


b2v_inst48 : mem_wb
PORT MAP(CLK => clock,
		 wb_flush => SYNTHESIZED_WIRE_84,
		 wb_stall => SYNTHESIZED_WIRE_85,
		 memwb_reset => SYNTHESIZED_WIRE_107,
		 mem_reg_dest => SYNTHESIZED_WIRE_87,
		 mem_mem_to_reg => SYNTHESIZED_WIRE_88,
		 mem_reg_write => SYNTHESIZED_WIRE_114,
		 mem_ALU_out => mem_ALU_out,
		 mem_dmem_out => SYNTHESIZED_WIRE_90,
		 mem_instruction => SYNTHESIZED_WIRE_91,
		 mem_pc_plus_4 => SYNTHESIZED_WIRE_92,
		 mem_write_reg_sel => SYNTHESIZED_WIRE_115,
		 wb_reg_dest => wb_reg_dest,
		 wb_mem_to_reg => SYNTHESIZED_WIRE_94,
		 wb_reg_write => SYNTHESIZED_WIRE_97,
		 wb_ALU_out => SYNTHESIZED_WIRE_95,
		 wb_dmem_out => SYNTHESIZED_WIRE_96,
		 wb_instruction => wb_instruction,
		 wb_pc_plus_4 => wb_pc_plus_4,
		 wb_write_reg_sel => SYNTHESIZED_WIRE_99);


b2v_inst6 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_94,
		 i_0 => SYNTHESIZED_WIRE_95,
		 i_1 => SYNTHESIZED_WIRE_96,
		 o_mux => SYNTHESIZED_WIRE_98);


END bdf_type;