`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2026 13:42:56
// Design Name: 
// Module Name: if_stage
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


module if_stage (
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic        and_out,
    input  logic [31:0] pc_signed_offset,
    output logic [31:0] address,
    output logic [31:0] pc_new
);

    logic [31:0] next_pc;

    // Calculate PC + 4
    assign pc_new = address + 32'd4;

    // Select next PC
    always_comb begin
        if (and_out)
            next_pc = pc_signed_offset;
        else
            next_pc = pc_new;
    end

    // Program Counter register
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            address <= 32'h80000000;
        else if (!stall)
            address <= next_pc;
    end

endmodule
