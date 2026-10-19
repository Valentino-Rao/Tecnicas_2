// ============================================================================
// Trabajo Práctico Nro 5 - CPU: RTL y Módulos
// Ejercicio 8: Datapath (Unidad Procesadora) de 4 bits
//
// Integra:
//   - Archivo de registros ram3port (R1 a R7)
//   - Multiplexores de entrada externa para Bus A y Bus B
//   - Unidad Aritmético-Lógica (ALU) con generación de banderas
//   - Unidad de corrimiento y rotación (Shifter)
//   - Registro de estado para banderas (flags: V, S, Z, C)
//
// Palabra de Control de 16 bits:
//   H[15:13] | F[12:9] | D[8:6] | B[5:3] | A[2:0]
// ============================================================================

`timescale 1ns / 1ps

module datapath #(
    parameter int N = 4
)(
    input  logic         clk,
    input  logic         reset_n,
    input  logic [15:0]  ctrl_word,  // Palabra de control de 16 bits
    input  logic [N-1:0] data_in,    // Entrada externa de datos
    output logic [3:0]   state_bits, // Banderas registradas {V, S, Z, C}
    output logic [N-1:0] data_out    // Salida del Shifter / Bus de datos interno
);

    // Campos decodificados de la palabra de control
    logic [2:0] A_field;
    logic [2:0] B_field;
    logic [2:0] D_field;
    logic [3:0] F_field;
    logic [2:0] H_field;

    assign A_field = ctrl_word[2:0];
    assign B_field = ctrl_word[5:3];
    assign D_field = ctrl_word[8:6];
    assign F_field = ctrl_word[12:9];
    assign H_field = ctrl_word[15:13];

    // Señales de interconexión interna
    logic [N-1:0] reg_a;
    logic [N-1:0] reg_b;
    logic [N-1:0] bus_a;
    logic [N-1:0] bus_b;
    logic [N-1:0] alu_result;
    logic [3:0]   alu_flags;

    // 1. Archivo de registros (Register File)
    // El puerto 000 en D deshabilita escritura: we = (D_field != 3'b000)
    ram3port #(
        .DATA_WIDTH(N),
        .ADDR_WIDTH(3)
    ) u_regfile (
        .clk(clk),
        .reset_n(reset_n),
        .A1(A_field),
        .A2(B_field),
        .A3(D_field),
        .WE3(D_field != 3'b000),
        .WD3(data_out),
        .RD1(reg_a),
        .RD2(reg_b)
    );

    // 2. Muxes de operandos de entrada a la ALU
    // El código 000 en A o B selecciona la entrada externa (data_in)
    assign bus_a = (A_field != 3'b000) ? reg_a : data_in;
    assign bus_b = (B_field != 3'b000) ? reg_b : data_in;

    // 3. Unidad Aritmético-Lógica (ALU) con banderas
    alu #(
        .N(N)
    ) u_alu (
        .a(bus_a),
        .b(bus_b),
        .F(F_field),
        .result(alu_result),
        .flags(alu_flags)
    );

    // 4. Unidad de corrimiento (Shifter)
    shifter #(
        .N(N)
    ) u_shifter (
        .d(alu_result),
        .H(H_field),
        .y(data_out)
    );

    // 5. Registro de Banderas de Estado (Flip-Flops de estado)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state_bits <= 4'b0000;
        end else begin
            state_bits <= alu_flags;
        end
    end

endmodule

// ----------------------------------------------------------------------------
// Submódulo ram3port embebido para integración directa
// ----------------------------------------------------------------------------
module ram3port #(
    parameter int DATA_WIDTH = 4,
    parameter int ADDR_WIDTH = 3
)(
    input  logic                  clk,
    input  logic                  reset_n,
    input  logic [ADDR_WIDTH-1:0] A1,
    input  logic [ADDR_WIDTH-1:0] A2,
    input  logic [ADDR_WIDTH-1:0] A3,
    input  logic                  WE3,
    input  logic [DATA_WIDTH-1:0] WD3,
    output logic [DATA_WIDTH-1:0] RD1,
    output logic [DATA_WIDTH-1:0] RD2
);
    logic [DATA_WIDTH-1:0] rf [1:7];

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (int i = 1; i <= 7; i++) begin
                rf[i] <= '0;
            end
        end else if (WE3 && (A3 != '0)) begin
            rf[A3] <= WD3;
        end
    end

    always_comb begin
        RD1 = (A1 == '0) ? '0 : rf[A1];
        RD2 = (A2 == '0) ? '0 : rf[A2];
    end
endmodule

// ----------------------------------------------------------------------------
// Submódulo ALU embebido para integración directa
// ----------------------------------------------------------------------------
module alu #(
    parameter int N = 4
)(
    input  logic [N-1:0] a,
    input  logic [N-1:0] b,
    input  logic [3:0]   F,
    output logic [N-1:0] result,
    output logic [3:0]   flags
);
    logic [1:0] s;
    assign s = F[2:1];

    logic [N-1:0] y_arit;
    logic [N-1:0] sum_arit;
    logic [N-1:0] logic_out;
    logic [N:0]   c;

    always_comb begin
        case (s)
            2'b00:   y_arit = '0;
            2'b01:   y_arit = b;
            2'b10:   y_arit = ~b;
            2'b11:   y_arit = '1;
            default: y_arit = '0;
        endcase
    end

    assign c[0] = F[0];
    genvar i;
    generate
        for (i = 0; i < N; i++) begin : gen_fa
            assign sum_arit[i] = a[i] ^ y_arit[i] ^ c[i];
            assign c[i+1]      = (a[i] & y_arit[i]) | (c[i] & (a[i] ^ y_arit[i]));
        end
    endgenerate

    always_comb begin
        case (s)
            2'b00:   logic_out = a & b;
            2'b01:   logic_out = a | b;
            2'b10:   logic_out = a ^ b;
            2'b11:   logic_out = ~a;
            default: logic_out = '0;
        endcase
    end

    assign result = (F[3] == 1'b0) ? sum_arit : logic_out;

    logic flag_s, flag_z, flag_c, flag_v;
    assign flag_s = result[N-1];
    assign flag_z = (result == '0);
    assign flag_c = (F[3] == 1'b0) ? c[N] : 1'b0;
    assign flag_v = (F[3] == 1'b0) ? (c[N] ^ c[N-1]) : 1'b0;

    assign flags = {flag_v, flag_s, flag_z, flag_c};
endmodule

// ----------------------------------------------------------------------------
// Submódulo Shifter embebido para integración directa
// ----------------------------------------------------------------------------
module shifter #(
    parameter int N = 4
)(
    input  logic [N-1:0] d,
    input  logic [2:0]   H,
    output logic [N-1:0] y
);
    always_comb begin
        case (H)
            3'b000: y = d;
            3'b001: y = {d[N-2:0], 1'b0};
            3'b010: y = {d[N-1], d[N-1:1]};
            3'b011: y = '0;
            3'b100: y = d;
            3'b101: y = {d[N-2:0], d[N-1]};
            3'b110: y = {d[0], d[N-1:1]};
            3'b111: y = d;
            default: y = d;
        endcase
    end
endmodule
