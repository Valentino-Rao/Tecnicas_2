# ==============================================================================
# Script de simulación automatizada para ModelSim / QuestaSim
# Trabajo Práctico Nro 5 - Punto 4: Unidad Procesadora
# Técnicas Digitales II - UTN FRC
# ==============================================================================

# 1. Crear y mapear librería de trabajo
vlib work
vmap work work

# 2. Compilar los módulos SystemVerilog en orden jerárquico
vlog -sv -work work register_file.sv
vlog -sv -work work alu.sv
vlog -sv -work work shifter.sv
vlog -sv -work work function_unit.sv
vlog -sv -work work unidad_procesadora.sv
vlog -sv -work work up_tb.sv

# 3. Cargar la simulación en vsim con resolución de tiempo y acceso a señales
vsim -t 1ps -voptargs="+acc" work.up_tb

# 4. Configurar ventana de ondas (Wave Window)
add wave -divider "RELOJ Y RESET"
add wave -color Yellow /up_tb/clk
add wave -color Magenta /up_tb/reset_n

add wave -divider "PALABRA DE CONTROL"
add wave -color Cyan -radix binary /up_tb/ctrl_word
add wave -radix unsigned /up_tb/d_addr
add wave -radix unsigned /up_tb/a_addr
add wave -radix unsigned /up_tb/b_addr
add wave -radix binary /up_tb/mb_select
add wave -radix binary /up_tb/fs
add wave -radix binary /up_tb/md_select
add wave -radix binary /up_tb/load_en

add wave -divider "ENTRADAS Y SALIDAS EXTERNAS"
add wave -radix hexadecimal /up_tb/data_in
add wave -radix hexadecimal /up_tb/constant_in
add wave -radix hexadecimal /up_tb/address_out
add wave -radix hexadecimal /up_tb/data_out

add wave -divider "BANCO DE REGISTROS (R0 - R3)"
add wave -color Orange -radix decimal /up_tb/r0
add wave -color Orange -radix decimal /up_tb/r1
add wave -color Orange -radix decimal /up_tb/r2
add wave -color Orange -radix decimal /up_tb/r3

add wave -divider "BUSES INTERNOS"
add wave -radix hexadecimal /up_tb/dut/bus_a
add wave -radix hexadecimal /up_tb/dut/bus_b
add wave -radix hexadecimal /up_tb/dut/func_f
add wave -radix hexadecimal /up_tb/dut/d_data

add wave -divider "BANDERAS DE ESTADO (FLAGS)"
add wave -color Red      -name "V (Desborde / Overflow)"   /up_tb/v
add wave -color Blue     -name "C (Acarreo / Carry)"       /up_tb/c
add wave -color Magenta  -name "N (Negativo / Sign)"       /up_tb/n
add wave -color Green    -name "Z (Cero / Zero Detect)"    /up_tb/z
add wave -color Orange   -radix binary -name "Vector {V,C,N,Z}" /up_tb/flags

# 5. Ejecutar la simulación
run -all

# 6. Zoom completo a la forma de onda
wave zoom full
