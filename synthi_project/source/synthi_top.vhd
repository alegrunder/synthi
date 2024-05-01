  -------------------------------------------------------------------------------
-- Title      : synthi_top
-- Project    : synthi
-------------------------------------------------------------------------------
-- File       : synthi_top.vhd
-- Author     : grundale
-- Company    : 
-- Created    : 2018-03-08
-- Last update: 2024-04-16
-- Platform   : 
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Top Level for Synthesizer
-------------------------------------------------------------------------------
-- Copyright (c) 2018 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2018-03-08  1.0      Hans-Joachim    Created
-- 2024-02-20  1.1      grundale        modyfied for Lab1
-- 2024-03-05  1.2      heinipas        added clk_12m
-- 2024-03-05  2.0      heinipas        added codec_controller and i2c_master
-- 2024-03-26  2.1      heinipas        added MS2, MS3, MS4 blocks
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.tone_gen_pkg.all;

-------------------------------------------------------------------------------

entity synthi_top is
  port (
    CLOCK_50 : in std_logic;            -- DE2 clock from xtal 50MHz
    KEY_0    : in std_logic;            -- DE2 low_active input buttons
    KEY_1    : in std_logic;            -- DE2 low_active input buttons
    SW       : in std_logic_vector(9 downto 0);  -- DE2 input switches

    USB_RXD : in std_logic;             -- USB (midi) serial_input
    USB_TXD : in std_logic;             -- USB (midi) serial_output
    GPIO_26 : in std_logic;             -- MIDI serial input

    BT_RXD   : in std_logic;            -- Bluetooth serial_input
    BT_TXD   : in std_logic;            -- Bluetooth serial_output
    BT_RST_N : in std_logic;            -- Bluetooth reset_n

    AUD_XCK     : out std_logic;        -- master clock for Audio Codec
    AUD_DACDAT  : out std_logic;        -- audio serial data to Codec-DAC
    AUD_BCLK    : out std_logic;        -- bit clock for audio serial data
    AUD_DACLRCK : out std_logic;        -- left/right word select for Codec-DAC
    AUD_ADCLRCK : out std_logic;        -- left/right word select for Codec-ADC
    AUD_ADCDAT  : in  std_logic;        -- audio serial data from Codec-ADC

    AUD_SCLK : out   std_logic;         -- clock from I2C master block
    AUD_SDAT : inout std_logic;         -- data  from I2C master block

    HEX0   : out std_logic_vector(6 downto 0);  -- output for HEX 0 display
    HEX1   : out std_logic_vector(6 downto 0);  -- output for HEX 0 display
    HEX2   : out std_logic_vector(6 downto 0);  -- output for HEX 2 display
    HEX3   : out std_logic_vector(6 downto 0);  -- output for HEX 3 display
    LEDR_0 : out std_logic;                     -- red LED
    LEDR_1 : out std_logic;                     -- red LED
    LEDR_2 : out std_logic;                     -- red LED
    LEDR_3 : out std_logic;                     -- red LED
    LEDR_4 : out std_logic;                     -- red LED
    LEDR_5 : out std_logic;                     -- red LED
    LEDR_6 : out std_logic;                     -- red LED
    LEDR_7 : out std_logic;                     -- red LED
    LEDR_8 : out std_logic;                     -- red LED
    LEDR_9 : out std_logic                      -- red LED
    );

end entity synthi_top;


-------------------------------------------------------------------------------

architecture struct of synthi_top is

  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  signal clk_6m_sig       : std_logic;
  signal reset_n_sig      : std_logic;
  signal usb_txd_sync_sig : std_logic;
  signal midi_sync_sig    : std_logic;
  signal uart_serial_sig  : std_logic;
  signal write_done       : std_logic;
  signal ack_error        : std_logic;
  signal write            : std_logic;
  signal write_data       : std_logic_vector(15 downto 0);
  signal adcdat_pl        : std_logic_vector(15 downto 0);
  signal adcdat_pr        : std_logic_vector(15 downto 0);
  signal dacdat_pl        : std_logic_vector(15 downto 0);
  signal dacdat_pr        : std_logic_vector(15 downto 0);
  signal ws_sig           : std_logic;
  signal step_sig         : std_logic;
  signal dds_l            : std_logic_vector(15 downto 0);
  signal dds_r            : std_logic_vector(15 downto 0);
  signal note_sig         : t_tone_array;
  signal velocity_sig     : t_tone_array;
  signal note_on_sig      : std_logic_vector(9 downto 0);
  signal rx_data_rdy_sig  : std_logic;
  signal rx_data_sig      : std_logic_vector(7 downto 0);
  signal baud_rate_sig    : positive;
  signal vol_reg_sig      : std_logic_vector(6 downto 0);
  signal pitch_reg_sig    : std_logic_vector(6 downto 0);
  signal ctrl_reg_sig     : std_logic_vector(6 downto 0);
  signal note_valid_sig   : std_logic_vector(9 downto 0);


  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component infrastructure is
    port (
      clock_50     : in  std_logic;
      key_0        : in  std_logic;
      usb_txd      : in  std_logic;
      midi_i       : in  std_logic;
      clk_6m       : out std_logic;
      clk_12m      : out std_logic;
      reset_n      : out std_logic;
      usb_txd_sync : out std_logic;
      midi_sync    : out std_logic;
      led_usb      : out std_logic
      );
  end component infrastructure;

  component midi_uart is
    port (
      clk_6m      : in  std_logic;
      reset_n     : in  std_logic;
      serial_in   : in  std_logic;
      baud_rate_i : in  positive;
      rx_data_rdy : out std_logic;
      rx_data     : out std_logic_vector(7 downto 0);
      hex0        : out std_logic_vector(6 downto 0);
      hex1        : out std_logic_vector(6 downto 0)
      );
  end component midi_uart;

  component codec_controller is
    port (
      mode         : in  std_logic_vector(2 downto 0);
      write_done_i : in  std_logic;
      ack_error_i  : in  std_logic;
      clk          : in  std_logic;
      reset_n      : in  std_logic;
      write_o      : out std_logic;
      write_data_o : out std_logic_vector(15 downto 0));
  end component codec_controller;

  component i2c_master is
    port (
      clk          : in    std_logic;
      reset_n      : in    std_logic;
      write_i      : in    std_logic;
      write_data_i : in    std_logic_vector(15 downto 0);
      sda_io       : inout std_logic;
      scl_o        : out   std_logic;
      write_done_o : out   std_logic;
      ack_error_o  : out   std_logic);
  end component i2c_master;

  component i2s_master is
    port (
      clk_6m      : in  std_logic;
      rst_n       : in  std_logic;
      step_o      : out std_logic;
      adcdat_pl_o : out std_logic_vector(15 downto 0);
      adcdat_pr_o : out std_logic_vector(15 downto 0);
      dacdat_pl_i : in  std_logic_vector(15 downto 0);
      dacdat_pr_i : in  std_logic_vector(15 downto 0);
      dacdat_s_o  : out std_logic;
      ws_o        : out std_logic;
      adcdat_s_i  : in  std_logic);
  end component i2s_master;

  component path_control is
    port (
      sw_3        : in  std_logic;
      dds_l_i     : in  std_logic_vector(15 downto 0);
      dds_r_i     : in  std_logic_vector(15 downto 0);
      adcdat_pl_i : in  std_logic_vector(15 downto 0);
      adcdat_pr_i : in  std_logic_vector(15 downto 0);
      dacdat_pl_o : out std_logic_vector(15 downto 0);
      dacdat_pr_o : out std_logic_vector(15 downto 0));
  end component path_control;

  component tone_generator is
    port (
      clk          : in  std_logic;
      rst_n        : in  std_logic;
      step_i       : in  std_logic;
      note_i       : in  t_tone_array;
      velocity_i   : in  t_tone_array;
      tone_on_i    : in  std_logic_vector(9 downto 0);
      vol_reg_i    : in  std_logic_vector(6 downto 0);
      pitch_reg_i  : in  std_logic_vector(6 downto 0);
      ctrl_reg_i   : in  std_logic_vector(6 downto 0);
          low_pass_enable_i : in  std_logic;
      preset_sel_i    : in  std_logic_vector(2 downto 0);  -- select presets
	  note_valid_o : out std_logic_vector(9 downto 0);
      dds_l_o      : out std_logic_vector(15 downto 0);
      dds_r_o      : out std_logic_vector(15 downto 0));
  end component tone_generator;

  component midi_controller is
    port (
      clk           : in  std_logic;
      reset_n       : in  std_logic;
      rx_data_rdy_i : in  std_logic;
      rx_data_i     : in  std_logic_vector(7 downto 0);
	  note_valid_i  : in  std_logic_vector(9 downto 0);
      hex2          : out std_logic_vector(6 downto 0);
      hex3          : out std_logic_vector(6 downto 0);
      note_on_o     : out std_logic_vector(9 downto 0);
      note_o        : out t_tone_array;
      velocity_o    : out t_tone_array;
      vol_reg_o     : out std_logic_vector(6 downto 0);
      pitch_reg_o   : out std_logic_vector(6 downto 0);
      ctrl_reg_o    : out std_logic_vector(6 downto 0));
  end component midi_controller;

  component source_select is
    port (
      clk         : in  std_logic;
      reset_n     : in  std_logic;
      usb_i       : in  std_logic;
      midi_i      : in  std_logic;
      sw_i        : in  std_logic;
      data_o      : out std_logic;
      baud_rate_o : out positive);
  end component source_select;

begin

-----------------------------------------------------------------------------
  -- Architecture Description
-----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Concurrent Assignments
  -----------------------------------------------------------------------------
  AUD_DACLRCK <= ws_sig;
  AUD_ADCLRCK <= ws_sig;
  AUD_BCLK    <= not(clk_6m_sig);       -- invert for I2S
  LEDR_0      <= note_on_sig(0) or note_valid_sig(0);
  LEDR_1      <= note_on_sig(1) or note_valid_sig(1);
  LEDR_2      <= note_on_sig(2) or note_valid_sig(2);
  LEDR_3      <= note_on_sig(3) or note_valid_sig(3);
  LEDR_4      <= note_on_sig(4) or note_valid_sig(4);
  LEDR_5      <= note_on_sig(5) or note_valid_sig(5);
  LEDR_6      <= note_on_sig(6) or note_valid_sig(6);
  LEDR_7      <= note_on_sig(7) or note_valid_sig(7);
  LEDR_8      <= note_on_sig(8) or note_valid_sig(8);
  LEDR_9      <= note_on_sig(9) or note_valid_sig(9);

  -----------------------------------------------------------------------------
  -- Instances
  -----------------------------------------------------------------------------
  -- instance "infrastructure_1"
  infrastructure_1 : infrastructure
    port map (
      clock_50     => CLOCK_50,
      key_0        => KEY_0,
      usb_txd      => USB_TXD,
      midi_i       => GPIO_26,
      clk_6m       => clk_6m_sig,
      clk_12m      => AUD_XCK,
      reset_n      => reset_n_sig,
      usb_txd_sync => usb_txd_sync_sig,
      midi_sync    => midi_sync_sig
      --led_usb      => LEDR_0
      );

  -- instance "midi_uart_1"
  midi_uart_1 : midi_uart
    port map (
      clk_6m      => clk_6m_sig,
      reset_n     => reset_n_sig,
      serial_in   => uart_serial_sig,
      baud_rate_i => baud_rate_sig,
      rx_data_rdy => rx_data_rdy_sig,
      rx_data     => rx_data_sig,
      hex0        => HEX0,
      hex1        => HEX1
      );

  -- instance "codec_controller_1"
  codec_controller_1 : codec_controller
    port map (
      mode         => SW(2 downto 0),
      write_done_i => write_done,
      ack_error_i  => ack_error,
      clk          => clk_6m_sig,
      reset_n      => reset_n_sig,
      write_o      => write,
      write_data_o => write_data);

  -- instance "i2c_master_1"
  i2c_master_1 : i2c_master
    port map (
      clk          => clk_6m_sig,
      reset_n      => reset_n_sig,
      write_i      => write,
      write_data_i => write_data,
      sda_io       => AUD_SDAT,
      scl_o        => AUD_SCLK,
      write_done_o => write_done,
      ack_error_o  => ack_error);

  -- instance "i2s_master_1"
  i2s_master_1 : i2s_master
    port map (
      clk_6m      => clk_6m_sig,
      rst_n       => reset_n_sig,
      step_o      => step_sig,
      adcdat_pl_o => adcdat_pl,
      adcdat_pr_o => adcdat_pr,
      dacdat_pl_i => dacdat_pl,
      dacdat_pr_i => dacdat_pr,
      dacdat_s_o  => AUD_DACDAT,
      ws_o        => ws_sig,
      adcdat_s_i  => AUD_ADCDAT);

  -- instance "path_control_1"
  path_control_1 : path_control
    port map (
      sw_3        => SW(3),
      dds_l_i     => dds_l,
      dds_r_i     => dds_r,
      adcdat_pl_i => adcdat_pl,
      adcdat_pr_i => adcdat_pr,
      dacdat_pl_o => dacdat_pl,
      dacdat_pr_o => dacdat_pr);

  -- instance "tone_generator_1"
  tone_generator_1 : tone_generator
    port map (
      clk          => clk_6m_sig,
      rst_n        => reset_n_sig,
      step_i       => step_sig,
      note_i       => note_sig,
      velocity_i   => velocity_sig,
      tone_on_i    => note_on_sig,
      vol_reg_i    => vol_reg_sig,
      pitch_reg_i  => pitch_reg_sig,
      ctrl_reg_i   => ctrl_reg_sig,
      low_pass_enable_i => SW(5),
      preset_sel_i  => SW(8 downto 6),
      note_valid_o => note_valid_sig,
      dds_l_o      => dds_l,
      dds_r_o      => dds_r
    );

  -- instance "midi_controller_1"
  midi_controller_1 : midi_controller
    port map (
      clk           => clk_6m_sig,
      reset_n       => reset_n_sig,
      rx_data_rdy_i => rx_data_rdy_sig,
      rx_data_i     => rx_data_sig,
      note_valid_i  => note_valid_sig,
      hex2          => HEX2,
      hex3          => HEX3,
      note_on_o     => note_on_sig,
      note_o        => note_sig,
      velocity_o    => velocity_sig,
      vol_reg_o     => vol_reg_sig,
      pitch_reg_o   => pitch_reg_sig,
      ctrl_reg_o    => ctrl_reg_sig);

  -- instance "source_select_1"
  source_select_1 : source_select
    port map (
      clk         => clk_6m_sig,
      reset_n     => reset_n_sig,
      usb_i       => usb_txd_sync_sig,
      midi_i      => midi_sync_sig,
      sw_i        => SW(4),
      data_o      => uart_serial_sig,
      baud_rate_o => baud_rate_sig);


end architecture struct;

-------------------------------------------------------------------------------

