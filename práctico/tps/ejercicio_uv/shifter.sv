// ============================================================================
// Trabajo Práctico Nro 5 - CPU: RTL y Módulos
// Punto 4: Unidad de Corrimiento (Shifter)
//
// Tabla 1 de operaciones (Punto 2.a de ejercicio_adicional.pdf):
// H1 H0 | Operación             | RTL (4 bits)
// ----------------------------------------------------------------------------
//  0  0 | Transferencia         | Y = B
//  0  1 | Corrimiento a la izq  | Y = { B[N-2:0], 1'b0 } (SHL con IR = 0)
//  1  0 | Corrimiento a la der  | Y = { 1'b0, B[N-1:1] } (SHR con IL = 0)
//  1  1 | Cero                  | Y = 4'b0000
// ============================================================================

`timescale 1ns / 1ps

module shifter #(
    parameter int N = 4
)(
    input  logic [N-1:0] b,      // Operando B (proviene de BUS B)
    input  logic [1:0]   h_sel,  // H Select [1:0] = {H1, H0}
    output logic [N-1:0] y       // Salida del Shifter
);

    always_comb begin
        case (h_sel)
            2'b00:   y = b;                  // Transferencia directa
            2'b01:   y = {b[N-2:0], 1'b0};   // SHL (entra 0 por LSB)
            2'b10:   y = {1'b0, b[N-1:1]};   // SHR (entra 0 por MSB)
            2'b11:   y = '0;                 // Cero
            default: y = b;
        endcase
    end

endmodule
