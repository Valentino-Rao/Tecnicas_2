// ============================================================================
// Banco de pruebas (Testbench) para Ejercicio 8:
// Verificación Funcional de Microoperaciones del Cuadro 6 en el Datapath
// ============================================================================

`timescale 1ns / 1ps

module microcode_tb;

    localparam int N = 4;

    logic         clk;
    logic         reset_n;
    logic [15:0]  ctrl_word;
    logic [N-1:0] data_in;
    logic [3:0]   state_bits; // {V, S, Z, C}
    logic [N-1:0] data_out;

    int errores = 0;

    // Instancia del Datapath
    datapath #(.N(N)) dut (
        .clk(clk),
        .reset_n(reset_n),
        .ctrl_word(ctrl_word),
        .data_in(data_in),
        .state_bits(state_bits),
        .data_out(data_out)
    );

    // Generador de reloj (período 20 ns -> 50 MHz)
    always #10 clk = ~clk;

    // Tarea para cargar datos externos en un registro: Rx <= data_in
    task automatic load_register(input logic [2:0] reg_dest, input logic [N-1:0] valor);
        @(negedge clk);
        // H=000 (Transf), F=0000 (Transf A), D=reg_dest, B=000, A=000 (data_in)
        ctrl_word = {3'b000, 4'b0000, reg_dest, 3'b000, 3'b000};
        data_in   = valor;
        @(posedge clk);
        #1; // Hold time
        $display("[INIT] R%0d <= 0x%0X (%02d)", reg_dest, valor, valor);
    endtask

    // Tarea para ejecutar y verificar una microoperación
    task automatic exec_microop(
        input string       id_op,
        input string       desc,
        input logic [15:0] palabra,
        input logic [2:0]  reg_dest,
        input logic [N-1:0] exp_val
    );
        @(negedge clk);
        ctrl_word = palabra;
        data_in   = '0;
        @(posedge clk);
        #1; // Espera para que el registro se actualice y la salida sea estable

        $display("----------------------------------------------------------------------------------------");
        $display("[%s] %-20s | Word=0x%04X (H=%03b F=%04b D=%03b B=%03b A=%03b)",
                 id_op, desc, palabra,
                 palabra[15:13], palabra[12:9], palabra[8:6], palabra[5:3], palabra[2:0]);
        $display("     Resultado escrito en R%0d = 0x%0X (%02d) | Esperado = 0x%0X (%02d) | Flags={V:%b, S:%b, Z:%b, C:%b}",
                 reg_dest, dut.u_regfile.rf[reg_dest], dut.u_regfile.rf[reg_dest],
                 exp_val, exp_val,
                 state_bits[3], state_bits[2], state_bits[1], state_bits[0]);

        if (dut.u_regfile.rf[reg_dest] !== exp_val) begin
            $display("     >>> ERROR: R%0d tiene 0x%0X, se esperaba 0x%0X <<<",
                     reg_dest, dut.u_regfile.rf[reg_dest], exp_val);
            errores++;
        end else begin
            $display("     >>> OK: Operacion verificada correctamente.");
        end
    endtask

    initial begin
        clk = 0;
        reset_n = 0;
        ctrl_word = 0;
        data_in = 0;

        $dumpfile("datapath.vcd");
        $dumpvars(0, microcode_tb);

        $display("========================================================================================");
        $display("     TESTBENCH EJERCICIO 8: EJECUCION DE MICROOPERACIONES (CUADRO 6) EN DATAPATH         ");
        $display("========================================================================================");

        // Reset inicial
        #25;
        reset_n = 1;
        #15;

        // Carga de operandos iniciales requeridos:
        // R1 = 3, R4 = 2, R5 = 5, R6 = 10 (0xA), R7 = 7
        $display("\n>>> PASO 1: Precarga de operandos iniciales en Banco de Registros");
        load_register(3'd1, 4'd3);      // R1 = 3
        load_register(3'd4, 4'd2);      // R4 = 2
        load_register(3'd5, 4'd5);      // R5 = 5
        load_register(3'd6, 4'b1010);   // R6 = 10 (0xA)
        load_register(3'd7, 4'd7);      // R7 = 7

        $display("\n>>> PASO 2: Ejecucion secuencial de microoperaciones del Cuadro 6");

        // (a) R2 <- R1 + 1  --> 3 + 1 = 4
        // H=000, F=0001, D=010, B=000, A=001 -> 16'h0281
        exec_microop("(a)", "R2 <- R1 + 1", 16'h0281, 3'd2, 4'd4);

        // (b) R3 <- R4 + R5 --> 2 + 5 = 7
        // H=000, F=0010, D=011, B=101, A=100 -> 16'h04EC
        exec_microop("(b)", "R3 <- R4 + R5", 16'h04EC, 3'd3, 4'd7);

        // (c) R6 <- ~R6     --> ~10 (1010) = 5 (0101)
        // H=000, F=1110, D=110, B=000, A=110 -> 16'h1D86
        exec_microop("(c)", "R6 <- ~R6", 16'h1D86, 3'd6, 4'd5);

        // (d) R7 <- R7 - 1  --> 7 - 1 = 6
        // H=000, F=0110, D=111, B=000, A=111 -> 16'h0DC7
        exec_microop("(d)", "R7 <- R7 - 1", 16'h0DC7, 3'd7, 4'd6);

        // (e) R1 <- shl R1  --> shl 3 (0011) = 6 (0110)
        // H=001, F=0000, D=001, B=000, A=001 -> 16'h2041
        exec_microop("(e)", "R1 <- shl R1", 16'h2041, 3'd1, 4'd6);

        // (f) R2 <- ror R2  --> ror 4 (0100) = 2 (0010)
        // H=110, F=0000, D=010, B=000, A=010 -> 16'hC082
        exec_microop("(f)", "R2 <- ror R2", 16'hC082, 3'd2, 4'd2);

        // (g) R5 <- R3 + R1 --> 7 + 6 = 13 (0xD)
        // H=000, F=0010, D=101, B=001, A=011 -> 16'h054B
        exec_microop("(g)", "R5 <- R3 + R1", 16'h054B, 3'd5, 4'd13);

        // (h) R6 <- R7      --> R6 <- 6
        // H=000, F=0000, D=110, B=000, A=111 -> 16'h0187
        exec_microop("(h)", "R6 <- R7", 16'h0187, 3'd6, 4'd6);

        #30;
        $display("========================================================================================");
        if (errores == 0) begin
            $display(">>> TEST EJERCICIO 8 PASSED: Las 8 microoperaciones se ejecutaron y verificaron al 100%%! <<<");
        end else begin
            $display(">>> TEST EJERCICIO 8 FAILED: %0d errores detectados <<<", errores);
        end
        $display("========================================================================================");

        $finish;
    end

endmodule
