# Makefile para Ejercicio 5 - TP5 Técnicas Digitales II
# Simulación con Icarus Verilog y Síntesis/Esquemáticos con Yosys

CC = iverilog
FLAGS = -g2012 -Wall
SIM = vvp
VIEWER = gtkwave
SYNTH = yosys
NETLISTSVG = netlistsvg

SRC = alu.sv alu_tb.sv
RTL_SRC = alu.sv
TARGET = alu_sim.vvp
VCD = alu.vcd
JSON = alu.json
SVG = alu_rtl.svg
GATES_JSON = alu_gates.json
GATES_SVG = alu_gates.svg

.PHONY: all sim wave synth gates svg svg-gates clean

all: sim

$(TARGET): $(SRC)
	@echo "==> Compilando Ejercicio 5 con Icarus Verilog..."
	$(CC) $(FLAGS) -o $(TARGET) $(SRC)

sim: $(TARGET)
	@echo "==> Ejecutando simulador..."
	$(SIM) $(TARGET)

wave: $(VCD)
	@echo "==> Abriendo GTKWave..."
	$(VIEWER) $(VCD) &

synth:
	@echo "==> Generando esquematico RTL con Yosys..."
	$(SYNTH) -p "read_verilog -sv $(RTL_SRC); proc; opt; show -format svg -prefix alu_rtl_yosys"

gates:
	@echo "==> Sintetizando a compuertas con Yosys..."
	$(SYNTH) -p "read_verilog -sv $(RTL_SRC); proc; opt; techmap; abc -g gates; show -format svg -prefix alu_gates_yosys"

svg:
	@echo "==> Exportando esquematico RTL a SVG..."
	$(SYNTH) -p "read_verilog -sv $(RTL_SRC); proc; opt; write_json $(JSON)"
	$(NETLISTSVG) $(JSON) -o $(SVG)
	@echo "Esquematico RTL exportado a $(SVG)"

svg-gates:
	@echo "==> Exportando esquematico de compuertas a SVG..."
	$(SYNTH) -p "read_verilog -sv $(RTL_SRC); proc; opt; techmap; abc -g gates; write_json $(GATES_JSON)"
	$(NETLISTSVG) $(GATES_JSON) -o $(GATES_SVG)
	@echo "Esquematico de compuertas exportado a $(GATES_SVG)"

clean:
	@echo "==> Limpiando..."
	rm -f $(TARGET) $(VCD) $(JSON) $(SVG) $(GATES_JSON) $(GATES_SVG) *.dot *.dot.svg alu_rtl_yosys.svg alu_gates_yosys.svg
