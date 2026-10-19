// ============================================================================
// Trabajo Práctico Nro 5 - CPU: RTL y Módulos
// Punto 4: Unidad Aritmético-Lógica (ALU)
//
// Tabla de operaciones de acuerdo al Punto 1 (G_sel[3:0] = {S2, S1, S0, Cin}):
// S2 S1 S0 Cin | Operación RTL           | Función
// ----------------------------------------------------------------------------
//  0  0  0  0  | F = A                   | Transferencia de A
//  0  0  0  1  | F = A + 1               | Incremento de A
//  0  0  1  0  | F = A + B               | Adición
//  0  0  1  1  | F = A + B + 1           | Adición con acarreo
//  0  1  0  0  | F = A + ~B              | A mas complemento a 1 de B
//  0  1  0  1  | F = A + ~B + 1 = A - B  | Sustracción (Complemento a 2)
//  0  1  1  0  | F = A - 1               | Decremento de A
//  0  1  1  1  | F = A                   | Transferencia de A
// ----------------------------------------------------------------------------
//  1  0  0  X  | F = A & B               | AND bit a bit
//  1  0  1  X  | F = A | B               | OR bit a bit
//  1  1  0  X  | F = A ^ B               | XOR bit a bit
//  1  1  1  X  | F = ~A                  | Complemento de A
//
// Banderas de estado de salida:
// - V (Overflow): flags[3]
// - C (Carry):    flags[2]
// - N (Negative): flags[1]
// - Z (Zero):     flags[0]
// ============================================================================

`timescale 1ns / 1ps

module alu #(
    parameter int N = 4
)(
    input  logic [N-1:0] a,       // Operando A (proviene de BUS A)
    input  logic [N-1:0] b,       // Operando B (proviene de BUS B)
    input  logic [3:0]   g_sel,   // G Select [3:0] = {S2, S1, S0, Cin}
    output logic [N-1:0] result,  // Salida de la ALU
    output logic         v,       // Desborde (Overflow)
    output logic         c_flag,  // Acarreo (Carry)
    output logic         n,       // Negativo (Negative/Sign)
    output logic         z,       // Cero (Zero)
    output logic [3:0]   flags    // Vector empaquetado {V, C, N, Z}
);

    logic [1:0] s_arit;
    assign s_arit = g_sel[2:1];

    logic [1:0] s_logic;
    assign s_logic = g_sel[2:1];

    // Señales de la sección aritmética
    logic [N-1:0] y_arit;
    logic [N-1:0] sum_arit;
    logic [N:0]   c;

    // Generador de operando Y para la suma
    always_comb begin
        case (s_arit)
            2'b00:   y_arit = '0;  // 0000
            2'b01:   y_arit = b;   // B
            2'b10:   y_arit = ~b;  // ~B
            2'b11:   y_arit = '1;  // 1111 (-1)
            default: y_arit = '0;
        endcase
    end

    // Sumador ripple-carry
    assign c[0] = g_sel[0]; // Cin = G_sel[0]
    genvar i;
    generate
        for (i = 0; i < N; i++) begin : gen_fa
            assign sum_arit[i] = a[i] ^ y_arit[i] ^ c[i];
            assign c[i+1]      = (a[i] & y_arit[i]) | (c[i] & (a[i] ^ y_arit[i]));
        end
    endgenerate

    // Sección lógica bit a bit
    logic [N-1:0] logic_out;
    always_comb begin
        case (s_logic)
            2'b00:   logic_out = a & b;  // AND
            2'b01:   logic_out = a | b;  // OR
            2'b10:   logic_out = a ^ b;  // XOR
            2'b11:   logic_out = ~a;     // NOT A
            default: logic_out = '0;
        endcase
    end

    // Multiplexor de resultado de la ALU (S2 = g_sel[3])
    // S2 = 0 -> Aritmética, S2 = 1 -> Lógica
    assign result = (g_sel[3] == 1'b0) ? sum_arit : logic_out;

    // V (Desborde) y C (Acarreo): activos en aritmética, forzados a 0 en lógica
    assign v      = (g_sel[3] == 1'b0) ? (c[N] ^ c[N-1]) : 1'b0;
    assign c_flag = (g_sel[3] == 1'b0) ? c[N] : 1'b0;

    // N (Negativo): bit MSB del resultado (bit de signo)
    assign n      = result[N-1];

    // Z (Cero): 1 cuando todos los bits son cero (detector de cero)
    assign z      = (result == '0);

    // Agrupación en el orden de la figura {V, C, N, Z}
    assign flags  = {v, c_flag, n, z};

endmodule
