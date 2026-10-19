// ============================================================================
// Trabajo Práctico Nro 5 - CPU: RTL y Módulos
// Ejercicio 4: Circuito Aritmético de 4 bits
//
// Operaciones aritméticas controladas por S1, S0 y Cin:
//   S1 S0 Cin | Operación               | Operando Y   | Resultado
//   --------------------------------------------------------------------------
//    0  0  0  | Transferencia de A      | 0000         | A
//    0  0  1  | Incremento de A         | 0000         | A + 1
//    0  1  0  | Suma de A y B           | B            | A + B
//    0  1  1  | Suma con acarreo        | B            | A + B + 1
//    1  0  0  | A + B_bar               | ~B           | A + ~B
//    1  0  1  | Sustracción (A - B)     | ~B           | A + ~B + 1 = A - B
//    1  1  0  | Decremento de A         | 1111 (-1)    | A - 1
//    1  1  1  | Transferencia de A      | 1111 (-1)    | A
// ============================================================================

`timescale 1ns / 1ps

module circuito_aritmetico #(
    parameter int N = 4
)(
    input  logic [N-1:0] a,        // Primer operando A
    input  logic [N-1:0] b,        // Segundo operando de entrada B
    input  logic [1:0]   s,        // Variables de selección {S1, S0}
    input  logic         cin,      // Acarreo de entrada Cin
    output logic [N-1:0] y,        // Operando modificado Y (observabilidad)
    output logic [N-1:0] sum,      // Resultado aritmético de N bits
    output logic         cout,     // Acarreo de salida Cout
    output logic         overflow  // Desborde en complemento a 2 (V)
);

    logic [N:0] c; // Vector de acarreos internos [c4, c3, c2, c1, c0]
    assign c[0] = cin;

    // ------------------------------------------------------------------------
    // ETAPA 1: Generador del segundo operando Y (Lógica B de 1 bit replicada)
    // ------------------------------------------------------------------------
    always_comb begin
        case (s)
            2'b00:   y = '0;  // Y = 0 (Transferencia / Incremento)
            2'b01:   y = b;   // Y = B (Suma)
            2'b10:   y = ~b;  // Y = ~B (Sustracción en Ca2 con Cin=1)
            2'b11:   y = '1;  // Y = -1 (Decremento con Cin=0)
            default: y = '0;
        endcase
    end

    // ------------------------------------------------------------------------
    // ETAPA 2: Sumador Completo de N bits (Ripple-Carry Adder)
    // Etapas típicas de 1 bit con generación de suma y propagación de acarreo
    // ------------------------------------------------------------------------
    genvar i;
    generate
        for (i = 0; i < N; i++) begin : gen_full_adder
            assign sum[i] = a[i] ^ y[i] ^ c[i];
            assign c[i+1] = (a[i] & y[i]) | (c[i] & (a[i] ^ y[i]));
        end
    endgenerate

    // Acarreo final de salida
    assign cout = c[N];

    // Detección de desborde con signo (Overflow V en complemento a 2):
    // V = c[N] ^ c[N-1] (el acarreo que entra al MSB difiere del que sale del MSB)
    assign overflow = c[N] ^ c[N-1];

endmodule
