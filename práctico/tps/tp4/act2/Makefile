PREFIX   = arm-none-eabi-
CC       = $(PREFIX)gcc
OBJCOPY  = $(PREFIX)objcopy

CFLAGS   = -mcpu=cortex-m3 -mthumb -g -Wall
CFLAGS  += -Isrc -I. -ICMSIS -ICMSIS/m-profile
CFLAGS  += -IFreeRTOS/include
CFLAGS  += -IFreeRTOS/portable/GCC/ARM_CM3
CFLAGS  += -DSTM32F103xB
CFLAGS  += -ffunction-sections -fdata-sections
CFLAGS  += -MMD -MP

LDFLAGS  = -T ld/STM32F103XB_FLASH.ld -nostartfiles
LDFLAGS += -Wl,--gc-sections -Wl,-Map=app.map

SRCS     = CMSIS/startup_stm32f103xb.s \
           CMSIS/system_stm32f1xx.c \
           src/syscalls.c \
           src/main.c \
           FreeRTOS/list.c \
           FreeRTOS/queue.c \
           FreeRTOS/tasks.c \
           FreeRTOS/timers.c \
           FreeRTOS/portable/MemMang/heap_4.c \
           FreeRTOS/portable/GCC/ARM_CM3/port.c

OBJS     = $(SRCS:.c=.o)
OBJS    := $(OBJS:.s=.o)

DEPS     = $(OBJS:.o=.d)

all: app.elf app.bin app.hex

app.elf: $(OBJS)
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

app.bin: app.elf
	$(OBJCOPY) -O binary $< $@

app.hex: app.elf
	$(OBJCOPY) -O ihex $< $@

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.s
	$(CC) -c -mcpu=cortex-m3 -mthumb -o $@ $<

-include $(DEPS)

flash: app.elf
	openocd -f interface/stlink.cfg -c "set CPUTAPID 0x2ba01477" -f target/stm32f1x.cfg -c "program app.elf verify reset exit"

clean:
	rm -f $(OBJS) $(DEPS) app.elf app.bin app.hex app.map

.PHONY: all flash clean
