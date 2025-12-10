// ================================================================================ //
// NEORV32 PS/2 Keyboard Reader Demo
// Reads 16-bit keycode from GPIO and prints via UART0
// ================================================================================ //

#include <neorv32.h>

#define BAUD_RATE 19200

void delay_ms(uint32_t time_ms) {
    neorv32_aux_delay_ms(neorv32_sysinfo_get_clk(), time_ms);
}

int main() {
    // Setup
    neorv32_rte_setup();
    neorv32_uart0_setup(BAUD_RATE, 0);

    // Check if GPIO is available
    if (neorv32_gpio_available() == 0) {
        neorv32_uart0_printf("Error: No GPIO unit synthesized!\n");
        return 1;
    }

    neorv32_gpio_port_set(0);  // clear output

    while (1) {
        uint16_t raw = neorv32_keyb_getRaw();
        uint8_t scan = raw & 0xFF;

        uint8_t pressed;

        // Als high byte 0xF0 is → released, pressed = 0
        // Als high byte 0xE0 is → pressed, pressed = 1
        // Anders → pressed = 1
        uint8_t code_hi = (raw >> 8) & 0xFF;

        if (code_hi == 0xF0) {
            pressed = 0;  // released
        } else {
            pressed = 1;  // pressed
        }

        neorv32_uart0_printf("RAW = %x\n", raw);

        // if (pressed) {
        //     neorv32_uart0_printf("pressed = %x\n", scan);
        // } else {
        //     neorv32_uart0_printf("released = %x\n", scan);
        // }

        // delay_ms(1000);
    }

    return 0;
}
