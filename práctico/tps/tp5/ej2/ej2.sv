// ============================================================================
// Trabajo Práctico Nro 5 - CPU: RTL y Módulos
// Ejercicio 2: Transferencias multiplexadas a registro destino R5
//
// Transferencias:
//   T0 : R5 <= R0
//   T1 : R5 <= R1
//   T2 : R5 <= R2
//   T3 : R5 <= R3
// ============================================================================

`timescale 1ns / 1ps

module mux_transfer_r5 #(
    parameter int N = 4
)(
    input  logic         clk,
    input  logic         reset_n,
    input  logic [3:0]   T,        // Variables de sincronización [T3, T2, T1, T0]
    input  logic [N-1:0] R0,       // Datos del registro R0
    input  logic [N-1:0] R1,       // Datos del registro R1
    input  logic [N-1:0] R2,       // Datos del registro R2
    input  logic [N-1:0] R3,       // Datos del registro R3
    output logic [1:0]   S,        // Señales de selección del MUX (observabilidad)
    output logic         load_en,  // Habilitación de carga de R5 (observabilidad)
    output logic [N-1:0] bus_data, // Bus multiplexado a la entrada de R5
    output logic [N-1:0] R5        // Registro destino R5
);

    // ------------------------------------------------------------------------
    // SECCIÓN 1: Lógica Combinacional
    // a) Codificador de sincronización: genera señales de selección S y load_en
    // ------------------------------------------------------------------------
    always_comb begin
        // Habilitación de carga activa si alguna variable Ti está en 1
        load_en = |T; // T[0] | T[1] | T[2] | T[3]

        // Ecuaciones mínimas para selección:
        // S1 = T2 | T3
        // S0 = T1 | T3
        S[1] = T[2] | T[3];
        S[0] = T[1] | T[3];
    end

    // b) Multiplexor 4 a 1 de N bits: selecciona el registro a transferir
    always_comb begin
        case (S)
            2'b00:   bus_data = R0;
            2'b01:   bus_data = R1;
            2'b10:   bus_data = R2;
            2'b11:   bus_data = R3;
            default: bus_data = '0;
        endcase
    end

    // ------------------------------------------------------------------------
    // SECCIÓN 2: Carga Secuencial
    // Registro sincrónico R5 con reset asíncrono y habilitación de carga
    // ------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            R5 <= '0;
        end
        else if (load_en) begin
            R5 <= bus_data;
        end
        // Si load_en == 0 (todas las T en 0), R5 retiene su valor
    end

endmodule
