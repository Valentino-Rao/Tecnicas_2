`timescale 1ns/1ps

/**
 * ============================================================================
 * Módulo: alu.sv (Unidad Aritmético Lógica Parametrizada)
 * Técnicas Digitales II - UTN FRC
 * Basado en Harris & Harris (Capítulo 4: HDL & Capítulo 7: Microarquitectura)
 * ============================================================================
 * Entradas:
 *   - a, b: Operandos de N bits
 *   - alu_control: Selector de operación (3 bits)
 *       3'b000: ADD (Suma: a + b)
 *       3'b001: SUB (Resta: a - b)
 *       3'b010: AND (Operación lógica Y: a & b)
 *       3'b011: OR  (Operación lógica O: a | b)
 *       3'b100: XOR (Operación O exclusiva: a ^ b)
 *       3'b101: SLT (Set on Less Than: resultado = 1 si a < b con signo, 0 sino)
 * Salidas:
 *   - result: Resultado de N bits
 *   - zero: Bandera Z (1 si result == 0)
 *   - negative: Bandera N (1 si el bit más significativo de result es 1)
 * ============================================================================
 */

module alu #(
    parameter WIDTH = 8
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic [2:0]       alu_control,
    output logic [WIDTH-1:0] result,
    output logic             zero,
    output logic             negative
);

    // Lógica combinacional usando always_comb (SystemVerilog)
    always_comb begin
        case (alu_control)
            3'b000: result = a + b;                                            // ADD
            3'b001: result = a - b;                                            // SUB
            3'b010: result = a & b;                                            // AND
            3'b011: result = a | b;                                            // OR
            3'b100: result = a ^ b;                                            // XOR
            3'b101: result = ($signed(a) < $signed(b)) ? {{(WIDTH-1){1'b0}}, 1'b1} : {WIDTH{1'b0}}; // SLT
            default: result = {WIDTH{1'b0}};
        endcase
    end

    // Generación de Banderas de Estado
    assign zero     = (result == {WIDTH{1'b0}});
    assign negative = result[WIDTH-1];

endmodule
