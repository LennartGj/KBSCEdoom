#include <neorv32.h>

/**
 * @brief Lees beide 8-bit keycodes van GPIO (keycode1 = LSB, keycode2 = MSB)
 *
 * @return 16-bit waarde: [15:8] = keycode2, [7:0] = keycode1
 */
uint16_t neorv32_keyb_getRaw(void) {
    return NEORV32_GPIO->PORT_IN & 0xFFFF;
}

/**
 * @brief Haal individuele keycodes uit de 16-bit waarde, kies 1 (meest recent) of 2 (vorige keycode)
 */
uint8_t neorv32_keyb_keycode(uint16_t keycodes, int which) {
    if (which == 1)
        return keycodes & 0xFF;  // LSB
    else
        return (keycodes >> 8) & 0xFF;  // MSB
}

uint8_t neorv32_keyb_isKeyPressed(uint16_t raw) {
    return (raw >> 8) & 1;
}

uint8_t neorv32_keyb_getDoomRefKey(int which, uint16_t keycode) {
    if (which == 1)
        keycode = keycode & 0x00ff;
    else if (which == 2)
        keycode = keycode & 0xff00;

    switch (keycode) {
        case 0x6B:  // ← left arrow
            return 0;
        case 0x74:  // → right arrow
            return 1;
        case 0x72:  // ↓ down arrow
            return 2;
        case 0x75:  // ↑ up arrow
            return 3;
        case 0x59:  // Right Shift
            return 4;
        case 0x14:  // Right Ctrl (same make-code as left ctrl)
            return 5;
        case 0x11:  // Right Alt (same make-code as left alt)
            return 6;
        case 0x76:  // Escape
            return 7;
        case 0x5A:  // Enter
            return 8;
        case 0x0D:  // Tab
            return 9;
        case 0x66:  // Backspace
            return 10;
        case 0x4D:  // P
            return 11;
        case 0x55:  // =
            return 12;
        case 0x4E:  // -
            return 13;
        case 0x05:  // F1
            return 14;
        case 0x06:  // F2
            return 15;
        case 0x04:  // F3
            return 16;
        case 0x0C:  // F4
            return 17;
        case 0x03:  // F5
            return 18;
        case 0x0B:  // F6
            return 19;
        case 0x83:  // F7
            return 20;
        case 0x0A:  // F8
            return 21;
        case 0x01:  // F9
            return 22;
        case 0x09:  // F10
            return 23;
        case 0x78:  // F11
            return 24;
        case 0x07:  // F12
            return 25;
        case 0xf0:
            return 80;  // release code
        case 0xe0:
            return 81;  // extend code
        default:
            return 100;  // Unknown / unsupported
    }
    return 100;
}
