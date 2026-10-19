// ============================================================================
// Banco de pruebas (Testbench) para Ejercicio 5: ALU Aritmético-Lógica
// ============================================================================

`timescale 1ns / 1ps

module alu_tb;

    localparam int N = 4;

    logic [N-1:0] a;
    logic [N-1:0] b;
    logic [3:0]   F;
    logic [N-1:0] result;

    int errores = 0;

    // Instancia del DUT
    alu #(.N(N)) dut (
        .a(a),
        .b(b),
        .F(F),
        .result(result)
    );

    task automatic check_alu(
        input string nombre_op,
        input logic [N-1:0] val_a,
        input logic [N-1:0] val_b,
        input logic [3:0]   val_F,
        input logic [N-1:0] exp_res
    );
        a = val_a;
        b = val_b;
        F = val_F;
        #10;
        $display("[t=%0t ns] %-22s | F=%04b | A=0x%0X (%02d) B=0x%0X (%02d) | Result=0x%0X (%02d)",
                 $time, nombre_op, F, a, a, b, b, result, result);

        if (result !== exp_res) begin
            $display("   --> ERROR: Obtenido 0x%0X, Esperado 0x%0X", result, exp_res);
            errores++;
        end
    endtask

    initial begin
        a = 0;
        b = 0;
        F = 0;

        $dumpfile("alu.vcd");
        $dumpvars(0, alu_tb);

        $display("==========================================================================");
        $display("   TESTBENCH EJERCICIO 5: VERIFICACION DE ALU (ARITMETICA Y LOGICA)       ");
        $display("==========================================================================");

        // Operaciones Aritméticas (F[3] = 0)
        check_alu("Transferencia A",      4'd6, 4'd2, 4'b0000, 4'd6);       // A
        check_alu("Incremento A+1",       4'd6, 4'd2, 4'b0001, 4'd7);       // A + 1
        check_alu("Suma A+B",             4'd6, 4'd2, 4'b0010, 4'd8);       // A + B
        check_alu("Suma A+B+1",           4'd6, 4'd2, 4'b0011, 4'd9);       // A + B + 1
        check_alu("Sustraccion A-B",      4'd6, 4'd2, 4'b0101, 4'd4);       // A - B
        check_alu("Decremento A-1",       4'd6, 4'd2, 4'b0110, 4'd5);       // A - 1
        check_alu("Transferencia Alt",    4'd6, 4'd2, 4'b0111, 4'd6);       // A

        // Operaciones Lógicas (F[3] = 1) con A = 4'b1100 (0xC), B = 4'b1010 (0xA)
        check_alu("AND bit a bit",        4'b1100, 4'b1010, 4'b1000, 4'b1000); // 1100 & 1010 = 1000 (0x8)
        check_alu("OR bit a bit",         4'b1100, 4'b1010, 4'b1010, 4'b1110); // 1100 | 1010 = 1110 (0xE)
        check_alu("XOR bit a bit",        4'b1100, 4'b1010, 4'b1100, 4'b0110); // 1100 ^ 1010 = 0110 (0x6)
        check_alu("Complemento ~A",       4'b1100, 4'b1010, 4'b1110, 4'b0011); // ~1100 = 0011 (0x3)

        #10;
        $display("==========================================================================");
        if (errores == 0) begin
            $display(">>> TEST EJERCICIO 5 PASSED: Todas las operaciones verificadas exitosamente! <<<");
        end else begin
            $display(">>> TEST EJERCICIO 5 FAILED: %0d errores detectados <<<", errores);
        end
        $display("==========================================================================");

        $finish;
    end

endmodule
