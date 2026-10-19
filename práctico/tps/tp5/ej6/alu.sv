// ============================================================================
// Trabajo Práctico Nro 5 - CPU: RTL y Módulos
// Ejercicio 6: Módulo ALU con Banderas de Estado (flags[3:0] = {V, S, Z, C})
//
// Incorpora la generación de banderas de estado:
// - V (Desborde / Overflow): flags[3]
// - S (Signo / Negative):   flags[2]
// - Z (Cero / Zero):         flags[1]
// - C (Acarreo / Carry):     flags[0]
//
// Regla: En operaciones lógicas (F[3] == 1), C y V se fuerzan a 0.
// ============================================================================

`timescale 1ns / 1ps

module alu #(
    parameter int N = 4
)(
    input  logic [N-1:0] a,       // Operando A
    input  logic [N-1:0] b,       // Operando B
    input  logic [3:0]   F,       // Campo de control F[3:0]
    output logic [N-1:0] result,  // Resultado de la ALU
    output logic [3:0]   flags    // Banderas {V, S, Z, C}
);

    // Alias para evitar advertencias de selección constante en always_comb
    logic [1:0] s;
    assign s = F[2:1];

    // Señales internas
    logic [N-1:0] y_arit;
    logic [N-1:0] sum_arit;
    logic [N-1:0] logic_out;
    logic [N:0]   c;

    // ------------------------------------------------------------------------
    // SECCIÓN 1: SECCIÓN ARITMÉTICA
    // ------------------------------------------------------------------------
    // a) Generador de operando Y
    always_comb begin
        case (s)
            2'b00:   y_arit = '0;  // 0
            2'b01:   y_arit = b;   // B
            2'b10:   y_arit = ~b;  // ~B
            2'b11:   y_arit = '1;  // -1
            default: y_arit = '0;
        endcase
    end

    // b) Sumador con acarreo propagado (Ripple-Carry Adder)
    assign c[0] = F[0]; // Cin = F[0]
    genvar i;
    generate
        for (i = 0; i < N; i++) begin : gen_fa
            assign sum_arit[i] = a[i] ^ y_arit[i] ^ c[i];
            assign c[i+1]      = (a[i] & y_arit[i]) | (c[i] & (a[i] ^ y_arit[i]));
        end
    endgenerate

    // ------------------------------------------------------------------------
    // SECCIÓN 2: SECCIÓN LÓGICA
    // ------------------------------------------------------------------------
    always_comb begin
        case (s)
            2'b00:   logic_out = a & b;  // AND
            2'b01:   logic_out = a | b;  // OR
            2'b10:   logic_out = a ^ b;  // XOR
            2'b11:   logic_out = ~a;     // NOT A
            default: logic_out = '0;
        endcase
    end

    // ------------------------------------------------------------------------
    // SECCIÓN 3: MULTIPLEXOR DE SALIDA
    // ------------------------------------------------------------------------
    assign result = (F[3] == 1'b0) ? sum_arit : logic_out;

    // ------------------------------------------------------------------------
    // SECCIÓN 4: GENERACIÓN DE BANDERAS DE ESTADO (flags = {V, S, Z, C})
    // ------------------------------------------------------------------------
    // Signo (S): bit más significativo del resultado obtenido
    logic flag_s;
    assign flag_s = result[N-1];

    // Cero (Z): 1 si todos los bits del resultado son 0
    logic flag_z;
    assign flag_z = (result == '0);

    // Acarreo (C): Acarreo de salida c[N] de la sección aritmética; 0 en lógica
    logic flag_c;
    assign flag_c = (F[3] == 1'b0) ? c[N] : 1'b0;

    // Desborde (V): Desborde aritmético con signo; 0 en lógica
    // V = c[N] ^ c[N-1]  (equivalente a: (~a[N-1] & ~y[N-1] & sum[N-1]) | (a[N-1] & y[N-1] & ~sum[N-1]))
    logic flag_v;
    logic v_arit;
    assign v_arit = c[N] ^ c[N-1];
    assign flag_v = (F[3] == 1'b0) ? v_arit : 1'b0;

    assign flags = {flag_v, flag_s, flag_z, flag_c};

endmodule
