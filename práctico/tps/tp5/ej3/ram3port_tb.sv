// ============================================================================
// Banco de pruebas (Testbench) para Ejercicio 3: ram3port
// Verificaciones requeridas:
//   1. Reset inicial.
//   2. Lectura en dirección 000 entrega 4'b0000.
//   3. Escritura secuencial en R1..R7 con WE3=1.
//   4. Lectura simultánea e independiente en RD1 y RD2 de dos registros distintos.
//   5. Ausencia de escritura cuando WE3=0 (retención de datos).
//   6. Intento de escritura en dirección 000 ignorado.
// ============================================================================

`timescale 1ns / 1ps

module ram3port_tb;

    localparam int DATA_WIDTH = 4;
    localparam int ADDR_WIDTH = 3;

    logic                  clk;
    logic                  reset_n;
    logic [ADDR_WIDTH-1:0] A1;
    logic [ADDR_WIDTH-1:0] A2;
    logic [ADDR_WIDTH-1:0] A3;
    logic                  WE3;
    logic [DATA_WIDTH-1:0] WD3;
    logic [DATA_WIDTH-1:0] RD1;
    logic [DATA_WIDTH-1:0] RD2;

    int errores = 0;

    // Instancia del DUT
    ram3port #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .A1(A1),
        .A2(A2),
        .A3(A3),
        .WE3(WE3),
        .WD3(WD3),
        .RD1(RD1),
        .RD2(RD2)
    );

    // Reloj de 100 MHz (periodo 10 ns)
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset_n = 0;
        A1 = 0;
        A2 = 0;
        A3 = 0;
        WE3 = 0;
        WD3 = 0;

        $dumpfile("ram3port.vcd");
        $dumpvars(0, ram3port_tb);

        $display("=========================================================");
        $display("   TESTBENCH EJERCICIO 3: ARCHIVO DE REGISTROS ram3port   ");
        $display("=========================================================");

        // 1. Reset
        #12;
        reset_n = 1;
        #8;
        $display("[%0t ns] Reset liberado.", $time);

        // 2. Verificar que dirección 000 entregue 0000
        A1 = 3'b000;
        A2 = 3'b000;
        #1;
        $display("[%0t ns] Lectura direccion 000: RD1=%0b, RD2=%0b (esperado 0000)", $time, RD1, RD2);
        if (RD1 !== 4'b0000 || RD2 !== 4'b0000) begin
            $display("ERROR: Direccion 000 no retorno 0000.");
            errores++;
        end

        // 3. Escribir datos distintos en R1 a R7
        //    R1=0x1, R2=0x2, R3=0x3, R4=0x4, R5=0x5, R6=0x6, R7=0x7
        for (int i = 1; i <= 7; i++) begin
            @(negedge clk);
            A3 = i[2:0];
            WD3 = i[3:0] ^ 4'hA; // Patrón de datos (ej. 1^A=B, 2^A=8...)
            WE3 = 1;
            @(posedge clk);
            #1;
            $display("[%0t ns] Escritura R%0d <= 0x%0X (WE3=1)", $time, i, WD3);
        end

        @(negedge clk);
        WE3 = 0; // Deshabilitar escritura

        // 4. Lectura simultánea de dos registros diferentes (RD1 lee R2, RD2 lee R5)
        @(negedge clk);
        A1 = 3'd2; // R2
        A2 = 3'd5; // R5
        #1;
        $display("[%0t ns] Lectura simultanea combinacional: RD1(R2)=0x%0X (esp 0x%0X), RD2(R5)=0x%0X (esp 0x%0X)",
                 $time, RD1, (2 ^ 4'hA), RD2, (5 ^ 4'hA));
        if (RD1 !== (2 ^ 4'hA) || RD2 !== (5 ^ 4'hA)) begin
            $display("ERROR: Fallo en lectura simultanea.");
            errores++;
        end

        // 5. Lectura simultánea de otro par (RD1 lee R7, RD2 lee R1)
        A1 = 3'd7; // R7
        A2 = 3'd1; // R1
        #1;
        $display("[%0t ns] Lectura simultanea combinacional: RD1(R7)=0x%0X (esp 0x%0X), RD2(R1)=0x%0X (esp 0x%0X)",
                 $time, RD1, (7 ^ 4'hA), RD2, (1 ^ 4'hA));
        if (RD1 !== (7 ^ 4'hA) || RD2 !== (1 ^ 4'hA)) begin
            $display("ERROR: Fallo en lectura simultanea R7 y R1.");
            errores++;
        end

        // 6. Verificar ausencia de escritura cuando WE3 = 0
        @(negedge clk);
        A3 = 3'd3;    // Apuntar a R3
        WD3 = 4'hF;   // Intentar escribir 0xF
        WE3 = 0;      // Pero con WE3 = 0
        @(posedge clk);
        #1;
        // Leer R3 para confirmar que NO cambió
        A1 = 3'd3;
        #1;
        $display("[%0t ns] Intento de escritura con WE3=0 en R3. RD1(R3)=0x%0X (esperado previo 0x%0X)",
                 $time, RD1, (3 ^ 4'hA));
        if (RD1 !== (3 ^ 4'hA)) begin
            $display("ERROR: Se modifico el registro R3 a pesar de que WE3=0!");
            errores++;
        end

        // 7. Verificar intento de escritura en direccion 000 con WE3 = 1
        @(negedge clk);
        A3 = 3'd0;    // Dirección reservada 000
        WD3 = 4'hE;
        WE3 = 1;
        @(posedge clk);
        #1;
        A1 = 3'd0;
        #1;
        $display("[%0t ns] Intento de escritura en dir 000 con WE3=1. RD1(000)=0x%0X (debe ser 0x0)", $time, RD1);
        if (RD1 !== 4'h0) begin
            $display("ERROR: La direccion 000 fue sobreescrita!");
            errores++;
        end

        #20;
        $display("=========================================================");
        if (errores == 0) begin
            $display(">>> TEST EJERCICIO 3 PASSED: Todos los casos exitosos! <<<");
        end else begin
            $display(">>> TEST EJERCICIO 3 FAILED: %0d errores detectados <<<", errores);
        end
        $display("=========================================================");

        $finish;
    end

endmodule
