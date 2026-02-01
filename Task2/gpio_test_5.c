#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define GPIO_ADDR (*(volatile unsigned int*)0x20000000)

// Delay means introduce NOP opcodes into the code : Wow Learnt.
#define DELAY 10

// Software delay for bare-metal RISC-V
void wait_cycles(volatile int count) {
    while (count-- > 0) {
        __asm__ volatile("nop");
    }
}

int main() {
    unsigned int x, y, i = 100;

    GPIO_ADDR = 100 + i;
    wait_cycles(DELAY);  // Pause
    y = GPIO_ADDR;
    wait_cycles(DELAY);  // Pause

    GPIO_ADDR = 100 + i*2;
    wait_cycles(DELAY);  // Pause
    y = GPIO_ADDR;
    wait_cycles(DELAY);  // Pause

    GPIO_ADDR = 100 + i*3;
    wait_cycles(DELAY);  // Pause
    y = GPIO_ADDR;
    wait_cycles(DELAY);  // Pause

    GPIO_ADDR = 100 + i*4;
    wait_cycles(DELAY);  // Pause
    y = GPIO_ADDR;
    wait_cycles(DELAY);  // Pause

    GPIO_ADDR = 100 + i*5;
    wait_cycles(DELAY);  // Pause
    y = GPIO_ADDR;
    wait_cycles(DELAY);  // Pause

    GPIO_ADDR = 100 + i*6;
    wait_cycles(DELAY);  // Pause
    y = GPIO_ADDR;
    wait_cycles(DELAY);  // Pause

    return 0;
}






