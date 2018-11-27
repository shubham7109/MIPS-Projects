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
-- CREATED		"Tue Nov 27 10:37:57 2018"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY Pipeline_MIPS IS 
	PORT
	(
		CLK :  IN  STD_LOGIC;
		stall :  IN  STD_LOGIC;
		reset :  IN  STD_LOGIC;
		Instr_Type :  OUT  STD_LOGIC;
		Instr_Out :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		PCp4_Out :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END Pipeline_MIPS;

ARCHITECTURE bdf_type OF Pipeline_MIPS IS 

COMPONENT sign_extender_16_32
	PORT(i_to_extend : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 o_extended : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
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

COMPONENT adder_32
	PORT(i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
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

COMPONENT sll_2
	PORT(i_to_shift : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_shifted : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sign_extender_26_32
	PORT(i_to_extend : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
		 o_extended : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
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

COMPONENT jumphandler
	PORT(i_PCplusFour31_28 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 i_shifted_j_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_J_Addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT bit32_mux_2to1
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux21_5bit
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

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

COMPONENT fixed_value_input
	PORT(		 PC_reset : OUT STD_LOGIC;
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

SIGNAL	ALU_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	Ins :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	JA :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	o_PC :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	PC :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	q :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_73 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_74 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_11 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_12 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_13 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_14 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_15 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_16 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_17 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_18 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_75 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_20 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_76 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_25 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_26 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_27 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_28 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_29 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_77 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_31 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_32 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_33 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_34 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_38 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_39 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_40 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_41 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_42 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_43 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_44 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_45 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_78 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_47 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_48 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_50 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_51 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_52 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_53 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_54 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_55 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_56 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_57 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_58 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_59 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_63 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_64 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_65 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_66 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_67 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_71 :  STD_LOGIC_VECTOR(31 DOWNTO 0);


BEGIN 
SYNTHESIZED_WIRE_74 <= '0';



b2v_ins21 : sign_extender_16_32
PORT MAP(i_to_extend => q(15 DOWNTO 0),
		 o_extended => SYNTHESIZED_WIRE_15);


b2v_inst : alu
PORT MAP(ALU_OP => SYNTHESIZED_WIRE_0,
		 i_A => SYNTHESIZED_WIRE_1,
		 i_B => SYNTHESIZED_WIRE_2,
		 shamt => Ins(10 DOWNTO 6),
		 zero => SYNTHESIZED_WIRE_33,
		 ALU_out => SYNTHESIZED_WIRE_28);


b2v_inst10 : adder_32
PORT MAP(i_A => PC,
		 i_B => SYNTHESIZED_WIRE_3,
		 o_F => SYNTHESIZED_WIRE_55);


b2v_inst11 : pc_reg
PORT MAP(CLK => CLK,
		 reset => reset,
		 stall => stall,
		 i_next_PC => SYNTHESIZED_WIRE_73,
		 o_PC => o_PC);


b2v_inst12 : id_ex
PORT MAP(CLK => CLK,
		 ex_flush => SYNTHESIZED_WIRE_74,
		 ex_stall => SYNTHESIZED_WIRE_74,
		 idex_reset => SYNTHESIZED_WIRE_74,
		 id_reg_dest => SYNTHESIZED_WIRE_8,
		 id_branch => SYNTHESIZED_WIRE_9,
		 id_mem_to_reg => SYNTHESIZED_WIRE_10,
		 id_mem_write => SYNTHESIZED_WIRE_11,
		 id_ALU_src => SYNTHESIZED_WIRE_12,
		 id_reg_write => SYNTHESIZED_WIRE_13,
		 id_ALU_op => SYNTHESIZED_WIRE_14,
		 id_extended_immediate => SYNTHESIZED_WIRE_15,
		 id_instruction => q,
		 id_pc_plus_4 => SYNTHESIZED_WIRE_16,
		 id_rd_sel => q(15 DOWNTO 11),
		 id_rs_data => SYNTHESIZED_WIRE_17,
		 id_rs_sel => q(25 DOWNTO 21),
		 id_rt_data => SYNTHESIZED_WIRE_18,
		 id_rt_sel => q(20 DOWNTO 16),
		 ex_reg_dest => SYNTHESIZED_WIRE_76,
		 ex_branch => SYNTHESIZED_WIRE_32,
		 ex_mem_to_reg => SYNTHESIZED_WIRE_25,
		 ex_mem_write => SYNTHESIZED_WIRE_26,
		 ex_ALU_src => SYNTHESIZED_WIRE_59,
		 ex_reg_write => SYNTHESIZED_WIRE_27,
		 ex_ALU_op => SYNTHESIZED_WIRE_0,
		 ex_extended_immediate => SYNTHESIZED_WIRE_75,
		 ex_instruction => Ins,
		 ex_pc_plus_4 => SYNTHESIZED_WIRE_29,
		 ex_rd_sel => SYNTHESIZED_WIRE_64,
		 ex_rs_data => SYNTHESIZED_WIRE_1,
		 ex_rt_data => SYNTHESIZED_WIRE_77,
		 ex_rt_sel => SYNTHESIZED_WIRE_63);


b2v_inst13 : sll_2
PORT MAP(i_to_shift => SYNTHESIZED_WIRE_75,
		 o_shifted => SYNTHESIZED_WIRE_3);


b2v_inst15 : sign_extender_26_32
PORT MAP(i_to_extend => q(25 DOWNTO 0),
		 o_extended => SYNTHESIZED_WIRE_20);


b2v_inst16 : sll_2
PORT MAP(i_to_shift => SYNTHESIZED_WIRE_20,
		 o_shifted => JA);


b2v_inst17 : ex_mem
PORT MAP(CLK => CLK,
		 mem_flush => SYNTHESIZED_WIRE_74,
		 mem_stall => SYNTHESIZED_WIRE_74,
		 exmem_reset => SYNTHESIZED_WIRE_74,
		 ex_reg_dest => SYNTHESIZED_WIRE_76,
		 ex_mem_to_reg => SYNTHESIZED_WIRE_25,
		 ex_mem_write => SYNTHESIZED_WIRE_26,
		 ex_reg_write => SYNTHESIZED_WIRE_27,
		 ex_ALU_out => SYNTHESIZED_WIRE_28,
		 ex_instruction => Ins,
		 ex_pc_plus_4 => SYNTHESIZED_WIRE_29,
		 ex_rt_data => SYNTHESIZED_WIRE_77,
		 ex_write_reg_sel => SYNTHESIZED_WIRE_31,
		 mem_reg_dest => SYNTHESIZED_WIRE_38,
		 mem_mem_to_reg => SYNTHESIZED_WIRE_39,
		 mem_mem_write => SYNTHESIZED_WIRE_45,
		 mem_reg_write => SYNTHESIZED_WIRE_40,
		 mem_ALU_out => ALU_out,
		 mem_instruction => SYNTHESIZED_WIRE_42,
		 mem_pc_plus_4 => SYNTHESIZED_WIRE_43,
		 mem_rt_data => SYNTHESIZED_WIRE_47,
		 mem_write_reg_sel => SYNTHESIZED_WIRE_44);


SYNTHESIZED_WIRE_54 <= SYNTHESIZED_WIRE_32 AND SYNTHESIZED_WIRE_33;


b2v_inst2 : adder_32
PORT MAP(i_A => o_PC,
		 i_B => SYNTHESIZED_WIRE_34,
		 o_F => PC);


b2v_inst20 : mem_wb
PORT MAP(CLK => CLK,
		 wb_flush => SYNTHESIZED_WIRE_74,
		 wb_stall => SYNTHESIZED_WIRE_74,
		 memwb_reset => SYNTHESIZED_WIRE_74,
		 mem_reg_dest => SYNTHESIZED_WIRE_38,
		 mem_mem_to_reg => SYNTHESIZED_WIRE_39,
		 mem_reg_write => SYNTHESIZED_WIRE_40,
		 mem_ALU_out => ALU_out,
		 mem_dmem_out => SYNTHESIZED_WIRE_41,
		 mem_instruction => SYNTHESIZED_WIRE_42,
		 mem_pc_plus_4 => SYNTHESIZED_WIRE_43,
		 mem_write_reg_sel => SYNTHESIZED_WIRE_44,
		 wb_reg_dest => Instr_Type,
		 wb_mem_to_reg => SYNTHESIZED_WIRE_51,
		 wb_reg_write => SYNTHESIZED_WIRE_65,
		 wb_ALU_out => SYNTHESIZED_WIRE_52,
		 wb_dmem_out => SYNTHESIZED_WIRE_53,
		 wb_instruction => Instr_Out,
		 wb_pc_plus_4 => PCp4_Out,
		 wb_write_reg_sel => SYNTHESIZED_WIRE_67);



b2v_inst22 : dmem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "dmem.mif"
			)
PORT MAP(clock => CLK,
		 wren => SYNTHESIZED_WIRE_45,
		 address => ALU_out(11 DOWNTO 2),
		 byteena => SYNTHESIZED_WIRE_78,
		 data => SYNTHESIZED_WIRE_47,
		 q => SYNTHESIZED_WIRE_41);


b2v_inst3 : imem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "imem.mif"
			)
PORT MAP(clock => CLK,
		 wren => SYNTHESIZED_WIRE_48,
		 address => o_PC(11 DOWNTO 2),
		 byteena => SYNTHESIZED_WIRE_78,
		 data => SYNTHESIZED_WIRE_50,
		 q => SYNTHESIZED_WIRE_71);


b2v_inst4 : jumphandler
PORT MAP(i_PCplusFour31_28 => PC(31 DOWNTO 28),
		 i_shifted_j_addr => JA,
		 o_J_Addr => SYNTHESIZED_WIRE_58);


b2v_inst42 : bit32_mux_2to1
PORT MAP(i_sel => SYNTHESIZED_WIRE_51,
		 i_0 => SYNTHESIZED_WIRE_52,
		 i_1 => SYNTHESIZED_WIRE_53,
		 o_mux => SYNTHESIZED_WIRE_66);


b2v_inst43 : bit32_mux_2to1
PORT MAP(i_sel => SYNTHESIZED_WIRE_54,
		 i_0 => SYNTHESIZED_WIRE_55,
		 i_1 => PC,
		 o_mux => SYNTHESIZED_WIRE_57);


b2v_inst44 : bit32_mux_2to1
PORT MAP(i_sel => SYNTHESIZED_WIRE_56,
		 i_0 => SYNTHESIZED_WIRE_57,
		 i_1 => SYNTHESIZED_WIRE_58,
		 o_mux => SYNTHESIZED_WIRE_73);


b2v_inst45 : bit32_mux_2to1
PORT MAP(i_sel => SYNTHESIZED_WIRE_59,
		 i_0 => SYNTHESIZED_WIRE_77,
		 i_1 => SYNTHESIZED_WIRE_75,
		 o_mux => SYNTHESIZED_WIRE_2);


b2v_inst5 : mux21_5bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_76,
		 i_0 => SYNTHESIZED_WIRE_63,
		 i_1 => SYNTHESIZED_WIRE_64,
		 o_mux => SYNTHESIZED_WIRE_31);


b2v_inst6 : register_file
PORT MAP(CLK => CLK,
		 w_en => SYNTHESIZED_WIRE_65,
		 reset => reset,
		 rs_sel => q(25 DOWNTO 21),
		 rt_sel => q(20 DOWNTO 16),
		 w_data => SYNTHESIZED_WIRE_66,
		 w_sel => SYNTHESIZED_WIRE_67,
		 rs_data => SYNTHESIZED_WIRE_17,
		 rt_data => SYNTHESIZED_WIRE_18);


b2v_inst7 : fixed_value_input
PORT MAP(		 imem_wren => SYNTHESIZED_WIRE_48,
		 byteena => SYNTHESIZED_WIRE_78,
		 data => SYNTHESIZED_WIRE_50,
		 Val_4_Adder => SYNTHESIZED_WIRE_34);


b2v_inst8 : main_control
PORT MAP(i_instruction => q,
		 o_reg_dest => SYNTHESIZED_WIRE_8,
		 o_jump => SYNTHESIZED_WIRE_56,
		 o_branch => SYNTHESIZED_WIRE_9,
		 o_mem_to_reg => SYNTHESIZED_WIRE_10,
		 o_mem_write => SYNTHESIZED_WIRE_11,
		 o_ALU_src => SYNTHESIZED_WIRE_12,
		 o_reg_write => SYNTHESIZED_WIRE_13,
		 o_ALU_op => SYNTHESIZED_WIRE_14);


b2v_inst9 : if_id
PORT MAP(CLK => CLK,
		 id_flush => SYNTHESIZED_WIRE_74,
		 id_stall => SYNTHESIZED_WIRE_74,
		 ifid_reset => SYNTHESIZED_WIRE_74,
		 if_instruction => SYNTHESIZED_WIRE_71,
		 if_pc_plus_4 => SYNTHESIZED_WIRE_73,
		 id_instruction => q,
		 id_pc_plus_4 => SYNTHESIZED_WIRE_16);


END bdf_type;