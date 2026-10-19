// ============================================================================
// Trabajo Práctico Nro 5 - CPU: RTL y Módulos
// Punto 4: Unidad Procesadora (Datapath de Morris Mano - Arquitectura Harvard)
//
// Módulo de jerarquía superior (Top-Level) correspondiente a las figuras de
// las Páginas 3 y 4 de ejercicio_adicional.pdf.
//
// Componentes interconectados:
// 1. FILA DE REGISTROS (register_file):
//    - 4 registros de N bits (R0 a R3)
//    - Decodificador 2 a 4 con Load Enable (Write)
//    - Puertos de lectura A data y B data con MUX 4:1
// 2. MULTIPLEXOR B (MUX B):
//    - Selecciona entre B data (0) y Constant IN (1) gobernado por MB select
//    - Produce BUS B y la Salida de Datos externa (Data out)
// 3. BUS A:
//    - Conecta directamente A data con la Salida de Direcciones (Address out)
//      y con la entrada A de la Unidad Funcional
// 4. UNIDAD FUNCIONAL (function_unit):
//    - Integra ALU y Shifter con selección por FS[4:0]
//    - Produce el resultado F y las banderas {V, C, N, Z}
// 5. MULTIPLEXOR D (MUX D):
//    - Selecciona entre F (0) y Dato de Entrada (Data in) (1) según MD select
//    - Conecta su salida (D data) al puerto de escritura de los registros
// ============================================================================

`timescale 1ns / 1ps

module unidad_procesadora #(
    parameter int N = 4, // Ancho de datos (n)
    parameter int M = 2  // Ancho de dirección (m) -> 2^M = 4 registros
)(
    input  logic         clk,
    input  logic         reset_n,

    // Señales de Control individuales
    input  logic         load_en,     // Load Enable (Habilitación de escritura en registro)
    input  logic [M-1:0] d_addr,      // Destination select / D address (DA)
    input  logic [M-1:0] a_addr,      // A select / A address (AA)
    input  logic [M-1:0] b_addr,      // B select / B address (BA)
    input  logic         mb_select,   // MB select (0: B data, 1: Constant IN)
    input  logic [4:0]   fs,          // Function Select [4:0] (FS)
    input  logic         md_select,   // MD select (0: Function Unit F, 1: Data in)

    // Entradas de Datos externas
    input  logic [N-1:0] constant_in, // Constant IN (Constante inmediata)
    input  logic [N-1:0] data_in,     // Data in (Dato de entrada desde memoria externa)

    // Salidas externas
    output logic [N-1:0] address_out, // Salida de Direcciones (conectada a BUS A)
    output logic [N-1:0] data_out,    // Salida de Datos (conectada a BUS B)
    output logic         v,           // Bandera V (Desborde en Complemento a 2)
    output logic         c,           // Bandera C (Acarreo de salida)
    output logic         n,           // Bandera N (Negativo / Bit de signo)
    output logic         z,           // Bandera Z (Cero)
    output logic [3:0]   flags,       // Banderas de estado agrupadas {V, C, N, Z}

    // Salidas de diagnóstico para verificación y simulación en ModelSim
    output logic [N-1:0] r0_out,
    output logic [N-1:0] r1_out,
    output logic [N-1:0] r2_out,
    output logic [N-1:0] r3_out
);

    // Buses internos principales
    logic [N-1:0] a_data;
    logic [N-1:0] b_data;
    logic [N-1:0] bus_a;
    logic [N-1:0] bus_b;
    logic [N-1:0] func_f;
    logic [N-1:0] d_data;

    // ------------------------------------------------------------------------
    // 1. BANCO DE REGISTROS (FILA DE REGISTROS R0 a R3)
    // ------------------------------------------------------------------------
    register_file #(
        .N(N),
        .M(M)
    ) u_reg_file (
        .clk(clk),
        .reset_n(reset_n),
        .load_en(load_en),
        .d_addr(d_addr),
        .d_data(d_data),
        .a_addr(a_addr),
        .b_addr(b_addr),
        .a_data(a_data),
        .b_data(b_data)
    );

    // Salidas de monitoreo de registros para el testbench
    assign r0_out = u_reg_file.regs[0];
    assign r1_out = u_reg_file.regs[1];
    assign r2_out = u_reg_file.regs[2];
    assign r3_out = u_reg_file.regs[3];

    // ------------------------------------------------------------------------
    // 2. BUS A Y SALIDA DE DIRECCIONES
    // ------------------------------------------------------------------------
    assign bus_a       = a_data;
    assign address_out = bus_a;

    // ------------------------------------------------------------------------
    // 3. MUX B Y SALIDA DE DATOS
    // ------------------------------------------------------------------------
    assign bus_b    = (mb_select == 1'b0) ? b_data : constant_in;
    assign data_out = bus_b;

    // ------------------------------------------------------------------------
    // 4. UNIDAD FUNCIONAL (ALU + SHIFTER + MUX F)
    // ------------------------------------------------------------------------
    function_unit #(
        .N(N)
    ) u_func_unit (
        .a(bus_a),
        .b(bus_b),
        .FS(fs),
        .F(func_f),
        .v(v),
        .c(c),
        .n(n),
        .z(z),
        .flags(flags)
    );

    // ------------------------------------------------------------------------
    // 5. MUX D (SELECCIÓN DE D DATA)
    // ------------------------------------------------------------------------
    assign d_data = (md_select == 1'b0) ? func_f : data_in;

endmodule
