// ============================================================================
// Banco de pruebas (Testbench) para Ejercicio 2: Transferencias a R5
// ============================================================================

`timescale 1ns / 1ps

module ej2_tb;

    localparam int N = 4;

    logic clk;
    logic reset_n;
    logic [3:0] T;
    logic [N-1:0] R0, R1, R2, R3;
    logic [1:0] S;
    logic load_en;
    logic [N-1:0] bus_data;
    logic [N-1:0] R5;

    int errores = 0;

    // Instancia del DUT
    mux_transfer_r5 #(.N(N)) dut (
        .clk(clk),
        .reset_n(reset_n),
        .T(T),
        .R0(R0),
        .R1(R1),
        .R2(R2),
        .R3(R3),
        .S(S),
        .load_en(load_en),
        .bus_data(bus_data),
        .R5(R5)
    );

    // Reloj a 100 MHz (periodo 10 ns)
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset_n = 0;
        T = 4'b0000;
        R0 = 4'hA; // 1010
        R1 = 4'h5; // 0101
        R2 = 4'hC; // 1100
        R3 = 4'h3; // 0011

        $dumpfile("ej2.vcd");
        $dumpvars(0, ej2_tb);

        $display("=========================================================");
        $display("   TESTBENCH EJERCICIO 2: TRANSFERENCIAS MULTIPLEXADAS   ");
        $display("   R0=0x%0X, R1=0x%0X, R2=0x%0X, R3=0x%0X               ", R0, R1, R2, R3);
        $display("=========================================================");

        // 1. Reset
        #12;
        reset_n = 1;
        #8;
        $display("[%0t ns] Reset liberado. R5 = 0x%0X (esperado 0x0)", $time, R5);
        if (R5 !== 4'h0) begin
            $display("ERROR: R5 no inicio en 0 tras reset.");
            errores++;
        end

        // 2. Sin señal de control T = 0000 (load_en = 0, R5 debe mantenerse en 0)
        @(negedge clk);
        T = 4'b0000;
        @(posedge clk);
        #1;
        $display("[%0t ns] T=0000 -> load_en=%0b, R5=0x%0X", $time, load_en, R5);
        if (load_en !== 0 || R5 !== 4'h0) begin
            $display("ERROR: Carga indebida sin señales T activas.");
            errores++;
        end

        // 3. T0 activa: R5 <= R0 (0xA)
        @(negedge clk);
        T = 4'b0001;
        #1;
        if (S !== 2'b00 || load_en !== 1 || bus_data !== R0) begin
            $display("ERROR combinacional en T0: S=%0b, load_en=%0b, bus=%0X", S, load_en, bus_data);
            errores++;
        end
        @(posedge clk);
        #1;
        $display("[%0t ns] T0=1 -> S=%0b, load_en=%0b, R5=0x%0X (esperado 0x%0X)", $time, S, load_en, R5, R0);
        if (R5 !== R0) begin
            $display("ERROR: R5 no cargo R0.");
            errores++;
        end

        // 4. Pausa T = 0000: R5 debe retener R0 (0xA)
        @(negedge clk);
        T = 4'b0000;
        @(posedge clk);
        #1;
        $display("[%0t ns] T=0000 -> Retencion de R5=0x%0X", $time, R5);
        if (R5 !== R0) begin
            $display("ERROR: R5 no retuvo su valor.");
            errores++;
        end

        // 5. T1 activa: R5 <= R1 (0x5)
        @(negedge clk);
        T = 4'b0010;
        @(posedge clk);
        #1;
        $display("[%0t ns] T1=1 -> S=%0b, load_en=%0b, R5=0x%0X (esperado 0x%0X)", $time, S, load_en, R5, R1);
        if (R5 !== R1 || S !== 2'b01) begin
            $display("ERROR: R5 no cargo R1 o S incorrecto.");
            errores++;
        end

        // 6. T2 activa: R5 <= R2 (0xC)
        @(negedge clk);
        T = 4'b0100;
        @(posedge clk);
        #1;
        $display("[%0t ns] T2=1 -> S=%0b, load_en=%0b, R5=0x%0X (esperado 0x%0X)", $time, S, load_en, R5, R2);
        if (R5 !== R2 || S !== 2'b10) begin
            $display("ERROR: R5 no cargo R2 o S incorrecto.");
            errores++;
        end

        // 7. T3 activa: R5 <= R3 (0x3)
        @(negedge clk);
        T = 4'b1000;
        @(posedge clk);
        #1;
        $display("[%0t ns] T3=1 -> S=%0b, load_en=%0b, R5=0x%0X (esperado 0x%0X)", $time, S, load_en, R5, R3);
        if (R5 !== R3 || S !== 2'b11) begin
            $display("ERROR: R5 no cargo R3 o S incorrecto.");
            errores++;
        end

        // 8. Retención final
        @(negedge clk);
        T = 4'b0000;
        @(posedge clk);
        #1;
        $display("[%0t ns] T=0000 -> Retencion final R5=0x%0X", $time, R5);
        if (R5 !== R3) begin
            $display("ERROR en retencion final.");
            errores++;
        end

        #20;
        $display("=========================================================");
        if (errores == 0) begin
            $display(">>> TEST EJERCICIO 2 PASSED: Todos los casos exitosos! <<<");
        end else begin
            $display(">>> TEST EJERCICIO 2 FAILED: %0d errores detectados <<<", errores);
        end
        $display("=========================================================");

        $finish;
    end

endmodule
