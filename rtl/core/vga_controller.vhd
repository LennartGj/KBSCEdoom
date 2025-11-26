```library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_controller is
    port (
        clk_i     : in  std_logic; -- 100 MHz System Clock
        rst_n_i   : in  std_logic;
        -- Color inputs from NEORV32 GPIO
        red_i     : in  std_logic_vector(3 downto 0);
        green_i   : in  std_logic_vector(3 downto 0);
        blue_i    : in  std_logic_vector(3 downto 0);
        -- VGA Hardware Outputs
        vga_hs_o  : out std_logic;
        vga_vs_o  : out std_logic;
        vga_r_o   : out std_logic_vector(3 downto 0);
        vga_g_o   : out std_logic_vector(3 downto 0);
        vga_b_o   : out std_logic_vector(3 downto 0)
    );
end vga_controller;

architecture Behavioral of vga_controller is
    -- 640x480 @ 60Hz Timing Constants (25 MHz Pixel Clock)
    constant H_VISIBLE : integer := 640;
    constant H_FRONT   : integer := 16;
    constant H_SYNC    : integer := 96;
    constant H_BACK    : integer := 48;
    constant H_TOTAL   : integer := 800;

    constant V_VISIBLE : integer := 480;
    constant V_FRONT   : integer := 10;
    constant V_SYNC    : integer := 2;
    constant V_BACK    : integer := 33;
    constant V_TOTAL   : integer := 525;

    signal h_cnt : unsigned(9 downto 0) := (others => '0');
    signal v_cnt : unsigned(9 downto 0) := (others => '0');
    signal clk_25mhz_en : std_logic := '0';
    signal clk_div      : unsigned(1 downto 0) := (others => '0');
    signal active_area  : std_logic;

begin

    -- 1. Generate 25 MHz Enable from 100 MHz
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            clk_div <= clk_div + 1;
            if clk_div = 3 then
                clk_25mhz_en <= '1';
                clk_div <= "00";
            else
                clk_25mhz_en <= '0';
            end if;
        end if;
    end process;

    -- 2. Horizontal and Vertical Counters
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_n_i = '0' then
                h_cnt <= (others => '0');
                v_cnt <= (others => '0');
            elsif clk_25mhz_en = '1' then
                if h_cnt = H_TOTAL - 1 then
                    h_cnt <= (others => '0');
                    if v_cnt = V_TOTAL - 1 then
                        v_cnt <= (others => '0');
                    else
                        v_cnt <= v_cnt + 1;
                    end if;
                else
                    h_cnt <= h_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    -- 3. Sync Signals (Active Low)
    process(clk_i)
    begin
        if rising_edge(clk_i) then
             -- HSync is low during the sync pulse
            if (h_cnt >= (H_VISIBLE + H_FRONT)) and (h_cnt < (H_VISIBLE + H_FRONT + H_SYNC)) then
                vga_hs_o <= '0';
            else
                vga_hs_o <= '1';
            end if;

            -- VSync is low during the sync pulse
            if (v_cnt >= (V_VISIBLE + V_FRONT)) and (v_cnt < (V_VISIBLE + V_FRONT + V_SYNC)) then
                vga_vs_o <= '0';
            else
                vga_vs_o <= '1';
            end if;
        end if;
    end process;

    -- 4. Output RGB Data only in Active Area
    active_area <= '1' when (h_cnt < H_VISIBLE) and (v_cnt < V_VISIBLE) else '0';

    vga_r_o <= red_i   when active_area = '1' else (others => '0');
    vga_g_o <= green_i when active_area = '1' else (others => '0');
    vga_b_o <= blue_i  when active_area = '1' else (others => '0');

end Behavioral;```