# Makefile general para TP4 (FreeRTOS)

.PHONY: all act1 act2 clean flash-act1 flash-act2

all: act1 act2

act1:
	@echo "=== Compilando Ejercicio 1 (act1) ==="
	$(MAKE) -C act1

act2:
	@echo "=== Compilando Ejercicio 2 (act2) ==="
	$(MAKE) -C act2

flash-act1:
	@echo "=== Flasheando Ejercicio 1 (act1) ==="
	$(MAKE) -C act1 flash

flash-act2:
	@echo "=== Flasheando Ejercicio 2 (act2) ==="
	$(MAKE) -C act2 flash

clean:
	@echo "=== Limpiando Ejercicios 1 y 2 ==="
	$(MAKE) -C act1 clean
	$(MAKE) -C act2 clean
