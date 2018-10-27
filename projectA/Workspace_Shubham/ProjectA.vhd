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
-- CREATED		"Tue Oct 23 17:16:19 2018"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY ProjectA IS 
	PORT
	(
		CLK :  IN  STD_LOGIC;
		PC_reset :  IN  STD_LOGIC;
		imem_wren :  IN  STD_LOGIC;
		reg_file_reset :  IN  STD_LOGIC;
		byteena :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		data :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		Val_4_Adder :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALU_i_A :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALU_i_B :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALU_out :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		JA_output :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END ProjectA;

ARCHITECTURE bdf_type OF ProjectA IS 

COMPONENT alu
	PORT(ALU_OP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 zero : OUT STD_LOGIC;
		 ALU_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pc_reg
	PORT(CLK : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
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

COMPONENT mux21_32bit
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
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

COMPONENT sign_extender_16_32
	PORT(i_to_extend : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 o_extended : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
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

SIGNAL	ALU_out_ALTERA_SYNTHESIZED :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	JA :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	o_PC :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	PC :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	q :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_24 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_11 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_25 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_14 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_15 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_16 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_17 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_18 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_19 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_20 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_21 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_22 :  STD_LOGIC;


BEGIN 
ALU_i_A <= SYNTHESIZED_WIRE_1;
ALU_i_B <= SYNTHESIZED_WIRE_2;



b2v_inst : alu
PORT MAP(ALU_OP => SYNTHESIZED_WIRE_0,
		 i_A => SYNTHESIZED_WIRE_1,
		 i_B => SYNTHESIZED_WIRE_2,
		 shamt => q(10 DOWNTO 6),
		 zero => SYNTHESIZED_WIRE_15,
		 ALU_out => ALU_out_ALTERA_SYNTHESIZED);


b2v_inst1 : pc_reg
PORT MAP(CLK => CLK,
		 reset => PC_reset,
		 i_next_PC => SYNTHESIZED_WIRE_3,
		 o_PC => o_PC);


b2v_inst10 : adder_32
PORT MAP(i_A => PC,
		 i_B => SYNTHESIZED_WIRE_4,
		 o_F => SYNTHESIZED_WIRE_8);


b2v_inst11 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_5,
		 i_0 => SYNTHESIZED_WIRE_6,
		 i_1 => JA,
		 o_mux => SYNTHESIZED_WIRE_3);


b2v_inst12 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_7,
		 i_0 => PC,
		 i_1 => SYNTHESIZED_WIRE_8,
		 o_mux => SYNTHESIZED_WIRE_6);


b2v_inst13 : sll_2
PORT MAP(i_to_shift => SYNTHESIZED_WIRE_24,
		 o_shifted => SYNTHESIZED_WIRE_4);


b2v_inst15 : sign_extender_26_32
PORT MAP(i_to_extend => q(25 DOWNTO 0),
		 o_extended => SYNTHESIZED_WIRE_10);


b2v_inst16 : sll_2
PORT MAP(i_to_shift => SYNTHESIZED_WIRE_10,
		 o_shifted => JA);


b2v_inst18 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_11,
		 i_0 => SYNTHESIZED_WIRE_25,
		 i_1 => SYNTHESIZED_WIRE_24,
		 o_mux => SYNTHESIZED_WIRE_2);


SYNTHESIZED_WIRE_7 <= SYNTHESIZED_WIRE_14 AND SYNTHESIZED_WIRE_15;


b2v_inst2 : adder_32
PORT MAP(i_A => o_PC,
		 i_B => Val_4_Adder,
		 o_F => PC);


b2v_inst20 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_16,
		 i_0 => ALU_out_ALTERA_SYNTHESIZED,
		 i_1 => SYNTHESIZED_WIRE_17,
		 o_mux => SYNTHESIZED_WIRE_20);


b2v_inst3 : imem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "imem.mif"
			)
PORT MAP(clock => CLK,
		 wren => imem_wren,
		 address => o_PC(11 DOWNTO 2),
		 byteena => byteena,
		 data => data,
		 q => q);


b2v_inst5 : mux21_5bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_18,
		 i_0 => q(20 DOWNTO 16),
		 i_1 => q(15 DOWNTO 11),
		 o_mux => SYNTHESIZED_WIRE_21);


b2v_inst6 : register_file
PORT MAP(CLK => CLK,
		 w_en => SYNTHESIZED_WIRE_19,
		 reset => reg_file_reset,
		 rs_sel => q(25 DOWNTO 21),
		 rt_sel => q(20 DOWNTO 16),
		 w_data => SYNTHESIZED_WIRE_20,
		 w_sel => SYNTHESIZED_WIRE_21,
		 rs_data => SYNTHESIZED_WIRE_1,
		 rt_data => SYNTHESIZED_WIRE_25);


b2v_inst7 : sign_extender_16_32
PORT MAP(i_to_extend => q(15 DOWNTO 0),
		 o_extended => SYNTHESIZED_WIRE_24);


b2v_inst8 : main_control
PORT MAP(i_instruction => q,
		 o_reg_dest => SYNTHESIZED_WIRE_18,
		 o_jump => SYNTHESIZED_WIRE_5,
		 o_branch => SYNTHESIZED_WIRE_14,
		 o_mem_to_reg => SYNTHESIZED_WIRE_16,
		 o_mem_write => SYNTHESIZED_WIRE_22,
		 o_ALU_src => SYNTHESIZED_WIRE_11,
		 o_reg_write => SYNTHESIZED_WIRE_19,
		 o_ALU_op => SYNTHESIZED_WIRE_0);


b2v_inst9 : dmem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "dmem.mif"
			)
PORT MAP(clock => CLK,
		 wren => SYNTHESIZED_WIRE_22,
		 address => ALU_out_ALTERA_SYNTHESIZED(11 DOWNTO 2),
		 byteena => byteena,
		 data => SYNTHESIZED_WIRE_25,
		 q => SYNTHESIZED_WIRE_17);

ALU_out <= ALU_out_ALTERA_SYNTHESIZED;
JA_output <= PC;

END bdf_type;