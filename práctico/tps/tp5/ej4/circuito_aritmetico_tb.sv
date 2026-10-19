// ============================================================================
// Banco de pruebas (Testbench) para Ejercicio 4: Circuito Aritmético de 4 bits
// Verificaciones requeridas por consigna:
//   - Transferencia (A)
//   - Incremento (A + 1)
//   - Suma (A + B)
//   - Resta (A - B)
//   - Decremento (A - 1)
//   - Al menos un caso con acarreo (Cout = 1)
//   - Al menos un caso con desborde con signo (Overflow V = 1)
// ============================================================================

`timescale 1ns / 1ps

module circuito_aritmetico_tb;

    localparam int N = 4;

    logic [N-1:0] a;
    logic [N-1:0] b;
    logic [1:0]   s;
    logic         cin;
    logic [N-1:0] y;
    logic [N-1:0] sum;
    logic         cout;
    logic         overflow;

    int errores = 0;

    // Instancia del DUT
    circuito_aritmetico #(.N(N)) dut (
        .a(a),
        .b(b),
        .s(s),
        .cin(cin),
        .y(y),
        .sum(sum),
        .cout(cout),
        .overflow(overflow)
    );

    // Tarea auxiliar de verificación
    task automatic check_operacion(
        input string nombre_op,
        input logic [N-1:0] val_a,
        input logic [N-1:0] val_b,
        input logic [1:0]   val_s,
        input logic         val_cin,
        input logic [N-1:0] exp_sum,
        input logic         exp_cout,
        input logic         exp_v
    );
        a = val_a;
        b = val_b;
        s = val_s;
        cin = val_cin;
        #10;
        $display("[t=%0t ns] %-25s | A=%0d (0x%0X) B=%0d (0x%0X) S=%02b Cin=%0b | Sum=%0d (0x%0X) Cout=%0b V=%0b | Y=0x%0X",
                 $time, nombre_op, a, a, b, b, s, cin, sum, sum, cout, overflow, y);

        if (sum !== exp_sum) begin
            $display("   --> ERROR en Sum: obtenido 0x%0X, esperado 0x%0X", sum, exp_sum);
            errores++;
        end
        if (cout !== exp_cout) begin
            $display("   --> ERROR en Cout: obtenido %0b, esperado %0b", cout, exp_cout);
            errores++;
        end
        if (overflow !== exp_v) begin
            $display("   --> ERROR en Overflow (V): obtenido %0b, esperado %0b", overflow, exp_v);
            errores++;
        end
    endtask

    initial begin
        a = 0;
        b = 0;
        s = 0;
        cin = 0;

        $dumpfile("circuito_aritmetico.vcd");
        $dumpvars(0, circuito_aritmetico_tb);

        $display("==========================================================================================");
        $display("   TESTBENCH EJERCICIO 4: CIRCUITO ARITMETICO DE 4 BITS                                 ");
        $display("==========================================================================================");

        // 1. TRANSFERENCIA DE A (S=00, Cin=0)
        check_operacion("Transferencia A (00,0)", 4'd9, 4'd3, 2'b00, 1'b0, 4'd9, 1'b0, 1'b0);

        // 2. INCREMENTO DE A (S=00, Cin=1): A + 1
        check_operacion("Incremento A (00,1)", 4'd5, 4'd0, 2'b00, 1'b1, 4'd6, 1'b0, 1'b0);

        // 3. INCREMENTO CON DESBORDE CON SIGNO: (+7) + 1 = +8 -> desborda a -8 (V=1)
        check_operacion("Incremento A (V=1)", 4'sb0111, 4'd0, 2'b00, 1'b1, 4'sb1000, 1'b0, 1'b1);

        // 4. INCREMENTO CON ACARREO: 15 + 1 = 16 (Sum=0, Cout=1)
        check_operacion("Incremento A (Cout=1)", 4'hF, 4'd0, 2'b00, 1'b1, 4'h0, 1'b1, 1'b0);

        // 5. SUMA (S=01, Cin=0): A + B
        check_operacion("Suma A+B normal", 4'd4, 4'd3, 2'b01, 1'b0, 4'd7, 1'b0, 1'b0);

        // 6. SUMA CON ACARREO DE SALIDA: 12 + 6 = 18 -> 4 bits = 2, Cout = 1
        check_operacion("Suma A+B (Cout=1)", 4'd12, 4'd6, 2'b01, 1'b0, 4'd2, 1'b1, 1'b0);

        // 7. SUMA CON DESBORDE CON SIGNO: (+5) + (+4) = +9 -> desborda a -7 (1001b, V=1)
        check_operacion("Suma A+B (V=1)", 4'sb0101, 4'sb0100, 2'b01, 1'b0, 4'sb1001, 1'b0, 1'b1);

        // 8. SUMA CON ACARREO DE ENTRADA (S=01, Cin=1): A + B + 1
        //    2 + 3 + 1 = 6 (sin desborde con signo, V=0)
        check_operacion("Suma A+B+1", 4'd2, 4'd3, 2'b01, 1'b1, 4'd6, 1'b0, 1'b0);

        // 9. SUSTRACCIÓN EN Ca2 (S=10, Cin=1): A + ~B + 1 = A - B
        //    Caso: 7 - 3 = 4 (Cout=1 indica sin préstamo en resta por Ca2)
        check_operacion("Resta A-B (7-3=4)", 4'd7, 4'd3, 2'b10, 1'b1, 4'd4, 1'b1, 1'b0);

        // 10. SUSTRACCIÓN CON RESULTADO NEGATIVO: 3 - 5 = -2 (1110b = 14 unsigned, Cout=0)
        check_operacion("Resta A-B (3-5=-2)", 4'd3, 4'd5, 2'b10, 1'b1, 4'b1110, 1'b0, 1'b0);

        // 11. SUSTRACCIÓN CON DESBORDE CON SIGNO:
        //     (+5) - (-6) = +11 -> no cabe en 4 bits signed (-8..+7), desborda a -5 (1011b, V=1)
        check_operacion("Resta A-B (V=1)", 4'sb0101, 4'sb1010, 2'b10, 1'b1, 4'sb1011, 1'b0, 1'b1);

        // 12. A + ~B (S=10, Cin=0): Complemento a 1
        check_operacion("Resta a 1s A+~B", 4'd7, 4'd3, 2'b10, 1'b0, 4'd3, 1'b1, 1'b0);

        // 13. DECREMENTO (S=11, Cin=0): A + (-1) = A - 1
        check_operacion("Decremento A (7-1=6)", 4'd7, 4'd0, 2'b11, 1'b0, 4'd6, 1'b1, 1'b0);

        // 14. DECREMENTO CON DESBORDE: (-8) - 1 = -9 -> desborda a +7 (0111b, V=1)
        check_operacion("Decremento A (V=1)", 4'sb1000, 4'd0, 2'b11, 1'b0, 4'sb0111, 1'b1, 1'b1);

        // 15. TRANSFERENCIA ALTERNATIVA (S=11, Cin=1): A + (-1) + 1 = A
        check_operacion("Transferencia (11,1)", 4'd11, 4'd0, 2'b11, 1'b1, 4'd11, 1'b1, 1'b0);

        #10;
        $display("==========================================================================================");
        if (errores == 0) begin
            $display(">>> TEST EJERCICIO 4 PASSED: Todas las operaciones, acarreos y desbordes exitosos! <<<");
        end else begin
            $display(">>> TEST EJERCICIO 4 FAILED: %0d errores detectados <<<", errores);
        end
        $display("==========================================================================================");

        $finish;
    end

endmodule
