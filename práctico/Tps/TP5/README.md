# TP5: Introducción a Verilog / SystemVerilog
**Simulación (Icarus Verilog + GTKWave) y Síntesis / Esquemáticos (Yosys + Netlistsvg)**
*Técnicas Digitales II - UTN FRC*

Este proyecto contiene un ejemplo funcional completo de diseño y simulación en **SystemVerilog (IEEE 1800-2012)** para verificar el correcto funcionamiento de toda la suite de herramientas de hardware de código abierto.

---

## 📂 Archivos del Proyecto

* `src/alu.sv`: Módulo combinacional parametrizado de una **ALU (Unidad Aritmético Lógica)** con operaciones `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLT` y banderas de estado (`zero`, `negative`).
* `src/alu_tb.sv`: Banco de pruebas (*Testbench*) con vectores de estímulo, validación por consola y volcado de ondas a `alu.vcd`.
* `Makefile`: Automatización completa de simulación, apertura de ondas, síntesis RTL y generación de diagramas a nivel de compuertas.

---

## 🚀 Guía de Comandos del `Makefile`

| Comando | Acción | Herramienta |
| :--- | :--- | :--- |
| **`make`** o **`make sim`** | Compila y corre los tests en la terminal | `iverilog` + `vvp` |
| **`make wave`** | Abre el visor de formas de onda temporales | `gtkwave` |
| **`make synth`** | Muestra el esquemático RTL interactivo por bloques | `yosys` + `xdot` |
| **`make gates`** | Sintetiza y muestra el circuito bajado a **compuertas lógicas** | `yosys` + `abc` |
| **`make svg`** | Exporta el esquemático en formato vectorial limpio (`alu.svg`) | `yosys` + `netlistsvg` |
| **`make clean`** | Elimina binarios, archivos `.vcd`, `.json` y `.svg` generados | `rm` |
