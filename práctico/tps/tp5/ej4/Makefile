# Makefile para Ejercicio 4 - TP5 Técnicas Digitales II
# Simulación con Icarus Verilog y Síntesis/Esquemáticos con Yosys

CC = iverilog
FLAGS = -g2012 -Wall
SIM = vvp
VIEWER = gtkwave
SYNTH = yosys
NETLISTSVG = netlistsvg

SRC = circuito_aritmetico.sv circuito_aritmetico_tb.sv
RTL_SRC = circuito_aritmetico.sv
TARGET = circuito_aritmetico_sim.vvp
VCD = circuito_aritmetico.vcd
JSON = circuito_aritmetico.json
SVG = circuito_aritmetico_rtl.svg
GATES_JSON = circuito_aritmetico_gates.json
GATES_SVG = circuito_aritmetico_gates.svg

.PHONY: all sim wave synth gates svg svg-gates clean

all: sim

$(TARGET): $(SRC)
	@echo "==> Compilando Ejercicio 4 con Icarus Verilog..."
	$(CC) $(FLAGS) -o $(TARGET) $(SRC)

sim: $(TARGET)
	@echo "==> Ejecutando simulador..."
	$(SIM) $(TARGET)

wave: $(VCD)
	@echo "==> Abriendo GTKWave..."
	$(VIEWER) $(VCD) &

synth:
	@echo "==> Generando esquematico RTL con Yosys..."
	$(SYNTH) -p "read_verilog -sv $(RTL_SRC); proc; opt; show -format svg -prefix circuito_aritmetico_rtl_yosys"

gates:
	@echo "==> Sintetizando a compuertas con Yosys..."
	$(SYNTH) -p "read_verilog -sv $(RTL_SRC); proc; opt; techmap; abc -g gates; show -format svg -prefix circuito_aritmetico_gates_yosys"

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
	rm -f $(TARGET) $(VCD) $(JSON) $(SVG) $(GATES_JSON) $(GATES_SVG) *.dot *.dot.svg circuito_aritmetico_rtl_yosys.svg circuito_aritmetico_gates_yosys.svg
