// ============================================================================
// Trabajo Práctico Nro 5 - CPU: RTL y Módulos
// Punto 4: Banco de Registros (Register File 2^m x n)
//
// Estructura según Figuras de Páginas 3 y 4 de ejercicio_adicional.pdf:
// - Arreglo de 4 registros: R0, R1, R2, R3 (m = 2, n = 4 por defecto).
// - Decodificador 2 a 4 con Load Enable para habilitar la carga en flanco de reloj.
// - Dos multiplexores 4 a 1 independientes para lectura combinacional (A data y B data).
// ============================================================================

`timescale 1ns / 1ps

module register_file #(
    parameter int N = 4, // Ancho de palabra de datos (n)
    parameter int M = 2  // Ancho de dirección (m) -> 2^M = 4 registros
)(
    input  logic         clk,
    input  logic         reset_n,
    input  logic         load_en,  // Load Enable (Write)
    input  logic [M-1:0] d_addr,   // D address (Destination select)
    input  logic [N-1:0] d_data,   // D data (Dato de entrada a escribir)
    input  logic [M-1:0] a_addr,   // A address (A select)
    input  logic [M-1:0] b_addr,   // B address (B select)
    output logic [N-1:0] a_data,   // A data (Salida del puerto A)
    output logic [N-1:0] b_data    // B data (Salida del puerto B)
);

    localparam int NUM_REGS = 1 << M; // 4 registros (R0 a R3)

    // Registros físicos internos
    logic [N-1:0] regs [NUM_REGS-1:0];

    // Decodificador 2 a 4 para habilitación de carga de cada registro
    logic [NUM_REGS-1:0] load;

    always_comb begin
        for (int i = 0; i < NUM_REGS; i++) begin
            load[i] = load_en & (d_addr == i[M-1:0]);
        end
    end

    // Escritura síncrona por flanco ascendente de reloj con reset activo en bajo
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (int i = 0; i < NUM_REGS; i++) begin
                regs[i] <= '0;
            end
        end else begin
            for (int i = 0; i < NUM_REGS; i++) begin
                if (load[i]) begin
                    regs[i] <= d_data;
                end
            end
        end
    end

    // Lectura combinacional mediante dos multiplexores 4:1
    assign a_data = regs[a_addr];
    assign b_data = regs[b_addr];

endmodule
