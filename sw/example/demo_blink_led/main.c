// ================================================================================ //
// The NEORV32 RISC-V Processor - https://github.com/stnolting/neorv32              //
// Copyright (c) NEORV32 contributors.                                              //
// Copyright (c) 2020 - 2025 Stephan Nolting. All rights reserved.                  //
// Licensed under the BSD-3-Clause license, see LICENSE for details.                //
// SPDX-License-Identifier: BSD-3-Clause                                            //
// ================================================================================ //


/**********************************************************************//**
 * @file demo_blink_led/main.c
 * @author Stephan Nolting
 * @brief Minimal blinking LED demo program using the 16 bits of the GPIO.output port.
 **************************************************************************/
#include <neorv32.h>


/**********************************************************************//**
 * Simple bus-wait helper.
 *
 * @param[in] time_ms Time in ms to wait (unsigned 32-bit).
 **************************************************************************/
void delay_ms(uint32_t time_ms) {
  neorv32_aux_delay_ms(neorv32_sysinfo_get_clk(), time_ms);
}

#define BAUD_RATE 19200

/**********************************************************************//**
 * Main function; shows an incrementing 16-bit counter on GPIO.output(7:0).
 *
 * @note This program requires the GPIO controller to be synthesized.
 *
 * @return Will never return.
 **************************************************************************/
int main() {

  // clear GPIO output (set all bits to 0)
  neorv32_gpio_port_set(0);
  neorv32_rte_setup();
  neorv32_uart0_setup(BAUD_RATE, 0);


  int cnt = 0;
  
  while(1){
    neorv32_uart0_printf("input = %u\n", neorv32_gpio_pin_get(0));
    if (neorv32_gpio_pin_get(0)) {
      neorv32_gpio_port_set(cnt++ & 0xFFFF); // increment counter and mask for 16 bit
      delay_ms(25); // wait 25ms using busy wait
    }
    else if (neorv32_gpio_pin_get(1)) {
      neorv32_gpio_port_set(cnt-- & 0xFFFF); // increment counter and mask for 16 bit
      delay_ms(25); // wait 25ms using busy wait
    }

    delay_ms(25); // wait 25ms using busy wait
  }


  // this should never be reached
  return 0;
}
