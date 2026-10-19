# Makefile para Ejercicio 7 - Shifter Combinacional

SIM = shifter_sim
VCD = shifter.vcd
TOP_MODULE = shifter
JSON = shifter.json
SVG = shifter_rtl.svg

all: sim svg

sim: $(SIM).vvp
	@echo "==> Ejecutando simulador..."
	vvp $(SIM).vvp

$(SIM).vvp: shifter.sv shifter_tb.sv
	iverilog -g2012 -Wall -o $(SIM).vvp shifter.sv shifter_tb.sv

wave: $(VCD)
	gtkwave $(VCD) &

svg: $(JSON)
	netlistsvg $(JSON) -o $(SVG)
	@echo "Esquematico RTL exportado a $(SVG)"

$(JSON): shifter.sv
	@echo "==> Exportando esquematico RTL a SVG..."
	yosys -p "read_verilog -sv shifter.sv; proc; opt; write_json $(JSON)"

clean:
	rm -f $(SIM).vvp $(VCD) $(JSON) $(SVG)

.PHONY: all sim wave svg clean
