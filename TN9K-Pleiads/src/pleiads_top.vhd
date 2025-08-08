---------------------------------------------------------------------------------
--                         Pleiads - Tang Nano 9k
--                        Code from Mister project
--
--                        Modified for Tang Nano 9k 
--                            by pinballwiz.org 
--                               09/08/2025
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------
entity pleiads_top is
port(
	Clock_27    : in std_logic;
    I_RESET     : in std_logic;
	O_VIDEO_R	: out std_logic; 
	O_VIDEO_G	: out std_logic;
	O_VIDEO_B	: out std_logic;
	O_HSYNC		: out std_logic;
	O_VSYNC		: out std_logic;
	O_AUDIO_L 	: out std_logic;
	O_AUDIO_R 	: out std_logic;
    ps2_clk     : in    std_logic;
    ps2_dat     : inout std_logic;
    led         : out std_logic_vector(5 downto 0)
);
end;
---------------------------------------------------------------------------------
architecture rtl of pleiads_top is

	signal clk44      : std_logic;
	signal ena22      : std_logic;
	signal ena11      : std_logic;
	signal reset      : std_logic;
	signal pll_locked : std_logic;
    --
	signal audio      : std_logic_vector(11 downto 0);
	signal audio_out  : std_logic;
	signal video_r	  : std_logic_vector(1 downto 0);
	signal video_g	  : std_logic_vector(1 downto 0);
	signal video_b	  : std_logic_vector(1 downto 0);
	signal vsync	  : std_logic;
	signal hsync	  : std_logic;
    --
	signal dip_switch  : std_logic_vector(7 downto 0);
	signal ce_pix      : std_logic;
    --
	signal video_r_x2  : std_logic_vector(3 downto 0);
	signal video_g_x2  : std_logic_vector(3 downto 0);
	signal video_b_x2  : std_logic_vector(3 downto 0);
	signal hsync_x2    : std_logic;
	signal vsync_x2    : std_logic;  
    --
	signal div_cnt     : std_logic_vector(1 downto 0);
    --
    signal kbd_intr        : std_logic;
    signal kbd_scancode    : std_logic_vector(7 downto 0);
    signal joyHBCPPFRLDU   : std_logic_vector(7 downto 0);
    --
    constant CLOCK_FREQ    : integer := 27E6;
    signal counter_clk     : std_logic_vector(25 downto 0);
    signal clock_4hz       : std_logic;
	signal AD              : std_logic_vector(15 downto 0);
-----------------------------------------------------------------------
component Gowin_rPLL
    port (
        clkout: out std_logic;
        lock: out std_logic;
        clkin: in std_logic
    );
end component;
-----------------------------------------------------------------------  
begin

	reset <= not I_RESET;
-----------------------------------------------------------------------
clocks: Gowin_rPLL
    port map (
        clkout => clk44,
        lock => pll_locked,
        clkin => Clock_27
    );
-----------------------------------------------------------------------
  p_clk_div : process(pll_locked, clk44)
  begin
    if (pll_locked = '0') then
      div_cnt <= (others => '0');
      ena22   <= '0';
      ena11   <= '0';
    elsif rising_edge(clk44) then
      div_cnt <= div_cnt + "1";
      ena22   <= div_cnt(0);
      ena11   <= div_cnt(0) and not div_cnt(1);
    end if;
  end process;		
----------------------------------------------------------------------
-- main

	phoenix : entity work.phoenix
	port map
	(
		clk          => ena11, -- 11Mhz
		reset        => reset,
        pause        => '0',
        flip_screen  => '0',
		ce_pix       => ce_pix, -- not used
		dip_switch   => dip_switch,
		btn_coin     => joyHBCPPFRLDU(7),
		btn_player_start(0) => joyHBCPPFRLDU(5),
		btn_player_start(1) => joyHBCPPFRLDU(6),
		btn_left     => joyHBCPPFRLDU(2),
		btn_right    => joyHBCPPFRLDU(3),
		btn_barrier  => joyHBCPPFRLDU(1),
		btn_fire     => joyHBCPPFRLDU(4),
		video_r      => video_r,
		video_g      => video_g,
		video_b      => video_b,
		video_hs     => hsync,
		video_vs     => vsync,
		audio_select => "000",
		audio        => audio,
        AD           => AD
	);	
-----------------------------------------------------------------------  
vga: entity work.scandoubler
	port map(
		clk_sys => ena22,
		scanlines => '0',
		r_in   => video_r & video_r,
		g_in   => video_g & video_g,
		b_in   => video_b & video_b,
		hs_in  => hsync,
		vs_in  => vsync,
		r_out  => video_r_x2(3 downto 1),
		g_out  => video_g_x2(3 downto 1),
		b_out  => video_b_x2(3 downto 1),
		hs_out => hsync_x2,
		vs_out => vsync_x2
	);
-----------------------------------------------------------------------
  O_VIDEO_R <= video_r_x2(3);
  O_VIDEO_G <= video_g_x2(3);
  O_VIDEO_B <= video_b_x2(3);
  O_HSYNC   <= hsync_x2;
  O_VSYNC   <= vsync_x2;
-----------------------------------------------------------------------
-- get scancode from keyboard

keyboard : entity work.io_ps2_keyboard
port map (
  clk       => ena11,
  kbd_clk   => ps2_clk,
  kbd_dat   => ps2_dat,
  interrupt => kbd_intr,
  scancode  => kbd_scancode
);
-----------------------------------------------------------------------
-- translate scancode to joystick

joystick : entity work.kbd_joystick
port map (
  clk           => ena11,
  kbdint        => kbd_intr,
  kbdscancode   => std_logic_vector(kbd_scancode), 
  JoyPCFRLDU    => joyHBCPPFRLDU
);
-----------------------------------------------------------------------	
-- dac

	dac : entity work.pwm_sddac
	port  map(
		clk_i	=> clk44,
		reset	=> reset,
		dac_i	=> audio,
		dac_o	=> audio_out,
		we		=> '1'
	);

	O_AUDIO_R <= audio_out;
	O_AUDIO_L <= audio_out;
-----------------------------------------------------------------------	
-- dips

	dip_switch <= "00001111";
	
	--   SWITCH 1:     SWITCH 2:    NUMBER OF SPACESHIPS:
	--   ---------     ---------    ---------------------
	--     OFF           OFF                  6
	--     ON            OFF                  5
	--     OFF           ON                   4
	--     ON            ON                   3
	--                               FIRST FREE     SECOND FREE
	--   SWITCH 3:     SWITCH 4:     SHIP SCORE:    SHIP SCORE:
	--  ---------     ---------     -----------    -----------
	--     OFF           OFF           6,000          60,000
	--     ON            OFF           5,000          50,000
	--     OFF           ON            4,000          40,000
	--     ON            ON            3,000          30,000
	 
	--Cocktail,Factory,Factory,Factory,Bonus2,Bonus1,Ships2,Ships1
-----------------------------------------------------------------------
-- debug

process(reset, clock_27)
begin
  if reset = '1' then
    clock_4hz <= '0';
    counter_clk <= (others => '0');
  else
    if rising_edge(clock_27) then
      if counter_clk = CLOCK_FREQ/8 then
        counter_clk <= (others => '0');
        clock_4hz <= not clock_4hz;
        led(5 downto 0) <= not AD(9 downto 4);
      else
        counter_clk <= counter_clk + 1;
      end if;
    end if;
  end if;
end process;
------------------------------------------------------------------------
end rtl;