# Makefile para Punto 4 - Unidad Procesadora (Arquitectura Harvard)

SIM = up_sim
VCD = up.vcd
TOP_MODULE = unidad_procesadora
JSON = up.json
SVG = up_rtl.svg

SRCS = register_file.sv alu.sv shifter.sv function_unit.sv unidad_procesadora.sv
TB = up_tb.sv

all: sim svg

sim: $(SIM).vvp
	@echo "==> Ejecutando simulación de la Unidad Procesadora..."
	vvp $(SIM).vvp

$(SIM).vvp: $(SRCS) $(TB)
	iverilog -g2012 -Wall -o $(SIM).vvp $(SRCS) $(TB)

wave: $(VCD)
	gtkwave $(VCD) &

svg: $(JSON)
	netlistsvg $(JSON) -o $(SVG)
	@echo "Esquematico RTL exportado a $(SVG)"

$(JSON): $(SRCS)
	@echo "==> Exportando esquematico RTL a SVG con Yosys..."
	yosys -p "read_verilog -sv $(SRCS); hierarchy -top $(TOP_MODULE); proc; opt; write_json $(JSON)"

clean:
	rm -f $(SIM).vvp $(VCD) $(JSON) $(SVG)

.PHONY: all sim wave svg clean
