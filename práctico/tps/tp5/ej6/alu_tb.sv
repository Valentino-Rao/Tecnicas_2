// ============================================================================
// Banco de pruebas (Testbench) para Ejercicio 6: ALU con Banderas de Estado
//
// Verifica rigurosamente las 5 condiciones exigidas en la consigna:
// 1. Resultado Cero (Z = 1)
// 2. Resultado Negativo (S = 1)
// 3. Acarreo sin Desborde (C = 1, V = 0)
// 4. Desborde sin Acarreo (C = 0, V = 1)
// 5. Operación Lógica forzando C = 0 y V = 0
// ============================================================================

`timescale 1ns / 1ps

module alu_tb;

    localparam int N = 4;

    logic [N-1:0] a;
    logic [N-1:0] b;
    logic [3:0]   F;
    logic [N-1:0] result;
    logic [3:0]   flags; // {V, S, Z, C}

    int errores = 0;

    // Instancia del DUT
    alu #(.N(N)) dut (
        .a(a),
        .b(b),
        .F(F),
        .result(result),
        .flags(flags)
    );

    // Tarea de verificación con desglose de banderas
    task automatic check_flags(
        input string caso,
        input logic [N-1:0] val_a,
        input logic [N-1:0] val_b,
        input logic [3:0]   val_F,
        input logic [N-1:0] exp_res,
        input logic [3:0]   exp_flags // {V, S, Z, C}
    );
        a = val_a;
        b = val_b;
        F = val_F;
        #10;

        $display("[t=%0t ns] %-32s | F=%04b | A=0x%0X B=0x%0X | Res=0x%0X (Exp=0x%0X) | Flags: V=%b S=%b Z=%b C=%b (Exp: V=%b S=%b Z=%b C=%b)",
                 $time, caso, F, a, b, result, exp_res,
                 flags[3], flags[2], flags[1], flags[0],
                 exp_flags[3], exp_flags[2], exp_flags[1], exp_flags[0]);

        if (result !== exp_res) begin
            $display("   --> ERROR en Resultado: Obtenido 0x%0X, Esperado 0x%0X", result, exp_res);
            errores++;
        end

        if (flags !== exp_flags) begin
            $display("   --> ERROR en Flags: Obtenido %04b, Esperado %04b", flags, exp_flags);
            errores++;
        end
    endtask

    initial begin
        a = 0;
        b = 0;
        F = 0;

        $dumpfile("alu_flags.vcd");
        $dumpvars(0, alu_tb);

        $display("=========================================================================================");
        $display("     TESTBENCH EJERCICIO 6: ALU CON BANDERAS DE ESTADO flags[3:0] = {V, S, Z, C}         ");
        $display("=========================================================================================");

        // --------------------------------------------------------------------
        // Condición 1: Resultado Cero (Z = 1)
        // Resta A - B con A = 5, B = 5 (F = 0101).
        // 5 - 5 = 0. En Ca2: 5 + ~5 + 1 = 5 + 10 + 1 = 16 = 0x0 con Carry = 1, Overflow = 0.
        // flags: V=0, S=0, Z=1, C=1 -> 4'b0011
        // --------------------------------------------------------------------
        check_flags("1. Resultado Cero (A - B = 0)", 
                    4'd5, 4'd5, 4'b0101, 4'd0, 4'b0011);

        // --------------------------------------------------------------------
        // Condición 2: Resultado Negativo (S = 1)
        // Resta A - B con A = 3, B = 7 (F = 0101).
        // 3 - 7 = -4 (en 4b Ca2 es 4'b1100 = 0xC).
        // Suma: 3 + ~7 + 1 = 3 + 8 + 1 = 12 = 0xC (Sin carry: C=0, sin overflow: V=0).
        // flags: V=0, S=1, Z=0, C=0 -> 4'b0100
        // --------------------------------------------------------------------
        check_flags("2. Resultado Negativo (3 - 7)", 
                    4'd3, 4'd7, 4'b0101, 4'hC, 4'b0100);

        // --------------------------------------------------------------------
        // Condición 3: Acarreo sin Desborde (C = 1, V = 0)
        // Suma A + B con A = 7 (0111, pos), B = 10 (1010, neg: -6 en Ca2). (F = 0010).
        // Aritmética sin signo: 7 + 10 = 17 -> Sum = 1 con Cout = 1.
        // Aritmética con signo: (+7) + (-6) = +1 -> cabe en 4 bits, por lo tanto V = 0.
        // flags: V=0, S=0, Z=0, C=1 -> 4'b0001
        // --------------------------------------------------------------------
        check_flags("3. Acarreo sin Desborde (7 + 10)", 
                    4'd7, 4'd10, 4'b0010, 4'd1, 4'b0001);

        // --------------------------------------------------------------------
        // Condición 4: Desborde sin Acarreo (C = 0, V = 1)
        // Suma A + B con A = 5 (0101, +5), B = 4 (0100, +4). (F = 0010).
        // Aritmética sin signo: 5 + 4 = 9 < 16 -> Cout = 0 (C = 0).
        // Aritmética con signo: (+5) + (+4) = +9 > +7 (rango -8 a +7). Desborde positivo -> V = 1.
        // Result = 9 (4'b1001, bit 3 es 1, por lo que S = 1).
        // flags: V=1, S=1, Z=0, C=0 -> 4'b1100
        // --------------------------------------------------------------------
        check_flags("4. Desborde sin Acarreo (5 + 4)", 
                    4'd5, 4'd4, 4'b0010, 4'd9, 4'b1100);

        // --------------------------------------------------------------------
        // Condición 5: Operación Lógica con C = 0 y V = 0
        // Operación lógica AND: A = 4'b1111, B = 4'b1111 (F = 1000).
        // Resultado = 4'b1111.
        // Bit 3 es 1 -> S = 1. No es cero -> Z = 0.
        // Como es lógica (F[3]=1), C y V deben ser obligatoriamente 0.
        // flags: V=0, S=1, Z=0, C=0 -> 4'b0100
        // --------------------------------------------------------------------
        check_flags("5. Operacion Logica AND (~0 & ~0)", 
                    4'b1111, 4'b1111, 4'b1000, 4'b1111, 4'b0100);

        // Test adicional: Operación Lógica XOR que da 0
        // A = 4'b1010, B = 4'b1010, XOR (F = 1100).
        // Result = 4'b0000 -> Z = 1, S = 0, V = 0, C = 0 -> flags = 4'b0010
        check_flags("5b. Operacion Logica XOR (Cero)", 
                    4'b1010, 4'b1010, 4'b1100, 4'b0000, 4'b0010);

        #10;
        $display("=========================================================================================");
        if (errores == 0) begin
            $display(">>> TEST EJERCICIO 6 PASSED: Banderas {V, S, Z, C} verificadas al 100%%! <<<");
        end else begin
            $display(">>> TEST EJERCICIO 6 FAILED: %0d errores detectados <<<", errores);
        end
        $display("=========================================================================================");

        $finish;
    end

endmodule
