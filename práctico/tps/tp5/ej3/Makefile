# Makefile para Ejercicio 3 - TP5 Técnicas Digitales II
# Simulación con Icarus Verilog y Síntesis/Esquemáticos con Yosys

CC = iverilog
FLAGS = -g2012 -Wall
SIM = vvp
VIEWER = gtkwave
SYNTH = yosys
NETLISTSVG = netlistsvg

SRC = ram3port.sv ram3port_tb.sv
RTL_SRC = ram3port.sv
TARGET = ram3port_sim.vvp
VCD = ram3port.vcd
JSON = ram3port.json
SVG = ram3port_rtl.svg
GATES_JSON = ram3port_gates.json
GATES_SVG = ram3port_gates.svg

.PHONY: all sim wave synth gates svg svg-gates clean

all: sim

$(TARGET): $(SRC)
	@echo "==> Compilando Ejercicio 3 con Icarus Verilog..."
	$(CC) $(FLAGS) -o $(TARGET) $(SRC)

sim: $(TARGET)
	@echo "==> Ejecutando simulador..."
	$(SIM) $(TARGET)

wave: $(VCD)
	@echo "==> Abriendo GTKWave..."
	$(VIEWER) $(VCD) &

synth:
	@echo "==> Generando esquematico RTL con Yosys..."
	$(SYNTH) -p "read_verilog -sv $(RTL_SRC); proc; opt; show -format svg -prefix ram3port_rtl_yosys"

gates:
	@echo "==> Sintetizando a compuertas con Yosys..."
	$(SYNTH) -p "read_verilog -sv $(RTL_SRC); proc; opt; memory; techmap; abc -g gates; show -format svg -prefix ram3port_gates_yosys"

svg:
	@echo "==> Exportando esquematico RTL a SVG..."
	$(SYNTH) -p "read_verilog -sv $(RTL_SRC); proc; opt; write_json $(JSON)"
	$(NETLISTSVG) $(JSON) -o $(SVG)
	@echo "Esquematico RTL exportado a $(SVG)"

svg-gates:
	@echo "==> Exportando esquematico de compuertas a SVG..."
	$(SYNTH) -p "read_verilog -sv $(RTL_SRC); proc; opt; memory; techmap; abc -g gates; write_json $(GATES_JSON)"
	$(NETLISTSVG) $(GATES_JSON) -o $(GATES_SVG)
	@echo "Esquematico de compuertas exportado a $(GATES_SVG)"

clean:
	@echo "==> Limpiando..."
	rm -f $(TARGET) $(VCD) $(JSON) $(SVG) $(GATES_JSON) $(GATES_SVG) *.dot *.dot.svg ram3port_rtl_yosys.svg ram3port_gates_yosys.svg
