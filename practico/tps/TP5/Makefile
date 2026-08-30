# Makefile para simulacion, sintesis y esquematicos de Verilog
# Tecnicas Digitales II - UTN FRC

CC = iverilog
FLAGS = -g2012 -Wall
SIM = vvp
VIEWER = gtkwave
SYNTH = yosys
NETLISTSVG = netlistsvg

SRC = src/alu.sv src/alu_tb.sv
RTL_SRC = src/alu.sv
TARGET = alu_sim.vvp
VCD = alu.vcd
JSON = alu.json
SVG = alu.svg
GATES_JSON = alu_gates.json
GATES_SVG = alu_gates.svg

.PHONY: all sim wave synth gates svg svg-gates clean

# Por defecto: compilar y simular en consola
all: sim

# Compilacion con Icarus Verilog
$(TARGET): $(SRC)
	@echo "==> Compilando con Icarus Verilog..."
	$(CC) $(FLAGS) -o $(TARGET) $(SRC)

# Ejecucion de la simulacion
sim: $(TARGET)
	@echo "==> Ejecutando simulador..."
	$(SIM) $(TARGET)

# Visualizacion de formas de onda en GTKWave
wave: $(VCD)
	@echo "==> Abriendo GTKWave..."
	$(VIEWER) $(VCD) &

# Visualizacion del esquematico RTL por bloques en Yosys
synth:
	@echo "==> Generando y mostrando esquematico RTL con Yosys..."
	$(SYNTH) -p "read_verilog -sv $(RTL_SRC); proc; opt; show"

# Sintesis y visualizacion a nivel de compuertas logicas (AND, OR, NAND, XOR, NOT)
gates:
	@echo "==> Sintetizando a nivel de compuertas logicas..."
	$(SYNTH) -p "read_verilog -sv $(RTL_SRC); proc; opt; techmap; abc -g gates; show"

# Exportacion de esquematico RTL en SVG
svg:
	@echo "==> Generando esquematico RTL en SVG..."
	$(SYNTH) -p "read_verilog -sv $(RTL_SRC); proc; opt; write_json $(JSON)"
	$(NETLISTSVG) $(JSON) -o $(SVG)
	@echo "Esquematico RTL exportado a: $(SVG)"

# Exportacion del circuito en compuertas a SVG
svg-gates:
	@echo "==> Generando esquematico en compuertas a SVG..."
	$(SYNTH) -p "read_verilog -sv $(RTL_SRC); proc; opt; techmap; abc -g gates; write_json $(GATES_JSON)"
	$(NETLISTSVG) $(GATES_JSON) -o $(GATES_SVG)
	@echo "Esquematico de compuertas exportado a: $(GATES_SVG)"

# Limpieza de archivos temporales y binarios
clean:
	@echo "==> Limpiando archivos generados..."
	rm -f $(TARGET) $(VCD) $(JSON) $(SVG) $(GATES_JSON) $(GATES_SVG)
