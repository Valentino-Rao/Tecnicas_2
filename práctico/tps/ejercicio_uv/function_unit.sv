// ============================================================================
// Trabajo Práctico Nro 5 - CPU: RTL y Módulos
// Punto 4: Unidad Funcional (Function Unit)
//
// Integra:
//   - ALU (controlada por G Select de 4 bits)
//   - Shifter (controlado por H Select de 2 bits)
//   - MUX F (controlado por MF Select de 1 bit)
//
// Permite control unificado mediante el bus FS[4:0] (Function Select):
//   - FS[4] = 0 (MF Select = 0): Selecciona salida de ALU con G Select = FS[3:0]
//   - FS[4] = 1 (MF Select = 1): Selecciona salida de Shifter con H Select = FS[1:0]
//
// Banderas de estado: {V, C, N, Z} generadas por la ALU.
// ============================================================================

`timescale 1ns / 1ps

module function_unit #(
    parameter int N = 4
)(
    input  logic [N-1:0] a,       // Entrada A (desde BUS A)
    input  logic [N-1:0] b,       // Entrada B (desde BUS B)
    input  logic [4:0]   FS,      // Function Select [4:0] (5 bits)
    output logic [N-1:0] F,       // Salida de la Unidad Funcional (MUX F)
    output logic         v,       // Desborde (Overflow)
    output logic         c,       // Acarreo (Carry)
    output logic         n,       // Negativo (Negative/Sign)
    output logic         z,       // Cero (Zero)
    output logic [3:0]   flags    // Banderas de estado {V, C, N, Z}
);

    // Decodificación interna de señales de control a partir de FS[4:0]
    logic       mf_select;
    logic [3:0] g_select;
    logic [1:0] h_select;

    assign mf_select = FS[4];
    assign g_select  = FS[3:0];
    assign h_select  = FS[1:0];

    // Señales internas
    logic [N-1:0] alu_out;
    logic [N-1:0] shifter_out;

    // Instancia de la ALU
    alu #(.N(N)) u_alu (
        .a(a),
        .b(b),
        .g_sel(g_select),
        .result(alu_out),
        .v(v),
        .c_flag(c),
        .n(n),
        .z(z),
        .flags(flags)
    );

    // Instancia del Shifter
    shifter #(.N(N)) u_shifter (
        .b(b),
        .h_sel(h_select),
        .y(shifter_out)
    );

    // MUX F: Selecciona entre ALU (0) y Shifter (1)
    assign F = (mf_select == 1'b0) ? alu_out : shifter_out;

endmodule
