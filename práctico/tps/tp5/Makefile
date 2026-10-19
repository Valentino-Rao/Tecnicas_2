# Makefile Principal - TP5: CPU: RTL y Módulos
# Técnicas Digitales II - UTN FRC

EJERCICIOS = ej1 ej2 ej3 ej4 ej5 ej6 ej7 ej8

.PHONY: all clean sim svg-all $(EJERCICIOS)

all: sim

sim:
	@for dir in $(EJERCICIOS); do \
		echo "=========================================================="; \
		echo "==> Simulando $$dir..."; \
		echo "=========================================================="; \
		$(MAKE) -C $$dir sim; \
	done

svg-all:
	@for dir in $(EJERCICIOS); do \
		echo "=========================================================="; \
		echo "==> Generando esquemáticos SVG para $$dir..."; \
		echo "=========================================================="; \
		$(MAKE) -C $$dir svg; \
	done

clean:
	@for dir in $(EJERCICIOS); do \
		$(MAKE) -C $$dir clean; \
	done
