library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

entity neorv32_test_setup_bootloader is
  generic (
    CLOCK_FREQUENCY : natural := 100_000_000; -- 100 MHz
    IMEM_SIZE       : natural := 16*1024;
    DMEM_SIZE       : natural := 8*1024
  );
  port (
    clk_i       : in  std_logic;
    rstn_i      : in  std_logic;
    -- GPIO voor NEORV32
    gpio_o      : out std_ulogic_vector(15 downto 0);
    gpio_i      : in  std_ulogic_vector(15 downto 0);
    -- UART0
    uart0_txd_o : out std_logic;
    uart0_rxd_i : in  std_logic;
    -- VGA
    vga_hs_o    : out std_logic;
    vga_vs_o    : out std_logic;
    vga_r_o     : out std_logic_vector(3 downto 0);
    vga_g_o     : out std_logic_vector(3 downto 0);
    vga_b_o     : out std_logic_vector(3 downto 0);
    -- PS/2
    ps2_clk     : in  std_logic;
    ps2_data    : in  std_logic
  );
end entity;

architecture rtl of neorv32_test_setup_bootloader is

  signal con_gpio_out : std_ulogic_vector(31 downto 0);
  signal con_gpio_in  : std_ulogic_vector(31 downto 0);
  
  signal vga_red_int   : std_logic_vector(3 downto 0);
  signal vga_green_int : std_logic_vector(3 downto 0);
  signal vga_blue_int  : std_logic_vector(3 downto 0);

  signal keycode_int : std_logic_vector(15 downto 0);

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

  component PS2Receiver is
    port (
      clk        : in  std_logic;
      kclk       : in  std_logic;
      kdata      : in  std_logic;
      keycodeout : out std_logic_vector(15 downto 0)
    );
  end component;

begin

  -- NEORV32 core
  neorv32_top_inst: neorv32_top
    generic map (
      CLOCK_FREQUENCY  => CLOCK_FREQUENCY,
      BOOT_MODE_SELECT => 0,
      RISCV_ISA_C      => true,
      RISCV_ISA_M      => true,
      RISCV_ISA_Zicntr => true,
      IMEM_EN          => true,
      IMEM_SIZE        => IMEM_SIZE,
      DMEM_EN          => true,
      DMEM_SIZE        => DMEM_SIZE,
      IO_GPIO_NUM      => 32,
      IO_CLINT_EN      => true,
      IO_UART0_EN      => true
    )
    port map (
      clk_i       => clk_i,
      rstn_i      => rstn_i,
      gpio_o      => con_gpio_out,
      gpio_i      => con_gpio_in,
      uart0_txd_o => uart0_txd_o,
      uart0_rxd_i => uart0_rxd_i
    );

  -- stuur PS/2 keycodes naar GPIO-input van NEORV32
  con_gpio_in(15 downto 0) <= std_ulogic_vector(keycode_int);

  -- stuur GPIO-output naar fysieke leds
  gpio_o <= con_gpio_out(15 downto 0);

  -- VGA mapping
  vga_red_int   <= std_logic_vector(con_gpio_out(3 downto 0));
  vga_green_int <= std_logic_vector(con_gpio_out(7 downto 4));
  vga_blue_int  <= std_logic_vector(con_gpio_out(11 downto 8));

  inst_vga: vga_controller
    port map (
      clk_i     => clk_i,
      rst_n_i   => rstn_i,
      red_i     => vga_red_int,
      green_i   => vga_green_int,
      blue_i    => vga_blue_int,
      vga_hs_o  => vga_hs_o,
      vga_vs_o  => vga_vs_o,
      vga_r_o   => vga_r_o,
      vga_g_o   => vga_g_o,
      vga_b_o   => vga_b_o
    );

  -- PS/2 receiver
  inst_ps2: PS2Receiver
    port map (
      clk        => clk_i,
      kclk       => ps2_clk,
      kdata      => ps2_data,
      keycodeout => keycode_int
    );

end architecture;
