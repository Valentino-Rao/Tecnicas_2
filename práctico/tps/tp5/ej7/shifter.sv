// ============================================================================
// Trabajo Práctico Nro 5 - CPU: RTL y Módulos
// Ejercicio 7: Unidad de Corrimiento y Rotación Combinacional (Shifter)
//
// Operaciones controladas por H[2:0] (Cuadro 5):
// H[2:0] | Operación | Resultado
// ----------------------------------------------------------------------------
//  000   | Transf    | Y = D
//  001   | SHL       | Y = { D[N-2:0], 1'b0 }          (Shift Left)
//  010   | ASR       | Y = { D[N-1], D[N-1:1] }        (Arithmetic Shift Right)
//  011   | Bus 0     | Y = '0                          (Bus Cero)
//  100   | Transf    | Y = D
//  101   | ROL       | Y = { D[N-2:0], D[N-1] }        (Rotate Left)
//  110   | ROR       | Y = { D[0], D[N-1:1] }          (Rotate Right)
//  111   | Transf    | Y = D
// ============================================================================

`timescale 1ns / 1ps

module shifter #(
    parameter int N = 4
)(
    input  logic [N-1:0] d,  // Dato de entrada (proviene de la salida de la ALU)
    input  logic [2:0]   H,  // Código de control de 3 bits
    output logic [N-1:0] y   // Dato de salida del Shifter
);

    always_comb begin
        case (H)
            3'b000: y = d;                     // Transferencia directa
            3'b001: y = {d[N-2:0], 1'b0};      // SHL: Corrimiento a la izquierda (entra 0 por LSB)
            3'b010: y = {d[N-1], d[N-1:1]};    // ASR: Corrimiento a la derecha aritmético (extiende signo)
            3'b011: y = '0;                    // Bus cero
            3'b100: y = d;                     // Transferencia directa
            3'b101: y = {d[N-2:0], d[N-1]};    // ROL: Rotación a la izquierda (MSB pasa a LSB)
            3'b110: y = {d[0], d[N-1:1]};      // ROR: Rotación a la derecha (LSB pasa a MSB)
            3'b111: y = d;                     // Transferencia directa
            default: y = d;
        endcase
    end

endmodule
