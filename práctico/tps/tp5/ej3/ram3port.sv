// ============================================================================
// Trabajo Práctico Nro 5 - CPU: RTL y Módulos
// Ejercicio 3: Archivo de Registros (Register File) ram3port
//
// Características:
//   - Almacena 7 registros generales de 4 bits (R1 a R7).
//   - Dos puertos de lectura combinacionales independientes (RD1, RD2).
//   - Un puerto de escritura síncrono por flanco ascendente gobernado por WE3.
//   - La dirección 3'b000 está reservada:
//       * En lectura: entrega siempre 4'b0000.
//       * En escritura: no se escribe ningún registro (no-op).
// ============================================================================

`timescale 1ns / 1ps

module ram3port #(
    parameter int DATA_WIDTH = 4,
    parameter int ADDR_WIDTH = 3
)(
    input  logic                  clk,
    input  logic                  reset_n,
    input  logic [ADDR_WIDTH-1:0] A1,      // Dirección de lectura puerto 1
    input  logic [ADDR_WIDTH-1:0] A2,      // Dirección de lectura puerto 2
    input  logic [ADDR_WIDTH-1:0] A3,      // Dirección de escritura puerto 3
    input  logic                  WE3,     // Habilitación de escritura (Write Enable)
    input  logic [DATA_WIDTH-1:0] WD3,     // Datos de entrada a escribir (Write Data)
    output logic [DATA_WIDTH-1:0] RD1,     // Datos leídos en puerto 1 (Read Data 1)
    output logic [DATA_WIDTH-1:0] RD2      // Datos leídos en puerto 2 (Read Data 2)
);

    // Banco de registros internos: registros 1 a 7 de DATA_WIDTH bits
    // El índice 0 no se almacena físicamente como registro modificable.
    logic [DATA_WIDTH-1:0] rf [1:7];

    // ------------------------------------------------------------------------
    // ESCRITURA SÍNCRONA (Flanco ascendente de reloj)
    // Decodificador de escritura + carga en flanco si WE3=1 y A3 != 000
    // ------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (int i = 1; i <= 7; i++) begin
                rf[i] <= '0;
            end
        end
        else if (WE3 && (A3 != '0)) begin
            rf[A3] <= WD3;
        end
    end

    // ------------------------------------------------------------------------
    // LECTURA COMBINACIONAL (Dos multiplexores independientes)
    // Si la dirección es 3'b000, la salida es forzada a 0000.
    // ------------------------------------------------------------------------
    always_comb begin
        // Puerto de lectura 1 (RD1)
        if (A1 == '0) begin
            RD1 = '0;
        end else begin
            RD1 = rf[A1];
        end

        // Puerto de lectura 2 (RD2)
        if (A2 == '0) begin
            RD2 = '0;
        end else begin
            RD2 = rf[A2];
        end
    end

endmodule
