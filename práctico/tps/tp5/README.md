# Trabajo Práctico Nro 5 — CPU: RTL y Módulos
**Técnicas Digitales II — UTN Facultad Regional Córdoba**  
*Prof. Estefanía Pereyra — Año 2026*  
*Alumno: Valentino Rao (402308)*

---

## 📌 Resumen General de la Unidad Procesadora (UP)

En este trabajo práctico se diseña, describe en **SystemVerilog (IEEE 1800-2012)**, simula con **Icarus Verilog** y sintetiza con **Yosys** la arquitectura modular completa de una **Unidad Procesadora (CPU Datapath)** de 4 bits con:
* **7 registros de propósito general de 4 bits ($R_1$ a $R_7$)** mediante un archivo de registros multiport (`ram3port`).
* **Dos buses de lectura combinacionales ($Bus_A$ y $Bus_B$)** con capacidad de lectura de registros internos o selección de entrada externa de datos (`DATA_in`).
* **Unidad Aritmético-Lógica (ALU)** unificada con campo de control de 4 bits $F[3:0]$.
* **4 Banderas de Estado agrupadas en `flags[3:0] = {V, S, Z, C}`** (Desborde, Signo, Cero, Acarreo) registradas síncronamente.
* **Unidad de Corrimiento y Rotación (Shifter)** combinacional gobernada por el campo $H[2:0]$.
* **Palabra de control unificada de 16 bits:**  
  $$\text{Control Word} = H[15:13] \;\|\; F[12:9] \;\|\; D[8:6] \;\|\; B[5:3] \;\|\; A[2:0]$$

```
                      +-------------------+
                      | Palabra de Control| (16 bits)
                      | HHH FFFF DDD BB AA|
                      +--+----+---+---+---+
                         |    |   |   |   |
         +---------------+    |   |   |   +--------+
         |                    |   |   +-------+    |
         |                    |   +--+        |    |
         |                    |      |        v    v
         v                    v      |     +------------+
  +-------------+       +-----------+|     | ram3port   |
  |   Shifter   |       |    ALU    ||     | R1 ... R7  |
  |  (H[15:13]) |       | (F[12:9]) ||     +-----+------+
  +------+------+       +-----+-----+|           |
         ^                    ^      |           | (RD1, RD2)
         |                    |      v           v
         | [ALU_out]          |   +-----------------------+
         +--------------------+---| Muxes de Entrada A y B| <--- DATA_in
                                  +-----------------------+
```

---

## 🚀 Ejercicio 1: Intercambio de Registros ($T_3: R_2 \leftarrow R_1,\; R_1 \leftarrow R_2$)

### 1.1 Descripción Teórica y Sincronización
La instrucción especifica una transferencia simultánea e intercambiada entre dos registros de 8 bits ($N=8$) durante el flanco ascendente de reloj, condicionada a que la señal de sincronización $T_3 = 1$.

```text
       t0         t1         t2
CLK  ---|___|---|___|---|___|---|___|---
T3   ___________|-----------|___________
R1      [0xA5]        [0x3C] (post t1)
R2      [0x3C]        [0xA5] (post t1)
```

### 1.2 Importancia de las Asignaciones No Bloqueantes (`<=`)
En hardware, los registros son bancos de Flip-Flops tipo D muestreados por el mismo reloj `clk`. Al utilizar asignaciones no bloqueantes (`<=`), el simulador evalúa las expresiones de la derecha ($R_1$ y $R_2$) en la región activa (*Active Region*) utilizando los valores presentes **antes** del flanco. Luego, en la región NBA (*Non-Blocking Assignment*), actualiza simultáneamente los registros:
* Si se hubiera usado asignación bloqueante (`=`): $R_1$ tomaría el valor de $R_2$, y en la siguiente línea $R_2$ tomaría el nuevo $R_1$, perdiendo el valor original de $R_1$ (carrera crítica).
* Con `<=`, el intercambio es determinístico, simultáneo e idéntico al comportamiento físico de dos registros con biestables maestros/esclavos.

### 1.3 Archivos del Ejercicio 1
* Código RTL: [`ej1/ej1.sv`](ej1/ej1.sv)
* Testbench: [`ej1/ej1_tb.sv`](ej1/ej1_tb.sv)
* Esquemático RTL Vectorial: [`ej1/ej1_rtl.svg`](ej1/ej1_rtl.svg)
* Esquemático en Compuertas: [`ej1/ej1_gates.svg`](ej1/ej1_gates.svg)

---

## 🚀 Ejercicio 2: Transferencias Multiplexadas a Registro Destino $R_5$

### 2.1 Tabla de Relación entre Sincronización ($T_0 \dots T_3$), Selección ($S[1:0]$) y Carga
Las transferencias solicitadas son:
* $T_0 : R_5 \leftarrow R_0$
* $T_1 : R_5 \leftarrow R_1$
* $T_2 : R_5 \leftarrow R_2$
* $T_3 : R_5 \leftarrow R_3$

Dado que $T_0 \dots T_3$ son mutuamente excluyentes (código *one-hot*), se construye la siguiente tabla de verdad:

| $T_3$ | $T_2$ | $T_1$ | $T_0$ | Carga ($load\_en$) | $S_1$ | $S_0$ | Registro Seleccionado | Operación |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| 0 | 0 | 0 | 0 | **0** | X | X | Ninguno | Retención de $R_5$ |
| 0 | 0 | 0 | 1 | **1** | **0** | **0** | $R_0$ | $T_0: R_5 \leftarrow R_0$ |
| 0 | 0 | 1 | 0 | **1** | **0** | **1** | $R_1$ | $T_1: R_5 \leftarrow R_1$ |
| 0 | 1 | 0 | 0 | **1** | **1** | **0** | $R_2$ | $T_2: R_5 \leftarrow R_2$ |
| 1 | 0 | 0 | 0 | **1** | **1** | **1** | $R_3$ | $T_3: R_5 \leftarrow R_3$ |

### 2.2 Ecuaciones Lógicas Mínimas
* **Habilitación de carga:**
  $$load\_en = T_0 \lor T_1 \lor T_2 \lor T_3 = |T$$
* **Señales de control del MUX 4 a 1:**
  $$S_1 = T_2 \lor T_3$$
  $$S_0 = T_1 \lor T_3$$

### 2.3 Separación de Lógica Combinacional y Carga Secuencial
El diseño implementa rigurosamente la separación metodológica de SystemVerilog:
1. **Bloque Combinacional (`always_comb`):** Codificador de prioridad/one-hot para $S[1:0]$ y $load\_en$, y multiplexor 4:1 que dirige el registro seleccionado al bus intermedio `bus_data`.
2. **Bloque Secuencial (`always_ff`):** Registro de 4 bits con entrada de datos conectada a `bus_data`, habilitado por $load\_en$ en flanco ascendente de `clk`.

### 2.4 Archivos del Ejercicio 2
* Código RTL: [`ej2/ej2.sv`](ej2/ej2.sv)
* Testbench: [`ej2/ej2_tb.sv`](ej2/ej2_tb.sv)
* Esquemático RTL Vectorial: [`ej2/ej2_rtl.svg`](ej2/ej2_rtl.svg)
* Esquemático en Compuertas: [`ej2/ej2_gates.svg`](ej2/ej2_gates.svg)

---

## 🚀 Ejercicio 3: Archivo de Registros de 3 Puertos (`ram3port`)

### 3.1 Determinación de Líneas de Selección
Para direccionar 7 registros generales ($R_1$ a $R_7$) más la dirección especial reservada `000` (cero constante), se requieren $M = 8$ direcciones distintas:
$$N_{\mathrm{lineas}} = \lceil \log_2(8) \rceil = 3\ \text{bits} \implies A[2:0]$$

Por lo tanto:
* **$A_1[2:0]$:** 3 bits para selección de lectura en Puerto 1 (`RD1`).
* **$A_2[2:0]$:** 3 bits para selección de lectura en Puerto 2 (`RD2`).
* **$A_3[2:0]$:** 3 bits para selección de registro destino de escritura (`WD3`).

### 3.2 Organización Interna
El módulo contiene:
1. **Banco de 7 registros de 4 bits** ($R_1 \dots R_7$) implementados con Flip-Flops sincronizados con `clk`.
2. **Decodificador de escritura 3 a 8 con habilitación:** Habilita el reloj/carga del registro $i$ si $WE3 = 1$ y $A_3 = i$ ($i \ne 0$). Si $A_3 = 000$, la escritura se desestima automáticamente.
3. **Dos Multiplexores de Lectura 8 a 1 independientes:**
   * Cuando $A = 000$, el multiplexor conmuta a una constante cableada $4'b0000$.
   * Cuando $A = i$ ($1 \le i \le 7$), entrega el contenido del registro $R_i$ de manera puramente combinacional (sin latencia de reloj).

### 3.3 Verificaciones del Testbench
El banco de pruebas [`ej3/ram3port_tb.sv`](ej3/ram3port_tb.sv) valida:
* Lectura en dirección `000` devolviendo estrictamente `0000`.
* Escritura en flanco de reloj con $WE3 = 1$.
* Lectura simultánea de dos registros diferentes en un mismo instante ($RD_1$ y $RD_2$).
* Retención estricta cuando $WE3 = 0$.
* Inmunidad de la dirección `000` frente a intentos de escritura.

### 3.4 Archivos del Ejercicio 3
* Código RTL: [`ej3/ram3port.sv`](ej3/ram3port.sv)
* Testbench: [`ej3/ram3port_tb.sv`](ej3/ram3port_tb.sv)
* Esquemático RTL Vectorial: [`ej3/ram3port_rtl.svg`](ej3/ram3port_rtl.svg)
* Esquemático en Compuertas: [`ej3/ram3port_gates.svg`](ej3/ram3port_gates.svg)

---

## 🚀 Ejercicio 4: Circuito Aritmético de 4 Bits

### 4.1 Tabla Completa de Microoperaciones y Selección del Campo $F[2:0]$
El campo de selección de 3 bits agrupa las variables de control como $F[2:0] = \{S_1, S_0, C_{in}\}$:

| $S_1$ | $S_0$ | $C_{in}$ | Operación Aritmética | Operando $Y$ | Función Matemática | Descripción |
| :---: | :---: | :---: | :--- | :---: | :--- | :--- |
| **0** | **0** | **0** | Transferencia | $0000$ | $A + 0 + 0 = A$ | Transfiere el operando A sin alterar |
| **0** | **0** | **1** | Incremento | $0000$ | $A + 0 + 1 = A + 1$ | Incrementa A en 1 |
| **0** | **1** | **0** | Suma | $B$ | $A + B + 0 = A + B$ | Suma binaria estándar |
| **0** | **1** | **1** | Suma con acarreo | $B$ | $A + B + 1$ | Suma binaria con acarreo de entrada |
| **1** | **0** | **0** | Resta a 1s | $\overline{B}$ | $A + \overline{B}$ | Suma de A con el complemento a 1 de B |
| **1** | **0** | **1** | Sustracción | $\overline{B}$ | $A + \overline{B} + 1 = A - B$ | Resta en complemento a 2 |
| **1** | **1** | **0** | Decremento | $1111\ (-1)$ | $A + (-1) + 0 = A - 1$ | Decrementa A en 1 |
| **1** | **1** | **1** | Transferencia | $1111\ (-1)$ | $A + (-1) + 1 = A$ | Transferencia alternativa de A |

### 4.2 Lógica de una Etapa Típica de 1 Bit (Bit-Slice)
Para cada etapa $i \in \{0, 1, 2, 3\}$, el circuito consta de:
1. **Generador del operando $Y_i$ (Lógica B):**
   $$Y_i = B_i \cdot S_0 \cdot \overline{S_1} + \overline{B_i} \cdot \overline{S_0} \cdot S_1 + S_1 \cdot S_0$$
   * Con $S_1 S_0 = 00 \implies Y_i = 0$
   * Con $S_1 S_0 = 01 \implies Y_i = B_i$
   * Con $S_1 S_0 = 10 \implies Y_i = \overline{B_i}$
   * Con $S_1 S_0 = 11 \implies Y_i = 1$

2. **Sumador Completo de 1 Bit (*Full Adder*):**
   $$Sum_i = A_i \oplus Y_i \oplus C_i$$
   $$C_{i+1} = (A_i \cdot Y_i) + (C_i \cdot (A_i \oplus Y_i))$$

3. **Detección de Desborde con Signo (*Overflow $V$*):**
   $$V = C_4 \oplus C_3$$

### 4.3 Archivos del Ejercicio 4
* Código RTL: [`ej4/circuito_aritmetico.sv`](ej4/circuito_aritmetico.sv)
* Testbench: [`ej4/circuito_aritmetico_tb.sv`](ej4/circuito_aritmetico_tb.sv)
* Esquemático RTL Vectorial: [`ej4/circuito_aritmetico_rtl.svg`](ej4/circuito_aritmetico_rtl.svg)
* Esquemático en Compuertas: [`ej4/circuito_aritmetico_gates.svg`](ej4/circuito_aritmetico_gates.svg)

---

## 🚀 Ejercicio 5: Unidad Aritmético-Lógica (ALU) Completa

### 5.1 Unificación de Secciones Aritmética y Lógica
El módulo ALU unifica el circuito aritmético del Ejercicio 4 con una unidad lógica de 4 funciones (Cuadro 3). La selección global se gobierna mediante el campo de control de 4 bits **$F[3:0]$**:
* **$F[3] = 0$:** Selecciona el resultado de la **Sección Aritmética** gobernado por $F[2:0] = \{S_1, S_0, C_{in}\}$.
* **$F[3] = 1$:** Selecciona el resultado de la **Sección Lógica** gobernado por $F[2:1] = \{S_1, S_0\}$ ($F[0]$ es irrelevante / 'don't care').

### 5.2 Tabla Completa de Operaciones de la ALU ($F[3:0]$)

| $F_3$ | $F_2$ ($S_1$) | $F_1$ ($S_0$) | $F_0$ ($C_{in}$) | Operación | Función Matemática / Lógica | Tipo |
| :---: | :---: | :---: | :---: | :--- | :--- | :--- |
| **0** | 0 | 0 | 0 | Transferencia A | $Y = A$ | Aritmética |
| **0** | 0 | 0 | 1 | Incremento | $Y = A + 1$ | Aritmética |
| **0** | 0 | 1 | 0 | Suma binaria | $Y = A + B$ | Aritmética |
| **0** | 0 | 1 | 1 | Suma con acarreo | $Y = A + B + 1$ | Aritmética |
| **0** | 1 | 0 | 0 | Resta a 1s | $Y = A + \overline{B}$ | Aritmética |
| **0** | 1 | 0 | 1 | Sustracción Ca2 | $Y = A - B$ ($A + \overline{B} + 1$) | Aritmética |
| **0** | 1 | 1 | 0 | Decremento | $Y = A - 1$ | Aritmética |
| **0** | 1 | 1 | 1 | Transferencia alt. | $Y = A$ | Aritmética |
| **1** | 0 | 0 | X | **AND bit a bit** | $Y = A \land B$ | Lógica |
| **1** | 0 | 1 | X | **OR bit a bit** | $Y = A \lor B$ | Lógica |
| **1** | 1 | 0 | X | **XOR bit a bit** | $Y = A \oplus B$ | Lógica |
| **1** | 1 | 1 | X | **NOT (Complemento)** | $Y = \overline{A}$ | Lógica |

### 5.3 Diagrama Jerárquico y Estructura Bit-Slice
Para cada bit $i$, la ALU cuenta con:
1. Una compuerta AND ($A_i \cdot B_i$), una compuerta OR ($A_i + B_i$), una compuerta XOR ($A_i \oplus B_i$) y un inversor ($\overline{A_i}$) dirigidos a un Mux 4:1 controlado por $F[2:1]$.
2. El sumador completo que calcula la suma aritmética $A_i + Y_i + C_i$.
3. Un multiplexor final 2 a 1 gobernado por $F[3]$ que conmuta entre la salida del sumador y la salida lógica.

### 5.4 Archivos del Ejercicio 5
* Código RTL: [`ej5/alu.sv`](ej5/alu.sv)
* Testbench: [`ej5/alu_tb.sv`](ej5/alu_tb.sv)
* Esquemático RTL Vectorial: [`ej5/alu_rtl.svg`](ej5/alu_rtl.svg)

---

## 🚀 Ejercicio 6: Banderas de Estado de la ALU (`flags[3:0] = {V, S, Z, C}`)

### 6.1 Definición de las Banderas (Cuadro 4)
Las cuatro banderas de estado proporcionan información sobre el resultado obtenido:
* **$V$ (Desborde / Overflow - `flags[3]`):** Indica que el resultado aritmético con signo desborda el rango de representación en complemento a 2 de 4 bits ($[-8, +7]$). Se calcula mediante:
  $$V = (F_3 == 0) \land (C_N \oplus C_{N-1})$$
  *(Forzado estrictamente a $0$ en operaciones lógicas).*
* **$S$ (Signo / Negative - `flags[2]`):** Refleja directamente el bit más significativo (MSB) del resultado:
  $$S = Result[N-1]$$
* **$Z$ (Cero / Zero - `flags[1]`):** Se activa cuando todos los bits del resultado son cero:
  $$Z = (Result == 0)$$
* **$C$ (Acarreo / Carry - `flags[0]`):** Acarreo de salida ($C_{out} = C_N$) de la sección aritmética:
  $$C = (F_3 == 0) \land C_N$$
  *(Forzado estrictamente a $0$ en operaciones lógicas).*

### 6.2 Verificación de las 5 Condiciones Requeridas
El banco de pruebas [`ej6/alu_tb.sv`](ej6/alu_tb.sv) comprueba rigurosamente cada condición requerida por la cátedra:

1. **Resultado Cero ($Z=1$):**  
   Resta $A - B$ con $A = 5, B = 5$ ($F = 0101$).  
   $5 - 5 = 0 \implies Result = 0x0$, $Flags = \{V=0, S=0, Z=1, C=1\}$ (4'b0011).
2. **Resultado Negativo ($S=1$):**  
   Resta $A - B$ con $A = 3, B = 7$ ($F = 0101$).  
   $3 - 7 = -4 = 0xC \implies Result = 0xC$, $Flags = \{V=0, S=1, Z=0, C=0\}$ (4'b0100).
3. **Acarreo sin Desborde ($C=1, V=0$):**  
   Suma $A + B$ con $A = 7$ (`0111`, positivo), $B = 10$ (`1010`, negativo: $-6$). ($F = 0010$).  
   Sin signo: $7 + 10 = 17 \ge 16 \implies C=1$. Con signo: $(+7) + (-6) = +1$ (cabe en 4 bits) $\implies V=0$.  
   $Flags = \{V=0, S=0, Z=0, C=1\}$ (4'b0001).
4. **Desborde sin Acarreo ($C=0, V=1$):**  
   Suma $A + B$ con $A = 5$ (`0101`, $+5$), $B = 4$ (`0100`, $+4$). ($F = 0010$).  
   Sin signo: $5 + 4 = 9 < 16 \implies C=0$. Con signo: $(+5) + (+4) = +9 > +7$ (desborda a $-7$) $\implies V=1, S=1$.  
   $Flags = \{V=1, S=1, Z=0, C=0\}$ (4'b1100).
5. **Operación Lógica con $C=0$ y $V=0$:**  
   Operación AND con $A = 4'b1111, B = 4'b1111$ ($F = 1000$).  
   $Result = 4'b1111 \implies S=1, Z=0$. Por ser lógica ($F_3=1$), $C=0$ y $V=0$.  
   $Flags = \{V=0, S=1, Z=0, C=0\}$ (4'b0100).

### 6.3 Archivos del Ejercicio 6
* Código RTL: [`ej6/alu.sv`](ej6/alu.sv)
* Testbench: [`ej6/alu_tb.sv`](ej6/alu_tb.sv)
* Esquemático RTL Vectorial: [`ej6/alu_flags_rtl.svg`](ej6/alu_flags_rtl.svg)

---

## 🚀 Ejercicio 7: Unidad de Corrimiento y Rotación Combinacional (Shifter)

### 7.1 Definición de Operaciones (Cuadro 5)
El Shifter toma la salida de la ALU ($D[3:0]$) y produce una salida combinacional $Y[3:0]$ según el código de control $H[2:0]$:

| $H_2$ | $H_1$ | $H_0$ | Operación | Expresión RTL (4 bits) | Descripción |
| :---: | :---: | :---: | :--- | :--- | :--- |
| **0** | **0** | **0** | **Transferencia** | $Y = D$ | Transfiere sin alterar |
| **0** | **0** | **1** | **SHL (Shift Left)** | $Y = \{D[2:0], 1'b0\}$ | Corrimiento a la izquierda con inserción de 0 en LSB |
| **0** | **1** | **0** | **ASR (Arith Shift Right)**| $Y = \{D[3], D[3:1]\}$ | Corrimiento aritmético a derecha (extiende bit de signo $D_3$) |
| **0** | **1** | **1** | **Bus Cero** | $Y = 4'b0000$ | Fuerza todos los bits de salida a 0 |
| **1** | **0** | **0** | **Transferencia** | $Y = D$ | Transferencia directa |
| **1** | **0** | **1** | **ROL (Rotate Left)** | $Y = \{D[2:0], D[3]\}$ | Rotación a izquierda (el bit MSB pasa a LSB) |
| **1** | **1** | **0** | **ROR (Rotate Right)** | $Y = \{D[0], D[3:1]\}$ | Rotación a derecha (el bit LSB pasa a MSB) |
| **1** | **1** | **1** | **Transferencia** | $Y = D$ | Transferencia directa |

### 7.2 Distinción de Patrones de Prueba en el Testbench
Para demostrar la correcta implementación y evitar ambigüedades entre operaciones similares:
* Con el vector $D = 4'b1100$ ($0xC$):
  - $SHL = 4'b1000$ (0 entra en LSB)
  - $ASR = 4'b1110$ (signo 1 se replica)
  - $Bus\_0 = 4'b0000$
  - $ROL = 4'b1001$ (MSB 1 rota a LSB) $\ne SHL$
  - $ROR = 4'b0110$ (LSB 0 rota a MSB) $\ne ASR$
* Con el vector $D = 4'b1000$:
  - $ASR = 4'b1100$ (extiende signo 1) mientras que $ROR = 4'b0100$ (LSB 0 rota a MSB).

### 7.3 Archivos del Ejercicio 7
* Código RTL: [`ej7/shifter.sv`](ej7/shifter.sv)
* Testbench: [`ej7/shifter_tb.sv`](ej7/shifter_tb.sv)
* Esquemático RTL Vectorial: [`ej7/shifter_rtl.svg`](ej7/shifter_rtl.svg)

---

## 🚀 Ejercicio 8: Microoperaciones y Palabra de Control de 16 Bits

### 8.1 Estructura de la Palabra de Control (Cuadro 1)
La palabra de control de la Unidad Procesadora agrupa 16 bits en 5 campos funcionales:

$$\underbrace{H_{15} H_{14} H_{13}}_{\text{Shifter (3b)}} \;\; \underbrace{F_{12} F_{11} F_{10} F_9}_{\text{ALU (4b)}} \;\; \underbrace{D_8 D_7 D_6}_{\text{Destino (3b)}} \;\; \underbrace{B_5 B_4 B_3}_{\text{Fuente B (3b)}} \;\; \underbrace{A_2 A_1 A_0}_{\text{Fuente A (3b)}}$$

* **Códigos de Registro:**  
  $R_1=001,\; R_2=010,\; R_3=011,\; R_4=100,\; R_5=101,\; R_6=110,\; R_7=111$.  
  El código `000` selecciona la entrada externa en buses $A$ y $B$, y deshabilita la escritura en $D$.

### 8.2 Resolución Completa del Cuadro 6

| Ítem | Microoperación | $H$ | $F$ | $D$ | $B$ | $A$ | Palabra Binaria (`H F D B A`) | Hexadecimal |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **(a)** | $R_2 \leftarrow R_1 + 1$ | `000` | `0001` | `010` | `000` | `001` | `000 0001 010 000 001` | `0x0281` |
| **(b)** | $R_3 \leftarrow R_4 + R_5$ | `000` | `0010` | `011` | `101` | `100` | `000 0010 011 101 100` | `0x04EC` |
| **(c)** | $R_6 \leftarrow \overline{R_6}$ | `000` | `1110` | `110` | `000` | `110` | `000 1110 110 000 110` | `0x1D86` |
| **(d)** | $R_7 \leftarrow R_7 - 1$ | `000` | `0110` | `111` | `000` | `111` | `000 0110 111 000 111` | `0x0DC7` |
| **(e)** | $R_1 \leftarrow \text{shl } R_1$ | `001` | `0000` | `001` | `000` | `001` | `001 0000 001 000 001` | `0x2041` |
| **(f)** | $R_2 \leftarrow \text{ror } R_2$ | `110` | `0000` | `010` | `000` | `010` | `110 0000 010 000 010` | `0xC082` |
| **(g)** | $R_5 \leftarrow R_3 + R_1$ | `000` | `0010` | `101` | `001` | `011` | `000 0010 101 001 011` | `0x054B` |
| **(h)** | $R_6 \leftarrow R_7$ | `000` | `0000` | `110` | `000` | `111` | `000 0000 110 000 111` | `0x0187` |

### 8.3 Verificación Funcional en el Datapath (`ej8/microcode_tb.sv`)
Se integró el Datapath completo (`datapath.sv`) y se precargaron valores en los registros ($R_1=3, R_4=2, R_5=5, R_6=10, R_7=7$), ejecutando la secuencia del Cuadro 6 paso a paso:
1. **(a)** $R_2 \leftarrow 3 + 1 = 4$ (`0x4`). ✅
2. **(b)** $R_3 \leftarrow 2 + 5 = 7$ (`0x7`). ✅
3. **(c)** $R_6 \leftarrow \sim(10) = 5$ (`0x5`). ✅
4. **(d)** $R_7 \leftarrow 7 - 1 = 6$ (`0x6`). ✅
5. **(e)** $R_1 \leftarrow \text{shl } 3 = 6$ (`0x6`). ✅
6. **(f)** $R_2 \leftarrow \text{ror } 4 = 2$ (`0x2`). ✅
7. **(g)** $R_5 \leftarrow 7 + 6 = 13$ (`0xD`). ✅
8. **(h)** $R_6 \leftarrow R_7 = 6$ (`0x6`). ✅

Todos los resultados fueron validados de forma automatizada al 100%.

### 8.4 Archivos del Ejercicio 8
* Código RTL: [`ej8/datapath.sv`](ej8/datapath.sv)
* Testbench: [`ej8/microcode_tb.sv`](ej8/microcode_tb.sv)
* Esquemático RTL Vectorial: [`ej8/datapath_rtl.svg`](ej8/datapath_rtl.svg)

---

## 🛠️ Comandos de Ejecución y Validación

### Ejecutar todas las simulaciones de una sola vez:
```bash
cd /home/valen/Facultad/Tecnicas_2/práctico/Tps/TP5
make sim
```

### Generar todos los esquemáticos SVG de una sola vez:
```bash
make svg-all
```

### Ejecutar y verificar individualmente:
```bash
# Ejercicio 5: ALU
cd /home/valen/Facultad/Tecnicas_2/práctico/Tps/TP5/ej5
make clean && make sim && make svg

# Ejercicio 6: Flags
cd /home/valen/Facultad/Tecnicas_2/práctico/Tps/TP5/ej6
make clean && make sim && make svg

# Ejercicio 7: Shifter
cd /home/valen/Facultad/Tecnicas_2/práctico/Tps/TP5/ej7
make clean && make sim && make svg

# Ejercicio 8: Datapath y Microcódigo
cd /home/valen/Facultad/Tecnicas_2/práctico/Tps/TP5/ej8
make clean && make sim && make svg
```
