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
// CREATED		"Tue Nov 13 16:52:49 2018"

module Pipeline_MIPS(
	CLK,
	id_flush,
	id_stall,
	ifid_reset,
	ex_flush,
	ex_stall,
	idex_reset,
	exmem_reset,
	mem_stall,
	mem_flush,
	exwb_reset,
	wb_flush,
	wb_stall,
	Instr_Type,
	Instr_Out,
	PCp4_Out
);


input wire	CLK;
input wire	id_flush;
input wire	id_stall;
input wire	ifid_reset;
input wire	ex_flush;
input wire	ex_stall;
input wire	idex_reset;
input wire	exmem_reset;
input wire	mem_stall;
input wire	mem_flush;
input wire	exwb_reset;
input wire	wb_flush;
input wire	wb_stall;
output wire	Instr_Type;
output wire	[31:0] Instr_Out;
output wire	[31:0] PCp4_Out;

wire	[31:0] ALU_out;
wire	[31:0] Ins;
wire	[31:0] JA;
wire	[31:0] o_PC;
wire	[31:0] PC;
wire	[31:0] q;
wire	[3:0] SYNTHESIZED_WIRE_0;
wire	[31:0] SYNTHESIZED_WIRE_1;
wire	[31:0] SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	[31:0] SYNTHESIZED_WIRE_63;
wire	[31:0] SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_11;
wire	[3:0] SYNTHESIZED_WIRE_12;
wire	[31:0] SYNTHESIZED_WIRE_13;
wire	[31:0] SYNTHESIZED_WIRE_14;
wire	[31:0] SYNTHESIZED_WIRE_15;
wire	[31:0] SYNTHESIZED_WIRE_16;
wire	[31:0] SYNTHESIZED_WIRE_64;
wire	[31:0] SYNTHESIZED_WIRE_18;
wire	SYNTHESIZED_WIRE_65;
wire	SYNTHESIZED_WIRE_20;
wire	SYNTHESIZED_WIRE_21;
wire	SYNTHESIZED_WIRE_22;
wire	[31:0] SYNTHESIZED_WIRE_23;
wire	[31:0] SYNTHESIZED_WIRE_24;
wire	[31:0] SYNTHESIZED_WIRE_66;
wire	[4:0] SYNTHESIZED_WIRE_26;
wire	SYNTHESIZED_WIRE_27;
wire	SYNTHESIZED_WIRE_28;
wire	[31:0] SYNTHESIZED_WIRE_29;
wire	SYNTHESIZED_WIRE_30;
wire	SYNTHESIZED_WIRE_31;
wire	SYNTHESIZED_WIRE_32;
wire	[31:0] SYNTHESIZED_WIRE_33;
wire	[31:0] SYNTHESIZED_WIRE_34;
wire	[31:0] SYNTHESIZED_WIRE_35;
wire	[4:0] SYNTHESIZED_WIRE_36;
wire	SYNTHESIZED_WIRE_37;
wire	[3:0] SYNTHESIZED_WIRE_67;
wire	[31:0] SYNTHESIZED_WIRE_39;
wire	SYNTHESIZED_WIRE_40;
wire	[31:0] SYNTHESIZED_WIRE_42;
wire	SYNTHESIZED_WIRE_43;
wire	[31:0] SYNTHESIZED_WIRE_44;
wire	[31:0] SYNTHESIZED_WIRE_45;
wire	SYNTHESIZED_WIRE_46;
wire	[31:0] SYNTHESIZED_WIRE_47;
wire	SYNTHESIZED_WIRE_48;
wire	[31:0] SYNTHESIZED_WIRE_49;
wire	[31:0] SYNTHESIZED_WIRE_50;
wire	SYNTHESIZED_WIRE_51;
wire	[4:0] SYNTHESIZED_WIRE_55;
wire	[4:0] SYNTHESIZED_WIRE_56;
wire	SYNTHESIZED_WIRE_57;
wire	SYNTHESIZED_WIRE_58;
wire	[31:0] SYNTHESIZED_WIRE_59;
wire	[4:0] SYNTHESIZED_WIRE_60;
wire	[31:0] SYNTHESIZED_WIRE_61;





sign_extender_16_32	b2v_ins21(
	.i_to_extend(q[15:0]),
	.o_extended(SYNTHESIZED_WIRE_13));


ALU	b2v_inst(
	.ALU_OP(SYNTHESIZED_WIRE_0),
	.i_A(SYNTHESIZED_WIRE_1),
	.i_B(SYNTHESIZED_WIRE_2),
	.shamt(Ins[10:6]),
	.zero(SYNTHESIZED_WIRE_28),
	.ALU_out(SYNTHESIZED_WIRE_23));


PC_reg	b2v_inst1(
	.CLK(CLK),
	.reset(SYNTHESIZED_WIRE_3),
	.i_next_PC(SYNTHESIZED_WIRE_63),
	.o_PC(o_PC));


adder_32	b2v_inst10(
	.i_A(PC),
	.i_B(SYNTHESIZED_WIRE_5),
	.o_F(SYNTHESIZED_WIRE_47));


id_ex	b2v_inst12(
	.CLK(CLK),
	.ex_flush(ex_flush),
	.ex_stall(ex_stall),
	.idex_reset(idex_reset),
	.id_reg_dest(SYNTHESIZED_WIRE_6),
	.id_branch(SYNTHESIZED_WIRE_7),
	.id_mem_to_reg(SYNTHESIZED_WIRE_8),
	.id_mem_write(SYNTHESIZED_WIRE_9),
	.id_ALU_src(SYNTHESIZED_WIRE_10),
	.id_reg_write(SYNTHESIZED_WIRE_11),
	.id_ALU_op(SYNTHESIZED_WIRE_12),
	.id_extended_immediate(SYNTHESIZED_WIRE_13),
	.id_instruction(q),
	.id_pc_plus_4(SYNTHESIZED_WIRE_14),
	.id_rd_sel(q[15:11]),
	.id_rs_data(SYNTHESIZED_WIRE_15),
	.id_rs_sel(q[25:21]),
	.id_rt_data(SYNTHESIZED_WIRE_16),
	.id_rt_sel(q[20:16]),
	.ex_reg_dest(SYNTHESIZED_WIRE_65),
	.ex_branch(SYNTHESIZED_WIRE_27),
	.ex_mem_to_reg(SYNTHESIZED_WIRE_20),
	.ex_mem_write(SYNTHESIZED_WIRE_21),
	.ex_ALU_src(SYNTHESIZED_WIRE_51),
	.ex_reg_write(SYNTHESIZED_WIRE_22),
	.ex_ALU_op(SYNTHESIZED_WIRE_0),
	.ex_extended_immediate(SYNTHESIZED_WIRE_64),
	.ex_instruction(Ins),
	.ex_pc_plus_4(SYNTHESIZED_WIRE_24),
	.ex_rd_sel(SYNTHESIZED_WIRE_56),
	.ex_rs_data(SYNTHESIZED_WIRE_1),
	
	.ex_rt_data(SYNTHESIZED_WIRE_66),
	.ex_rt_sel(SYNTHESIZED_WIRE_55));


sll_2	b2v_inst13(
	.i_to_shift(SYNTHESIZED_WIRE_64),
	.o_shifted(SYNTHESIZED_WIRE_5));



sign_extender_26_32	b2v_inst15(
	.i_to_extend(q[25:0]),
	.o_extended(SYNTHESIZED_WIRE_18));


sll_2	b2v_inst16(
	.i_to_shift(SYNTHESIZED_WIRE_18),
	.o_shifted(JA));


ex_mem	b2v_inst17(
	.CLK(CLK),
	.mem_flush(mem_flush),
	.mem_stall(mem_stall),
	.exmem_reset(exmem_reset),
	.ex_reg_dest(SYNTHESIZED_WIRE_65),
	.ex_mem_to_reg(SYNTHESIZED_WIRE_20),
	.ex_mem_write(SYNTHESIZED_WIRE_21),
	.ex_reg_write(SYNTHESIZED_WIRE_22),
	.ex_ALU_out(SYNTHESIZED_WIRE_23),
	.ex_instruction(Ins),
	.ex_pc_plus_4(SYNTHESIZED_WIRE_24),
	.ex_rt_data(SYNTHESIZED_WIRE_66),
	.ex_write_reg_sel(SYNTHESIZED_WIRE_26),
	.mem_reg_dest(SYNTHESIZED_WIRE_30),
	.mem_mem_to_reg(SYNTHESIZED_WIRE_31),
	.mem_mem_write(SYNTHESIZED_WIRE_37),
	.mem_reg_write(SYNTHESIZED_WIRE_32),
	.mem_ALU_out(ALU_out),
	.mem_instruction(SYNTHESIZED_WIRE_34),
	.mem_pc_plus_4(SYNTHESIZED_WIRE_35),
	.mem_rt_data(SYNTHESIZED_WIRE_39),
	.mem_write_reg_sel(SYNTHESIZED_WIRE_36));

assign	SYNTHESIZED_WIRE_46 = SYNTHESIZED_WIRE_27 & SYNTHESIZED_WIRE_28;


adder_32	b2v_inst2(
	.i_A(o_PC),
	.i_B(SYNTHESIZED_WIRE_29),
	.o_F(PC));


mem_wb	b2v_inst20(
	.CLK(CLK),
	.wb_flush(wb_flush),
	.wb_stall(wb_stall),
	.memwb_reset(exwb_reset),
	.mem_reg_dest(SYNTHESIZED_WIRE_30),
	.mem_mem_to_reg(SYNTHESIZED_WIRE_31),
	.mem_reg_write(SYNTHESIZED_WIRE_32),
	.mem_ALU_out(ALU_out),
	.mem_dmem_out(SYNTHESIZED_WIRE_33),
	.mem_instruction(SYNTHESIZED_WIRE_34),
	.mem_pc_plus_4(SYNTHESIZED_WIRE_35),
	.mem_write_reg_sel(SYNTHESIZED_WIRE_36),
	.wb_reg_dest(Instr_Type),
	.wb_mem_to_reg(SYNTHESIZED_WIRE_43),
	.wb_reg_write(SYNTHESIZED_WIRE_57),
	.wb_ALU_out(SYNTHESIZED_WIRE_44),
	.wb_dmem_out(SYNTHESIZED_WIRE_45),
	.wb_instruction(Instr_Out),
	.wb_pc_plus_4(PCp4_Out),
	.wb_write_reg_sel(SYNTHESIZED_WIRE_60));


dmem	b2v_inst22(
	.clock(CLK),
	.wren(SYNTHESIZED_WIRE_37),
	.address(ALU_out[11:2]),
	.byteena(SYNTHESIZED_WIRE_67),
	.data(SYNTHESIZED_WIRE_39),
	.q(SYNTHESIZED_WIRE_33));
	defparam	b2v_inst22.depth_exp_of_2 = 10;
	defparam	b2v_inst22.mif_filename = "dmem.mif";


imem	b2v_inst3(
	.clock(CLK),
	.wren(SYNTHESIZED_WIRE_40),
	.address(o_PC[11:2]),
	.byteena(SYNTHESIZED_WIRE_67),
	.data(SYNTHESIZED_WIRE_42),
	.q(SYNTHESIZED_WIRE_61));
	defparam	b2v_inst3.depth_exp_of_2 = 10;
	defparam	b2v_inst3.mif_filename = "imem.mif";


jumpHandler	b2v_inst4(
	.i_PCplusFour31_28(PC[31:28]),
	.i_shifted_j_addr(JA),
	.o_J_Addr(SYNTHESIZED_WIRE_50));


bit32_mux_2to1	b2v_inst42(
	.i_sel(SYNTHESIZED_WIRE_43),
	.i_0(SYNTHESIZED_WIRE_44),
	.i_1(SYNTHESIZED_WIRE_45),
	.o_mux(SYNTHESIZED_WIRE_59));


bit32_mux_2to1	b2v_inst43(
	.i_sel(SYNTHESIZED_WIRE_46),
	.i_0(SYNTHESIZED_WIRE_47),
	.i_1(PC),
	.o_mux(SYNTHESIZED_WIRE_49));


bit32_mux_2to1	b2v_inst44(
	.i_sel(SYNTHESIZED_WIRE_48),
	.i_0(SYNTHESIZED_WIRE_49),
	.i_1(SYNTHESIZED_WIRE_50),
	.o_mux(SYNTHESIZED_WIRE_63));


bit32_mux_2to1	b2v_inst45(
	.i_sel(SYNTHESIZED_WIRE_51),
	.i_0(SYNTHESIZED_WIRE_66),
	.i_1(SYNTHESIZED_WIRE_64),
	.o_mux(SYNTHESIZED_WIRE_2));


mux21_5bit	b2v_inst5(
	.i_sel(SYNTHESIZED_WIRE_65),
	.i_0(SYNTHESIZED_WIRE_55),
	.i_1(SYNTHESIZED_WIRE_56),
	.o_mux(SYNTHESIZED_WIRE_26));


register_file	b2v_inst6(
	.CLK(CLK),
	.w_en(SYNTHESIZED_WIRE_57),
	.reset(SYNTHESIZED_WIRE_58),
	.rs_sel(q[25:21]),
	.rt_sel(q[20:16]),
	.w_data(SYNTHESIZED_WIRE_59),
	.w_sel(SYNTHESIZED_WIRE_60),
	.rs_data(SYNTHESIZED_WIRE_15),
	.rt_data(SYNTHESIZED_WIRE_16));


fixed_value_input	b2v_inst7(
	.PC_reset(SYNTHESIZED_WIRE_3),
	.imem_wren(SYNTHESIZED_WIRE_40),
	.reg_file_reset(SYNTHESIZED_WIRE_58),
	.byteena(SYNTHESIZED_WIRE_67),
	.data(SYNTHESIZED_WIRE_42),
	.Val_4_Adder(SYNTHESIZED_WIRE_29));


main_control	b2v_inst8(
	.i_instruction(q),
	.o_reg_dest(SYNTHESIZED_WIRE_6),
	.o_jump(SYNTHESIZED_WIRE_48),
	.o_branch(SYNTHESIZED_WIRE_7),
	.o_mem_to_reg(SYNTHESIZED_WIRE_8),
	.o_mem_write(SYNTHESIZED_WIRE_9),
	.o_ALU_src(SYNTHESIZED_WIRE_10),
	.o_reg_write(SYNTHESIZED_WIRE_11),
	.o_ALU_op(SYNTHESIZED_WIRE_12));


if_id	b2v_inst9(
	.CLK(CLK),
	.id_flush(id_flush),
	.id_stall(id_stall),
	.ifid_reset(ifid_reset),
	.if_instruction(SYNTHESIZED_WIRE_61),
	.if_pc_plus_4(SYNTHESIZED_WIRE_63),
	.id_instruction(q),
	.id_pc_plus_4(SYNTHESIZED_WIRE_14));


endmodule
