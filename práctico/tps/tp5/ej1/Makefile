# Makefile para Ejercicio 1 - TP5 Técnicas Digitales II
# Simulación con Icarus Verilog y Síntesis/Esquemáticos con Yosys

CC = iverilog
FLAGS = -g2012 -Wall
SIM = vvp
VIEWER = gtkwave
SYNTH = yosys
NETLISTSVG = netlistsvg

SRC = ej1.sv ej1_tb.sv
RTL_SRC = ej1.sv
TARGET = ej1_sim.vvp
VCD = ej1.vcd
JSON = ej1.json
SVG = ej1_rtl.svg
GATES_JSON = ej1_gates.json
GATES_SVG = ej1_gates.svg

.PHONY: all sim wave synth gates svg svg-gates clean

all: sim

# Compilacion con Icarus Verilog
$(TARGET): $(SRC)
	@echo "==> Compilando Ejercicio 1 con Icarus Verilog..."
	$(CC) $(FLAGS) -o $(TARGET) $(SRC)

# Ejecucion de la simulacion
sim: $(TARGET)
	@echo "==> Ejecutando simulador..."
	$(SIM) $(TARGET)

# Visualizacion de ondas
wave: $(VCD)
	@echo "==> Abriendo GTKWave..."
	$(VIEWER) $(VCD) &

# Sintesis y visualizacion RTL en bloques
synth:
	@echo "==> Generando esquematico RTL con Yosys..."
	$(SYNTH) -p "read_verilog -sv $(RTL_SRC); proc; opt; show -format svg -prefix ej1_rtl_yosys"

# Sintesis a nivel compuertas
gates:
	@echo "==> Sintetizando a compuertas con Yosys..."
	$(SYNTH) -p "read_verilog -sv $(RTL_SRC); proc; opt; techmap; abc -g gates; show -format svg -prefix ej1_gates_yosys"

# Exportacion de esquematico RTL a SVG con netlistsvg
svg:
	@echo "==> Exportando esquematico RTL a SVG..."
	$(SYNTH) -p "read_verilog -sv $(RTL_SRC); proc; opt; write_json $(JSON)"
	$(NETLISTSVG) $(JSON) -o $(SVG)
	@echo "Esquematico RTL exportado a $(SVG)"

# Exportacion a compuertas con netlistsvg
svg-gates:
	@echo "==> Exportando esquematico de compuertas a SVG..."
	$(SYNTH) -p "read_verilog -sv $(RTL_SRC); proc; opt; techmap; abc -g gates; write_json $(GATES_JSON)"
	$(NETLISTSVG) $(GATES_JSON) -o $(GATES_SVG)
	@echo "Esquematico de compuertas exportado a $(GATES_SVG)"

clean:
	@echo "==> Limpiando..."
	rm -f $(TARGET) $(VCD) $(JSON) $(SVG) $(GATES_JSON) $(GATES_SVG) *.dot *.dot.svg ej1_rtl_yosys.svg ej1_gates_yosys.svg
