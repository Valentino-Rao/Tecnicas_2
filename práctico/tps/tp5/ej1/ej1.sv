// ============================================================================
// Trabajo Práctico Nro 5 - CPU: RTL y Módulos
// Ejercicio 1: Intercambio de registros controlado por variable T3
// Instrucción de transferencia: T3 : R2 <= R1, R1 <= R2
// ============================================================================

`timescale 1ns / 1ps

module intercambio #(
    parameter int N = 8,
    parameter logic [N-1:0] INIT_R1 = 8'hA5,
    parameter logic [N-1:0] INIT_R2 = 8'h3C
)(
    input  logic         clk,
    input  logic         reset_n,
    input  logic         T3,
    output logic [N-1:0] R1,
    output logic [N-1:0] R2
);

    // En flanco ascendente de reloj, si T3 = 1 se realiza la transferencia simultánea.
    // Las asignaciones no bloqueantes (<=) garantizan que ambos registros
    // tomen el valor previo del otro registro sin colisión de lectura/escritura.
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            R1 <= INIT_R1;
            R2 <= INIT_R2;
        end
        else if (T3) begin
            R1 <= R2;
            R2 <= R1;
        end
        // Si T3 == 0, se mantiene el estado previo (retención)
    end

endmodule
