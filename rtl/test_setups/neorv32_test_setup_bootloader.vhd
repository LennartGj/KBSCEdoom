-- ================================================================================ --
-- NEORV32 - Test Setup Using The UART-Bootloader To Upload And Run Executables     --
-- -------------------------------------------------------------------------------- --
-- The NEORV32 RISC-V Processor - https://github.com/stnolting/neorv32              --
-- Copyright (c) NEORV32 contributors.                                              --
-- Copyright (c) 2020 - 2025 Stephan Nolting. All rights reserved.                  --
-- Licensed under the BSD-3-Clause license, see LICENSE for details.                --
-- SPDX-License-Identifier: BSD-3-Clause                                            --
-- ================================================================================ --
--Dit si een testi voor de Sennaiiiii
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

entity neorv32_test_setup_bootloader is
  generic (
    -- adapt these for your setup --
    CLOCK_FREQUENCY : natural := 100000000; -- clock frequency of clk_i in Hz
    IMEM_SIZE       : natural := 16*1024;   -- size of processor-internal instruction memory in bytes
    DMEM_SIZE       : natural := 8*1024     -- size of processor-internal data memory in bytes
  );
  port (
    -- Global control --
    clk_i       : in  std_ulogic; -- global clock, rising edge
    rstn_i      : in  std_ulogic; -- global reset, low-active, async
    -- GPIO --
    gpio_o      : out std_ulogic_vector(15 downto 0); -- parallel output
    gpio_i      : in  std_ulogic_vector(4 downto 0);
    gpio_i_sw   : in  std_ulogic_vector(15 downto 0);
    -- UART0 --
    uart0_txd_o : out std_ulogic; -- UART0 send data
    uart0_rxd_i : in  std_ulogic;  -- UART0 receive data
       -- NEW VGA PORTS --
    vga_hs_o    : out std_logic;
    vga_vs_o    : out std_logic;
    vga_r_o     : out std_logic_vector(3 downto 0);
    vga_g_o     : out std_logic_vector(3 downto 0);
    vga_b_o     : out std_logic_vector(3 downto 0)
  );
end entity;

architecture neorv32_test_setup_bootloader_rtl of neorv32_test_setup_bootloader is

  signal con_gpio_out : std_ulogic_vector(31 downto 0);
  signal con_gpio_in : std_ulogic_vector(31 downto 0);
  
   -- Signal types conversion for VGA component
  signal vga_red_int   : std_logic_vector(3 downto 0);
  signal vga_green_int : std_logic_vector(3 downto 0);
  signal vga_blue_int  : std_logic_vector(3 downto 0);

-- Component Declaration
  component vga_controller is
    port (
        clk_i     : in  std_logic;
        rst_n_i   : in  std_logic;
        red_i     : in  std_logic_vector(3 downto 0);
        green_i   : in  std_logic_vector(3 downto 0);
        blue_i    : in  std_logic_vector(3 downto 0);
        vga_hs_o  : out std_logic;
        vga_vs_o  : out std_logic;
        vga_r_o   : out std_logic_vector(3 downto 0);
        vga_g_o   : out std_logic_vector(3 downto 0);
        vga_b_o   : out std_logic_vector(3 downto 0)
    );
  end component;  

begin

  -- The Core Of The Problem ----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  neorv32_top_inst: neorv32_top
  generic map (
    -- Clocking --
    CLOCK_FREQUENCY  => CLOCK_FREQUENCY,   -- clock frequency of clk_i in Hz
    -- Boot Configuration --
    BOOT_MODE_SELECT => 0,                 -- boot via internal bootloader
    -- RISC-V CPU Extensions --
    RISCV_ISA_C      => true,              -- implement compressed extension?
    RISCV_ISA_M      => true,              -- implement mul/div extension?
    RISCV_ISA_Zicntr => true,              -- implement base counters?
    -- Internal Instruction memory --
    IMEM_EN          => true,              -- implement processor-internal instruction memory
    IMEM_SIZE        => IMEM_SIZE, -- size of processor-internal instruction memory in bytes
    -- Internal Data memory --
    DMEM_EN          => true,              -- implement processor-internal data memory
    DMEM_SIZE        => DMEM_SIZE, -- size of processor-internal data memory in bytes
    -- Processor peripherals --
    IO_GPIO_NUM      => 32,                 -- number of GPIO input/output pairs (0..32)
    IO_CLINT_EN      => true,              -- implement core local interruptor (CLINT)?
    IO_UART0_EN      => true               -- implement primary universal asynchronous receiver/transmitter (UART0)?
  )
  port map (
    -- Global control --
    clk_i       => clk_i,        -- global clock, rising edge
    rstn_i      => rstn_i,       -- global reset, low-active, async
    -- GPIO (available if IO_GPIO_NUM > 0) --
    gpio_o      => con_gpio_out, -- parallel output
    gpio_i      => con_gpio_in,
    -- primary UART0 (available if IO_UART0_EN = true) --
    uart0_txd_o => uart0_txd_o,  -- UART0 send data
    uart0_rxd_i => uart0_rxd_i   -- UART0 receive data
  );

  -- GPIO output --
  gpio_o <= con_gpio_out(15 downto 0);
  con_gpio_in(15 downto 0) <= gpio_i_sw(15 downto 0);
  con_gpio_in(20 downto 16) <= gpio_i(4 downto 0);
  
    -- Map NEORV32 GPIO to VGA Colors
  -- GPIO [3:0] -> Red
  -- GPIO [7:4] -> Green
  -- GPIO [11:8] -> Blue
  vga_red_int   <= std_logic_vector(con_gpio_out(3 downto 0));
  vga_green_int <= std_logic_vector(con_gpio_out(7 downto 4));
  vga_blue_int  <= std_logic_vector(con_gpio_out(11 downto 8));

  -- Instantiate VGA Controller
  inst_vga: vga_controller 
  port map (
      clk_i     => std_logic(clk_i),
      rst_n_i   => std_logic(rstn_i),
      red_i     => vga_red_int,
      green_i   => vga_green_int,
      blue_i    => vga_blue_int,
      vga_hs_o  => vga_hs_o,
      vga_vs_o  => vga_vs_o,
      vga_r_o   => vga_r_o,
      vga_g_o   => vga_g_o,
      vga_b_o   => vga_b_o
  );
end architecture;
