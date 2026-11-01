`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2026 19:43:32
// Design Name: 
// Module Name: ex_stage
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


module ex_stage (
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [31:0] imm_out,
    input  logic [31:0] address,
    input  logic        branch,
    input  logic        alu_src,
    input  logic        fn7_5,
    input  logic        mux_inp,
    input  logic [2:0]  fn3,
    input  logic [6:0]  imm11_5,
    input  logic [2:0]  aluop,
    input  logic [6:0]  opcode,
    output logic        and_out_ex,
    output logic [31:0] alu_out,
    output logic [31:0] pc_ex_out
);

    logic [31:0] alu_operand_b;
    logic [4:0]  alu_control_signal;
    logic        zero;

    logic [31:0] pc_signed_offset;

    // Select ALU operand B
    always_comb begin
        if (alu_src)
            alu_operand_b = imm_out;
        else
            alu_operand_b = rs2_data;
    end

    // ALU Control
    alu_control alu_control_unit (
        .alu_op     (aluop),
        .fn3        (fn3),
        .imm11_5    (imm11_5),
        .fn7_5      (fn7_5),
        .control_out(alu_control_signal)
    );

    // ALU
    alu alu_unit (
        .alu_control(alu_control_signal),
        .rs1_data   (rs1_data),
        .rs2_data   (alu_operand_b),
        .alu_out    (alu_out),
        .zero       (zero)
    );

    // Calculate PC + immediate
    assign pc_signed_offset = address + imm_out;

    // Select branch/jump target
    always_comb begin
        if (mux_inp)
            pc_ex_out = {alu_out[31:1], 1'b0};
        else
            pc_ex_out = pc_signed_offset;
    end

    // Branch and jump decision
    always_comb begin
        and_out_ex = (branch && zero) ||
                     (opcode == 7'h6F) ||
                     (opcode == 7'h67);
    end

endmodule
