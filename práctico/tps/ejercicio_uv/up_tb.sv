// ============================================================================
// Trabajo Práctico Nro 5 - CPU: RTL y Módulos
// Punto 4: Banco de Pruebas (Testbench) para la Unidad Procesadora
//
// Verifica la ejecución de la UP mediante palabras de control y datos de entrada,
// demostrando las operaciones aritméticas solicitadas en la consigna de la UV:
// 1. Carga inicial de datos desde memoria externa (Data in) hacia R0 y R1.
// 2. Operación Aritmética 1: Suma R2 <= R0 + R1
// 3. Operación Aritmética 2: Resta R3 <= R2 - R1
// 4. Operación Aritmética con constante inmediata: R0 <= R0 + Constant_IN
// 5. Operación de Corrimiento: R1 <= SHL(R1)
// ============================================================================

`timescale 1ns / 1ps

module up_tb;

    localparam int N = 4;
    localparam int M = 2;

    // Señales de estímulo
    logic         clk;
    logic         reset_n;

    logic         load_en;
    logic [M-1:0] d_addr;
    logic [M-1:0] a_addr;
    logic [M-1:0] b_addr;
    logic         mb_select;
    logic [4:0]   fs;
    logic         md_select;

    logic [N-1:0] constant_in;
    logic [N-1:0] data_in;

    // Salidas del DUT
    logic [N-1:0] address_out;
    logic [N-1:0] data_out;
    logic         v;
    logic         c;
    logic         n;
    logic         z;
    logic [3:0]   flags; // {V, C, N, Z}

    logic [N-1:0] r0, r1, r2, r3;

    int errores = 0;

    // Instancia de la Unidad Procesadora
    unidad_procesadora #(
        .N(N),
        .M(M)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .load_en(load_en),
        .d_addr(d_addr),
        .a_addr(a_addr),
        .b_addr(b_addr),
        .mb_select(mb_select),
        .fs(fs),
        .md_select(md_select),
        .constant_in(constant_in),
        .data_in(data_in),
        .address_out(address_out),
        .data_out(data_out),
        .v(v),
        .c(c),
        .n(n),
        .z(z),
        .flags(flags),
        .r0_out(r0),
        .r1_out(r1),
        .r2_out(r2),
        .r3_out(r3)
    );

    // Generador de Reloj: período 20 ns (50 MHz)
    always #10 clk = ~clk;

    // Palabra de control de 14 bits empaquetada para visualización y registro
    // {Load_en, DA[1:0], AA[1:0], BA[1:0], MB, FS[4:0], MD}
    wire [13:0] ctrl_word = {load_en, d_addr, a_addr, b_addr, mb_select, fs, md_select};

    // Tarea para aplicar una instrucción en un ciclo de reloj
    task automatic execute_inst(
        input string       nombre_op,
        input logic        v_load,
        input logic [M-1:0] v_da,
        input logic [M-1:0] v_aa,
        input logic [M-1:0] v_ba,
        input logic        v_mb,
        input logic [4:0]  v_fs,
        input logic        v_md,
        input logic [N-1:0] v_cin,
        input logic [N-1:0] v_din,
        input logic [M-1:0] reg_check,
        input logic [N-1:0] exp_val
    );
        @(negedge clk);
        load_en     = v_load;
        d_addr      = v_da;
        a_addr      = v_aa;
        b_addr      = v_ba;
        mb_select   = v_mb;
        fs          = v_fs;
        md_select   = v_md;
        constant_in = v_cin;
        data_in     = v_din;

        @(posedge clk);
        #2; // Tiempo de propagación para evaluar salidas registradas

        $display("----------------------------------------------------------------------------------------");
        $display("[t=%0t ns] %-32s | Word=14'b%b (0x%04X)", $time, nombre_op, ctrl_word, ctrl_word);
        $display("          DA=%0d AA=%0d BA=%0d MB=%b FS=%05b MD=%b | C_in=0x%0X D_in=0x%0X",
                 d_addr, a_addr, b_addr, mb_select, fs, md_select, constant_in, data_in);
        $display("          REGISTROS: R0=0x%0X R1=0x%0X R2=0x%0X R3=0x%0X", r0, r1, r2, r3);
        $display("          BANDERAS:  V(Desborde)=%b, C(Acarreo)=%b, N(Signo)=%b, Z(Cero)=%b  [Flags=%b]",
                 v, c, n, z, flags);

        if (v_load) begin
            logic [N-1:0] actual_val;
            case (reg_check)
                2'd0: actual_val = r0;
                2'd1: actual_val = r1;
                2'd2: actual_val = r2;
                2'd3: actual_val = r3;
            endcase
            if (actual_val !== exp_val) begin
                $display("          >>> ERROR: R%0d = 0x%0X, Esperado = 0x%0X <<<", reg_check, actual_val, exp_val);
                errores++;
            end else begin
                $display("          >>> OK: R%0d actualizado correctamente con valor 0x%0X (%02d)", reg_check, actual_val, actual_val);
            end
        end
    endtask

    initial begin
        clk = 0;
        reset_n = 0;
        load_en = 0;
        d_addr = 0;
        a_addr = 0;
        b_addr = 0;
        mb_select = 0;
        fs = 0;
        md_select = 0;
        constant_in = 0;
        data_in = 0;

        $dumpfile("up.vcd");
        $dumpvars(0, up_tb);

        $display("========================================================================================");
        $display("    TESTBENCH UNIDAD PROCESADORA (PUNTO 4) - ARQUITECTURA HARVARD / MORRIS MANO         ");
        $display("========================================================================================");

        // Reset inicial
        #25;
        reset_n = 1;
        #15;

        // --------------------------------------------------------------------
        // 1. Carga de datos iniciales desde memoria externa (Data in)
        // --------------------------------------------------------------------
        $display("\n>>> ETAPA 1: CARGA DE DATOS EXTERNOS EN BANCO DE REGISTROS (MD=1, Load=1)");
        // R0 <= Data_in (5)
        execute_inst("Carga R0 <= Data_in (5)", 
                     1'b1, 2'd0, 2'd0, 2'd0, 1'b0, 5'b00000, 1'b1, 4'd0, 4'd5, 2'd0, 4'd5);

        // R1 <= Data_in (3)
        execute_inst("Carga R1 <= Data_in (3)", 
                     1'b1, 2'd1, 2'd0, 2'd0, 1'b0, 5'b00000, 1'b1, 4'd0, 4'd3, 2'd1, 4'd3);

        // --------------------------------------------------------------------
        // 2. Operación Aritmética 1: Suma R2 <= R0 + R1
        // AA=0 (R0), BA=1 (R1), MB=0 (B data), FS=00010 (Adición A+B), MD=0 (F), DA=2 (R2)
        // R2 = 5 + 3 = 8 (0x8)
        // --------------------------------------------------------------------
        $display("\n>>> ETAPA 2: OPERACION ARITMETICA 1 - ADICION (R2 <= R0 + R1)");
        execute_inst("Op Arit 1: R2 <= R0 + R1 (5+3)", 
                     1'b1, 2'd2, 2'd0, 2'd1, 1'b0, 5'b00010, 1'b0, 4'd0, 4'd0, 2'd2, 4'd8);

        // --------------------------------------------------------------------
        // 3. Operación Aritmética 2: Sustracción R3 <= R2 - R1
        // AA=2 (R2), BA=1 (R1), MB=0 (B data), FS=00101 (Sustracción A-B), MD=0 (F), DA=3 (R3)
        // R3 = 8 - 3 = 5 (0x5)
        // --------------------------------------------------------------------
        $display("\n>>> ETAPA 3: OPERACION ARITMETICA 2 - SUSTRACCION (R3 <= R2 - R1)");
        execute_inst("Op Arit 2: R3 <= R2 - R1 (8-3)", 
                     1'b1, 2'd3, 2'd2, 2'd1, 1'b0, 5'b00101, 1'b0, 4'd0, 4'd0, 2'd3, 4'd5);

        // --------------------------------------------------------------------
        // 4. Operación Aritmética con Constante Inmediata: R0 <= R0 + Constant_IN (2)
        // AA=0 (R0), MB=1 (Constant IN), Constant_IN = 2, FS=00010 (Adición), MD=0, DA=0 (R0)
        // R0 = 5 + 2 = 7 (0x7)
        // --------------------------------------------------------------------
        $display("\n>>> ETAPA 4: OPERACION ARITMETICA CON CONSTANTE INMEDIATA (R0 <= R0 + 2)");
        execute_inst("Op Arit 3: R0 <= R0 + 2 (5+2)", 
                     1'b1, 2'd0, 2'd0, 2'd0, 1'b1, 5'b00010, 1'b0, 4'd2, 4'd0, 2'd0, 4'd7);

        // --------------------------------------------------------------------
        // 5. Operación de Corrimiento: R1 <= SHL(R1)
        // BA=1 (R1), MB=0, FS=10001 (MF=1, H=01 -> SHL), MD=0, DA=1 (R1)
        // R1 = SHL(3) = SHL(0011) = 0110 (6)
        // --------------------------------------------------------------------
        $display("\n>>> ETAPA 5: OPERACION DE CORRIMIENTO (R1 <= SHL R1)");
        execute_inst("Op Shift: R1 <= SHL(R1) (3<<1)", 
                     1'b1, 2'd1, 2'd0, 2'd1, 1'b0, 5'b10001, 1'b0, 4'd0, 4'd0, 2'd1, 4'd6);

        #30;
        $display("========================================================================================");
        if (errores == 0) begin
            $display(">>> TEST PUNTO 4 PASSED: Unidad Procesadora verificada al 100%% con exito! <<<");
        end else begin
            $display(">>> TEST PUNTO 4 FAILED: %0d errores detectados <<<", errores);
        end
        $display("========================================================================================");

        $finish;
    end

endmodule
