`timescale 1ns/1ps

/**
 * ============================================================================
 * Testbench: alu_tb.sv (Banco de pruebas para la ALU)
 * ============================================================================
 */

module alu_tb;

    localparam WIDTH = 8;

    // Señales de estímulo y monitoreo
    logic [WIDTH-1:0] a;
    logic [WIDTH-1:0] b;
    logic [2:0]       alu_control;
    logic [WIDTH-1:0] result;
    logic             zero;
    logic             negative;

    // Instanciación del módulo bajo prueba (DUT)
    alu #(.WIDTH(WIDTH)) dut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero),
        .negative(negative)
    );

    // Procedimiento de prueba
    initial begin
        // Configurar volcado de ondas para GTKWave
        $dumpfile("alu.vcd");
        $dumpvars(0, alu_tb);

        $display("=================================================");
        $display("   Iniciando Simulacion de Prueba de ALU (8 bits)");
        $display("=================================================");

        // Test 1: Suma (ADD) -> 15 + 10 = 25
        a = 8'd15; b = 8'd10; alu_control = 3'b000;
        #10;
        $display("[ADD] a=%0d, b=%0d => result=%0d, Z=%b, N=%b (Esperado: 25, Z=0)", a, b, result, zero, negative);

        // Test 2: Resta con resultado cero (SUB) -> 42 - 42 = 0
        a = 8'd42; b = 8'd42; alu_control = 3'b001;
        #10;
        $display("[SUB] a=%0d, b=%0d => result=%0d, Z=%b, N=%b (Esperado: 0, Z=1)", a, b, result, zero, negative);

        // Test 3: Resta con resultado negativo -> 10 - 25 = -15 (241 en uint8)
        a = 8'd10; b = 8'd25; alu_control = 3'b001;
        #10;
        $display("[SUB] a=%0d, b=%0d => result=0x%0h (%0d signed), Z=%b, N=%b (Esperado: N=1)", a, b, result, $signed(result), zero, negative);

        // Test 4: Operacion AND bit a bit -> 0xF0 & 0xAA = 0xA0
        a = 8'hF0; b = 8'hAA; alu_control = 3'b010;
        #10;
        $display("[AND] a=0x%0h, b=0x%0h => result=0x%0h (Esperado: 0xA0)", a, b, result);

        // Test 5: Operacion OR bit a bit -> 0x55 | 0xAA = 0xFF
        a = 8'h55; b = 8'hAA; alu_control = 3'b011;
        #10;
        $display("[OR ] a=0x%0h, b=0x%0h => result=0x%0h (Esperado: 0xFF)", a, b, result);

        // Test 6: Operacion XOR -> 0xFF ^ 0x0F = 0xF0
        a = 8'hFF; b = 8'h0F; alu_control = 3'b100;
        #10;
        $display("[XOR] a=0x%0h, b=0x%0h => result=0x%0h (Esperado: 0xF0)", a, b, result);

        // Test 7: Set on Less Than (SLT) -> -5 < 10 (Verdadero => 1)
        a = -8'sd5; b = 8'sd10; alu_control = 3'b101;
        #10;
        $display("[SLT] a=%0d, b=%0d => result=%0d (Esperado: 1)", $signed(a), $signed(b), result);

        // Test 8: Set on Less Than (SLT) -> 20 < 10 (Falso => 0)
        a = 8'sd20; b = 8'sd10; alu_control = 3'b101;
        #10;
        $display("[SLT] a=%0d, b=%0d => result=%0d (Esperado: 0)", $signed(a), $signed(b), result);

        $display("=================================================");
        $display("   Simulacion completada exitosamente!");
        $display("   Archivo de ondas generado: alu.vcd");
        $display("=================================================");
        $finish;
    end

endmodule
