# Makefile para Ejercicio 6 - ALU con Banderas de Estado

SIM = alu_flags_sim
VCD = alu_flags.vcd
TOP_MODULE = alu
JSON = alu_flags.json
SVG = alu_flags_rtl.svg

all: sim svg

sim: $(SIM).vvp
	@echo "==> Ejecutando simulador..."
	vvp $(SIM).vvp

$(SIM).vvp: alu.sv alu_tb.sv
	iverilog -g2012 -Wall -o $(SIM).vvp alu.sv alu_tb.sv

wave: $(VCD)
	gtkwave $(VCD) &

svg: $(JSON)
	netlistsvg $(JSON) -o $(SVG)
	@echo "Esquematico RTL exportado a $(SVG)"

$(JSON): alu.sv
	@echo "==> Exportando esquematico RTL a SVG..."
	yosys -p "read_verilog -sv alu.sv; proc; opt; write_json $(JSON)"

clean:
	rm -f $(SIM).vvp $(VCD) $(JSON) $(SVG)

.PHONY: all sim wave svg clean
