// Copyright (C) 2018  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 18.0.0 Build 614 04/24/2018 SJ Standard Edition"
// CREATED		"Sun Nov 11 20:26:41 2018"

module Pipeline_MIPS(
	CLK,
	PC_reset,
	imem_wren,
	reg_file_reset,
	byteena,
	data,
	Val_4_Adder
);


input wire	CLK;
input wire	PC_reset;
input wire	imem_wren;
input wire	reg_file_reset;
input wire	[3:0] byteena;
input wire	[31:0] data;
input wire	[31:0] Val_4_Adder;

wire	[31:0] ALU_out;
wire	gdfx_temp0;
wire	[31:0] JA;
wire	[31:0] o_PC;
wire	[31:0] PC;
wire	[31:0] q;
wire	[3:0] SYNTHESIZED_WIRE_0;
wire	[31:0] SYNTHESIZED_WIRE_1;
wire	[31:0] SYNTHESIZED_WIRE_2;
wire	[31:0] SYNTHESIZED_WIRE_3;
wire	[31:0] SYNTHESIZED_WIRE_4;
wire	[31:0] SYNTHESIZED_WIRE_24;
wire	[31:0] SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;
wire	[31:0] SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_11;
wire	SYNTHESIZED_WIRE_12;
wire	[31:0] SYNTHESIZED_WIRE_13;
wire	[31:0] SYNTHESIZED_WIRE_14;
wire	SYNTHESIZED_WIRE_15;
wire	[31:0] SYNTHESIZED_WIRE_25;
wire	SYNTHESIZED_WIRE_18;
wire	SYNTHESIZED_WIRE_19;
wire	[31:0] SYNTHESIZED_WIRE_20;
wire	[4:0] SYNTHESIZED_WIRE_21;
wire	SYNTHESIZED_WIRE_22;





ALU	b2v_inst(
	.ALU_OP(SYNTHESIZED_WIRE_0),
	.i_A(SYNTHESIZED_WIRE_1),
	.i_B(SYNTHESIZED_WIRE_2),
	.shamt(q[10:6]),
	.zero(SYNTHESIZED_WIRE_8),
	.ALU_out(ALU_out));


PC_reg	b2v_inst1(
	.CLK(gdfx_temp0),
	.reset(PC_reset),
	.i_next_PC(SYNTHESIZED_WIRE_3),
	.o_PC(o_PC));


adder_32	b2v_inst10(
	.i_A(PC),
	.i_B(SYNTHESIZED_WIRE_4),
	.o_F(PC));


sll_2	b2v_inst13(
	.i_to_shift(SYNTHESIZED_WIRE_24),
	.o_shifted(SYNTHESIZED_WIRE_4));


sign_extender_26_32	b2v_inst15(
	.i_to_extend(q[25:0]),
	.o_extended(SYNTHESIZED_WIRE_6));


sll_2	b2v_inst16(
	.i_to_shift(SYNTHESIZED_WIRE_6),
	.o_shifted(JA));

assign	SYNTHESIZED_WIRE_11 = SYNTHESIZED_WIRE_7 & SYNTHESIZED_WIRE_8;


adder_32	b2v_inst2(
	.i_A(o_PC),
	.i_B(Val_4_Adder),
	.o_F(PC));


imem	b2v_inst3(
	.clock(gdfx_temp0),
	.wren(imem_wren),
	.address(o_PC[11:2]),
	.byteena(byteena),
	.data(data),
	.q(q));
	defparam	b2v_inst3.depth_exp_of_2 = 10;
	defparam	b2v_inst3.mif_filename = "imem.mif";


jumpHandler	b2v_inst4(
	.i_PCplusFour31_28(PC[31:28]),
	.i_shifted_j_addr(JA),
	.o_J_Addr(SYNTHESIZED_WIRE_14));


bit32_mux_2to1	b2v_inst42(
	.i_sel(SYNTHESIZED_WIRE_9),
	.i_0(ALU_out),
	.i_1(SYNTHESIZED_WIRE_10),
	.o_mux(SYNTHESIZED_WIRE_20));


bit32_mux_2to1	b2v_inst43(
	.i_sel(SYNTHESIZED_WIRE_11),
	.i_0(PC),
	.i_1(PC),
	.o_mux(SYNTHESIZED_WIRE_13));


bit32_mux_2to1	b2v_inst44(
	.i_sel(SYNTHESIZED_WIRE_12),
	.i_0(SYNTHESIZED_WIRE_13),
	.i_1(SYNTHESIZED_WIRE_14),
	.o_mux(SYNTHESIZED_WIRE_3));


bit32_mux_2to1	b2v_inst45(
	.i_sel(SYNTHESIZED_WIRE_15),
	.i_0(SYNTHESIZED_WIRE_25),
	.i_1(SYNTHESIZED_WIRE_24),
	.o_mux(SYNTHESIZED_WIRE_2));


mux21_5bit	b2v_inst5(
	.i_sel(SYNTHESIZED_WIRE_18),
	.i_0(q[20:16]),
	.i_1(q[15:11]),
	.o_mux(SYNTHESIZED_WIRE_21));


register_file	b2v_inst6(
	.CLK(gdfx_temp0),
	.w_en(SYNTHESIZED_WIRE_19),
	.reset(gdfx_temp0),
	.rs_sel(q[25:21]),
	.rt_sel(q[20:16]),
	.w_data(SYNTHESIZED_WIRE_20),
	.w_sel(SYNTHESIZED_WIRE_21),
	.rs_data(SYNTHESIZED_WIRE_1),
	.rt_data(SYNTHESIZED_WIRE_25));


sign_extender_16_32	b2v_inst7(
	.i_to_extend(q[15:0]),
	.o_extended(SYNTHESIZED_WIRE_24));


main_control	b2v_inst8(
	.i_instruction(q),
	.o_reg_dest(SYNTHESIZED_WIRE_18),
	.o_jump(SYNTHESIZED_WIRE_12),
	.o_branch(SYNTHESIZED_WIRE_7),
	.o_mem_to_reg(SYNTHESIZED_WIRE_9),
	.o_mem_write(SYNTHESIZED_WIRE_22),
	.o_ALU_src(SYNTHESIZED_WIRE_15),
	.o_reg_write(SYNTHESIZED_WIRE_19),
	.o_ALU_op(SYNTHESIZED_WIRE_0));


dmem	b2v_inst9(
	.clock(gdfx_temp0),
	.wren(SYNTHESIZED_WIRE_22),
	.address(ALU_out[11:2]),
	.byteena(byteena),
	.data(SYNTHESIZED_WIRE_25),
	.q(SYNTHESIZED_WIRE_10));
	defparam	b2v_inst9.depth_exp_of_2 = 10;
	defparam	b2v_inst9.mif_filename = "dmem.mif";

assign	gdfx_temp0 = CLK;
assign	gdfx_temp0 = reg_file_reset;

endmodule
