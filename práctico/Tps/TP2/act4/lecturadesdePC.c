#include <stdio.h>      // printf(), perror()
#include <stdlib.h>     // exit()
#include <fcntl.h>      // open()
#include <unistd.h>     // read(), write(), close()
#include <termios.h>    // configuración UART Linux
#include <signal.h>     // Ctrl+C (SIGINT)
#include <string.h>

#define SERIAL_PORT "/dev/ttyUSB0"

int fd;                         // descriptor del puerto serie
struct termios oldtty;         // configuración original

void cerrar_programa(int sig)
{
    tcsetattr(fd, TCSANOW, &oldtty);  // restaurar configuración
    close(fd);                        // cerrar puerto
    printf("\nPuerto cerrado.\n");
    exit(0);
}

int main(void)
{
    struct termios tty;   // nueva configuración UART

    signal(SIGINT, cerrar_programa); // Ctrl+C -> cerrar_programa()

    // Abrir UART en modo lectura/escritura y sin terminal controladora
    fd = open(SERIAL_PORT, O_RDWR | O_NOCTTY); 

    if (fd < 0)
    {
        perror("No se pudo abrir el puerto serie /dev/ttyUSB0");
        printf("Sugerencia: ¿Está conectada la placa y configurados los permisos? (ej. sudo chmod 666 /dev/ttyUSB0)\n");
        return 1;
    }

    tcgetattr(fd, &oldtty); // leer config actual
    tty = oldtty;           // copiar configuración base

    cfmakeraw(&tty);        // modo raw: sin eco, sin procesar saltos de línea ni señales especiales

    cfsetispeed(&tty, B9600); // velocidad de recepción: 9600 baudios
    cfsetospeed(&tty, B9600); // velocidad de transmisión: 9600 baudios

    tty.c_cflag |= CLOCAL | CREAD; // habilitar transmisión/recepción local
    tty.c_cflag &= ~PARENB;        // sin paridad (8N1)
    tty.c_cflag &= ~CSTOPB;        // 1 bit de stop
    tty.c_cflag &= ~CSIZE;         // limpiar tamaño de palabra anterior
    tty.c_cflag |= CS8;            // trama de 8 bits de datos

    tty.c_lflag &= ~ECHO;          // desactivar eco local

    tty.c_cc[VMIN]  = 1;           // esperar al menos 1 byte por cada llamada a read()
    tty.c_cc[VTIME] = 0;           // sin temporizador de espera (bloqueante indefinido)

    tcflush(fd, TCIFLUSH);         // limpiar buffers
    tcsetattr(fd, TCSANOW, &tty);  // aplicar cambios de configuración de inmediato

    printf("Puerto %s configurado correctamente a 9600 8N1.\n", SERIAL_PORT);
    printf("Ctrl+C para salir de la aplicación.\n");

    while (1)
    {
        // Mostrar menú interactivo por terminal
        printf("\n===== MENU UART =====\n");
        printf("1: LED_ON\n");
        printf("2: LED_OFF\n");
        printf("3: LED_TITILA\n");
        printf("0: Salir\n");
        printf("Opcion: ");
        fflush(stdout);

        char opcion;
        // Leer la opción seleccionada por teclado
        if (scanf(" %c", &opcion) != 1) {
            continue;
        }

        // Opción de salida
        if (opcion == '0') {
            write(fd, &opcion, 1);
            printf("Saliendo de la aplicación...\n");
            break;
        }

        // Validar rango
        if (opcion < '1' || opcion > '3') {
            printf("Opción no válida. Intente nuevamente.\n");
            continue;
        }

        // Limpiar el buffer de entrada para asegurar que no leemos respuestas previas acumuladas
        tcflush(fd, TCIFLUSH);

        // Enviar la opción seleccionada a la BluePill
        if (write(fd, &opcion, 1) != 1) {
            perror("Error de escritura en el puerto serie");
            break;
        }

        // Leer la respuesta enviada por la BluePill (terminada en '\n')
        char respuesta[256];
        int idx = 0;
        char c;
        int n;

        while (idx < 255) {
            n = read(fd, &c, 1);
            if (n > 0) {
                if (c == '\n') {
                    respuesta[idx] = '\0';
                    break;
                }
                // Ignorar retornos de carro (\r) y guardar caracteres imprimibles
                if (c != '\r') {
                    respuesta[idx++] = c;
                }
            } else if (n < 0) {
                perror("Error de lectura del puerto serie");
                break;
            }
        }
        
        printf("BluePill responde: %s\n", respuesta);
    }

    cerrar_programa(0);
    return 0;
}
