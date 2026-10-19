# Makefile para Ejercicio 8 - Microoperaciones y Datapath

SIM = datapath_sim
VCD = datapath.vcd
TOP_MODULE = datapath
JSON = datapath.json
SVG = datapath_rtl.svg

all: sim svg

sim: $(SIM).vvp
	@echo "==> Ejecutando simulador..."
	vvp $(SIM).vvp

$(SIM).vvp: datapath.sv microcode_tb.sv
	iverilog -g2012 -Wall -o $(SIM).vvp datapath.sv microcode_tb.sv

wave: $(VCD)
	gtkwave $(VCD) &

svg: $(JSON)
	netlistsvg $(JSON) -o $(SVG)
	@echo "Esquematico RTL exportado a $(SVG)"

$(JSON): datapath.sv
	@echo "==> Exportando esquematico RTL a SVG..."
	yosys -p "read_verilog -sv datapath.sv; proc; opt; write_json $(JSON)"

clean:
	rm -f $(SIM).vvp $(VCD) $(JSON) $(SVG)

.PHONY: all sim wave svg clean
