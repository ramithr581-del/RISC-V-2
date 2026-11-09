`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.11.2026 23:09:18
// Design Name: 
// Module Name: single_cycle_riscv
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module single_cycle_riscv (
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic [31:0] instruction,
    input  logic [31:0] mem_out,
    output logic [31:0] rs2_data,
    output logic [31:0] alu_out,
    output logic        mem_write,
    output logic        mem_read,
    output logic [2:0]  fn3,
    output logic [6:0]  opcode,
    output logic [31:0] address
);

    // IF stage signals
    logic [31:0] pc_new;
    logic [31:0] pc_ex_out;
    logic        and_out_ex;

    // ID stage signals
    logic [31:0] rs1_data;
    logic [31:0] imm_out;
    logic [6:0]  opcode_out_d;
    logic [6:0]  imm11_5;
    logic        fn7_5;
    logic [2:0]  aluop;
    logic [1:0]  memtoreg;
    logic        branch;
    logic        alu_src;
    logic        mux_inp;

    // WB stage signal
    logic [31:0] wb_data;

    // 1. Instruction Fetch Stage
    if_stage IF (
        .clk             (clk),
        .reset           (reset),
        .stall           (stall),
        .and_out         (and_out_ex),
        .pc_signed_offset(pc_ex_out),
        .address         (address),
        .pc_new          (pc_new)
    );

    // 2. Instruction Decode Stage
    id_stage ID (
        .clk          (clk),
        .reset        (reset),
        .stall        (stall),
        .instruction  (instruction),
        .wb_data      (wb_data),
        .rs1_data     (rs1_data),
        .rs2_data     (rs2_data),
        .imm_out      (imm_out),
        .opcode_out_d (opcode_out_d),
        .imm11_5      (imm11_5),
        .fn3_out_d    (fn3),
        .fn7_5        (fn7_5),
        .aluop        (aluop),
        .memtoreg     (memtoreg),
        .branch       (branch),
        .mem_write    (mem_write),
        .mem_read     (mem_read),
        .alu_src      (alu_src),
        .mux_inp      (mux_inp)
    );

    // 3. Execute Stage
    ex_stage EX (
        .rs1_data   (rs1_data),
        .rs2_data   (rs2_data),
        .imm_out    (imm_out),
        .address    (address),
        .branch     (branch),
        .alu_src    (alu_src),
        .fn7_5      (fn7_5),
        .mux_inp    (mux_inp),
        .fn3        (fn3),
        .imm11_5    (imm11_5),
        .aluop      (aluop),
        .opcode     (opcode_out_d),
        .and_out_ex (and_out_ex),
        .alu_out    (alu_out),
        .pc_ex_out  (pc_ex_out)
    );

    // 4. Write Back Stage
    wb_stage WB (
        .mem_out         (mem_out),
        .alu_out         (alu_out),
        .return_addr     (pc_new),
        .imm_out         (imm_out),
        .pc_signed_offset(pc_ex_out),
        .memtoreg        (memtoreg),
        .opcode_out_d    (opcode_out_d),
        .wb_data         (wb_data)
    );

    // Pass opcode to external interface
    assign opcode = opcode_out_d;

endmodule
