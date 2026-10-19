// ============================================================================
// Banco de pruebas (Testbench) para Ejercicio 1: intercambio de registros
// ============================================================================

`timescale 1ns / 1ps

module ej1_tb;

    localparam int N = 8;
    localparam logic [N-1:0] VAL_A = 8'hA5; // 10100101
    localparam logic [N-1:0] VAL_B = 8'h3C; // 00111100

    logic clk;
    logic reset_n;
    logic T3;
    logic [N-1:0] R1;
    logic [N-1:0] R2;

    int errores = 0;

    // Instancia del módulo bajo prueba (DUT)
    intercambio #(
        .N(N),
        .INIT_R1(VAL_A),
        .INIT_R2(VAL_B)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .T3(T3),
        .R1(R1),
        .R2(R2)
    );

    // Generador de reloj: periodo = 10 ns (100 MHz)
    always #5 clk = ~clk;

    initial begin
        // Inicialización de señales
        clk = 0;
        reset_n = 0;
        T3 = 0;

        $dumpfile("ej1.vcd");
        $dumpvars(0, ej1_tb);

        $display("=========================================================");
        $display("   TESTBENCH EJERCICIO 1: INTERCAMBIO T3: R2<-R1, R1<-R2  ");
        $display("=========================================================");

        // 1. Fase de Reset
        #12;
        reset_n = 1;
        #8;
        $display("[%0t ns] Reset liberado. R1 = 0x%02X, R2 = 0x%02X", $time, R1, R2);
        if (R1 !== VAL_A || R2 !== VAL_B) begin
            $display("ERROR: Valores iniciales incorrectos tras reset.");
            errores++;
        end

        // 2. Ciclo con T3 = 0 (Debe retener estado)
        @(posedge clk);
        #1;
        $display("[%0t ns] T3=0 (Retención). R1 = 0x%02X, R2 = 0x%02X", $time, R1, R2);
        if (R1 !== VAL_A || R2 !== VAL_B) begin
            $display("ERROR: Los registros no retuvieron el valor con T3=0.");
            errores++;
        end

        // 3. Activar T3 = 1 durante un flanco de reloj (Intercambio 1)
        @(negedge clk);
        T3 = 1;
        @(posedge clk);
        #1;
        $display("[%0t ns] Flanco con T3=1 -> Intercambio ejecutado.", $time);
        $display("         R1 = 0x%02X (esperado 0x%02X), R2 = 0x%02X (esperado 0x%02X)", R1, VAL_B, R2, VAL_A);
        if (R1 !== VAL_B || R2 !== VAL_A) begin
            $display("ERROR: Falló el primer intercambio.");
            errores++;
        end

        // 4. Desactivar T3 = 0 (Retención con valores intercambiados)
        @(negedge clk);
        T3 = 0;
        @(posedge clk);
        #1;
        $display("[%0t ns] T3=0 (Retención post-swap). R1 = 0x%02X, R2 = 0x%02X", $time, R1, R2);
        if (R1 !== VAL_B || R2 !== VAL_A) begin
            $display("ERROR: Falló la retención post-intercambio.");
            errores++;
        end

        // 5. Segundo intercambio (Debe retornar a los valores originales)
        @(negedge clk);
        T3 = 1;
        @(posedge clk);
        #1;
        $display("[%0t ns] Flanco con T3=1 -> Segundo intercambio.", $time);
        $display("         R1 = 0x%02X (esperado 0x%02X), R2 = 0x%02X (esperado 0x%02X)", R1, VAL_A, R2, VAL_B);
        if (R1 !== VAL_A || R2 !== VAL_B) begin
            $display("ERROR: Falló el segundo intercambio.");
            errores++;
        end

        @(negedge clk);
        T3 = 0;
        #20;

        $display("=========================================================");
        if (errores == 0) begin
            $display(">>> TEST EJERCICIO 1 PASSED: Todos los casos exitosos! <<<");
        end else begin
            $display(">>> TEST EJERCICIO 1 FAILED: %0d errores detectados <<<", errores);
        end
        $display("=========================================================");

        $finish;
    end

endmodule
