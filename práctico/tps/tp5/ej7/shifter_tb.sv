// ============================================================================
// Banco de pruebas (Testbench) para Ejercicio 7: Shifter Combinacional
//
// Verifica todas las operaciones de la unidad de corrimiento y rotación
// según el Cuadro 5, utilizando patrones de prueba que distinguen claramente
// cada operación (incluyendo diferencias entre SHL vs ROL y ASR vs ROR).
// ============================================================================

`timescale 1ns / 1ps

module shifter_tb;

    localparam int N = 4;

    logic [N-1:0] d;
    logic [2:0]   H;
    logic [N-1:0] y;

    int errores = 0;

    // Instancia del DUT
    shifter #(.N(N)) dut (
        .d(d),
        .H(H),
        .y(y)
    );

    task automatic check_shifter(
        input string nombre_op,
        input logic [N-1:0] val_d,
        input logic [2:0]   val_H,
        input logic [N-1:0] exp_y
    );
        d = val_d;
        H = val_H;
        #10;
        $display("[t=%0t ns] %-28s | H=%03b | D=%04b (0x%0X) | Y=%04b (0x%0X) | Exp=%04b",
                 $time, nombre_op, H, d, d, y, y, exp_y);

        if (y !== exp_y) begin
            $display("   --> ERROR: Obtenido %04b, Esperado %04b", y, exp_y);
            errores++;
        end
    endtask

    initial begin
        d = 0;
        H = 0;

        $dumpfile("shifter.vcd");
        $dumpvars(0, shifter_tb);

        $display("======================================================================================");
        $display("    TESTBENCH EJERCICIO 7: SHIFTER COMBINACIONAL (CORRIMIENTO Y ROTACION)             ");
        $display("======================================================================================");

        // --------------------------------------------------------------------
        // SERIE 1: Patrón D = 4'b1100 (Distingue inequívocamente todas las operaciones)
        // D = 1100
        // 000: Y = 1100 (Transf)
        // 001: Y = 1000 (SHL: 100 y 0)
        // 010: Y = 1110 (ASR: signo 1 se replica en MSB, desplaza 110)
        // 011: Y = 0000 (Bus Cero)
        // 100: Y = 1100 (Transf)
        // 101: Y = 1001 (ROL: 100 desplaza y MSB 1 pasa a LSB)
        // 110: Y = 0110 (ROR: LSB 0 pasa a MSB, desplaza 110)
        // 111: Y = 1100 (Transf)
        // --------------------------------------------------------------------
        $display("--- SERIE 1: Evaluacion con patron D = 4'b1100 (C) ---");
        check_shifter("H=000: Transferencia",      4'b1100, 3'b000, 4'b1100);
        check_shifter("H=001: Corrimiento SHL",    4'b1100, 3'b001, 4'b1000);
        check_shifter("H=010: Corrimiento ASR",    4'b1100, 3'b010, 4'b1110);
        check_shifter("H=011: Bus Cero",           4'b1100, 3'b011, 4'b0000);
        check_shifter("H=100: Transferencia",      4'b1100, 3'b100, 4'b1100);
        check_shifter("H=101: Rotacion ROL",       4'b1100, 3'b101, 4'b1001);
        check_shifter("H=110: Rotacion ROR",       4'b1100, 3'b110, 4'b0110);
        check_shifter("H=111: Transferencia",      4'b1100, 3'b111, 4'b1100);

        // --------------------------------------------------------------------
        // SERIE 2: Patrón D = 4'b1000 (Verifica ASR vs ROR con bit 0 en cero)
        // D = 1000
        // ASR: extiende bit 3 -> 1100
        // ROR: bit 0 es 0 -> rota a bit 3 -> 0100
        // ROL: bit 3 es 1 -> rota a bit 0 -> 0001
        // SHL: entra 0 por bit 0 -> 0000
        // --------------------------------------------------------------------
        $display("\n--- SERIE 2: Distincion ASR (1100) vs ROR (0100) con D = 4'b1000 ---");
        check_shifter("H=001: SHL D=1000",         4'b1000, 3'b001, 4'b0000);
        check_shifter("H=010: ASR D=1000",         4'b1000, 3'b010, 4'b1100);
        check_shifter("H=101: ROL D=1000",         4'b1000, 3'b101, 4'b0001);
        check_shifter("H=110: ROR D=1000",         4'b1000, 3'b110, 4'b0100);

        // --------------------------------------------------------------------
        // SERIE 3: Patrón D = 4'b0101 (Número positivo con LSB=1)
        // ASR: extiende bit 3 (0) -> 0010
        // ROR: bit 0 (1) pasa a MSB -> 1010
        // SHL: entra 0 por LSB -> 1010
        // ROL: bit 3 (0) pasa a LSB -> 1010
        // --------------------------------------------------------------------
        $display("\n--- SERIE 3: Evaluacion con numero positivo D = 4'b0101 ---");
        check_shifter("H=010: ASR D=0101",         4'b0101, 3'b010, 4'b0010);
        check_shifter("H=110: ROR D=0101",         4'b0101, 3'b110, 4'b1010);

        #10;
        $display("======================================================================================");
        if (errores == 0) begin
            $display(">>> TEST EJERCICIO 7 PASSED: Todas las operaciones verificadas exitosamente! <<<");
        end else begin
            $display(">>> TEST EJERCICIO 7 FAILED: %0d errores detectados <<<", errores);
        end
        $display("======================================================================================");

        $finish;
    end

endmodule
