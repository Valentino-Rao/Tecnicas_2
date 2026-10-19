// ============================================================================
// Trabajo Práctico Nro 5 - CPU: RTL y Módulos
// Ejercicio 5: Módulo ALU (Unidad Aritmético Lógica) de 4 bits
//
// Unifica la sección aritmética (Ejercicio 4) y la sección lógica bajo
// el campo de control unificado F[3:0]:
//
// F[3] | F[2:1] (S1, S0) | F[0] (Cin) | Operación         | Tipo
// ----------------------------------------------------------------------------
//  0   |   00            |    0       | Result = A        | Aritmética (Transf)
//  0   |   00            |    1       | Result = A + 1    | Aritmética (Incr)
//  0   |   01            |    0       | Result = A + B    | Aritmética (Suma)
//  0   |   01            |    1       | Result = A + B + 1| Aritmética (Suma+1)
//  0   |   10            |    0       | Result = A + ~B   | Aritmética (Resta 1s)
//  0   |   10            |    1       | Result = A - B    | Aritmética (Resta Ca2)
//  0   |   11            |    0       | Result = A - 1    | Aritmética (Decr)
//  0   |   11            |    1       | Result = A        | Aritmética (Transf)
// ----------------------------------------------------------------------------
//  1   |   00            |    X       | Result = A & B    | Lógica (AND)
//  1   |   01            |    X       | Result = A | B    | Lógica (OR)
//  1   |   10            |    X       | Result = A ^ B    | Lógica (XOR)
//  1   |   11            |    X       | Result = ~A       | Lógica (NOT / Compl)
// ============================================================================

`timescale 1ns / 1ps

module alu #(
    parameter int N = 4
)(
    input  logic [N-1:0] a,       // Operando A
    input  logic [N-1:0] b,       // Operando B
    input  logic [3:0]   F,       // Campo de control de la ALU F[3:0]
    output logic [N-1:0] result   // Resultado de la operación
);

    // Señales internas
    logic [1:0]   s;
    assign s = F[2:1];

    logic [N-1:0] y_arit;
    logic [N-1:0] sum_arit;
    logic [N-1:0] logic_out;
    logic [N:0]   c;

    // ------------------------------------------------------------------------
    // SECCIÓN 1: SECCIÓN ARITMÉTICA (Controlada por F[2:0])
    // ------------------------------------------------------------------------
    // a) Generador del operando Y a partir de F[2:1] = {S1, S0}
    always_comb begin
        case (s)
            2'b00:   y_arit = '0;  // 0000
            2'b01:   y_arit = b;   // B
            2'b10:   y_arit = ~b;  // ~B
            2'b11:   y_arit = '1;  // 1111 (-1)
            default: y_arit = '0;
        endcase
    end

    // b) Sumador con acarreo ripple-carry
    assign c[0] = F[0]; // Cin = F[0]
    genvar i;
    generate
        for (i = 0; i < N; i++) begin : gen_fa
            assign sum_arit[i] = a[i] ^ y_arit[i] ^ c[i];
            assign c[i+1]      = (a[i] & y_arit[i]) | (c[i] & (a[i] ^ y_arit[i]));
        end
    endgenerate

    // ------------------------------------------------------------------------
    // SECCIÓN 2: SECCIÓN LÓGICA (Controlada por F[2:1] = {S1, S0})
    // Cuadro 3: AND, OR, XOR, NOT bit a bit
    // ------------------------------------------------------------------------
    always_comb begin
        case (s)
            2'b00:   logic_out = a & b;  // AND bit a bit
            2'b01:   logic_out = a | b;  // OR bit a bit
            2'b10:   logic_out = a ^ b;  // XOR bit a bit
            2'b11:   logic_out = ~a;     // Complemento bit a bit (~A)
            default: logic_out = '0;
        endcase
    end

    // ------------------------------------------------------------------------
    // SECCIÓN 3: MULTIPLEXOR DE SALIDA (Selección de Resultado por F[3])
    // F[3] = 0 -> Resultado Aritmético
    // F[3] = 1 -> Resultado Lógico
    // ------------------------------------------------------------------------
    assign result = (F[3] == 1'b0) ? sum_arit : logic_out;

endmodule
