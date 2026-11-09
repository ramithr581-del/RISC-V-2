`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.11.2026 23:07:49
// Design Name: 
// Module Name: wb_stage
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


module wb_stage(
    input  logic [31:0] mem_out,
    input  logic [31:0] alu_out,
    input  logic [31:0] return_addr,
    input  logic [31:0] imm_out,
    input  logic [31:0] pc_signed_offset,
    input  logic [1:0]  memtoreg,
    input  logic [6:0]  opcode_out_d,
    output logic [31:0] wb_data
);

    always_comb begin

        case (memtoreg)

            // ALU result
            2'b00: wb_data = alu_out;

            // Data memory output
            2'b01: wb_data = mem_out;

            // Special write-back selection
            2'b10: begin
                case (opcode_out_d)

                    // JAL and JALR: return address
                    7'b1101111,
                    7'b1100111:
                        wb_data = return_addr;

                    // LUI: upper immediate
                    7'b0110111:
                        wb_data = imm_out;

                    // AUIPC: PC + upper immediate
                    7'b0010111:
                        wb_data = pc_signed_offset;

                    default:
                        wb_data = alu_out;

                endcase
            end

            // Default
            2'b11: wb_data = alu_out;

            default: wb_data = alu_out;

        endcase
    end

endmodule
