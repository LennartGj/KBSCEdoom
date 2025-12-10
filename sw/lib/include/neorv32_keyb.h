#ifndef NEORV32_KEYB_H
#define NEORV32_KEYB_H

#include <stdint.h>

uint16_t neorv32_keyb_getRaw(void);
uint8_t neorv32_keyb_keycode(uint16_t keycodes, int which);
uint8_t neorv32_keyb_getDoomRefKey(int which, uint16_t keycode);
uint8_t neorv32_keyb_isKeyPressed(uint16_t raw);

#endif