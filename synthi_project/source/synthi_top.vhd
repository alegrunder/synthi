-------------------------------------------------------------------------------
-- Title      : synthi_top
-- Project    : 
-------------------------------------------------------------------------------
-- File       : synthi_top.vhd
-- Author     : grundale
-- Company    : 
-- Created    : 2018-03-08
-- Last update: 2022-02-20
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
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------

entity synthi_top is

  port (
    CLOCK_50 : in std_logic;            -- DE2 clock from xtal 50MHz
    KEY_0    : in std_logic;            -- DE2 low_active input buttons
    KEY_1    : in std_logic;            -- DE2 low_active input buttons
    SW       : in std_logic_vector(9 downto 0);  -- DE2 input switches

    USB_RXD : in std_logic;             -- USB (midi) serial_input
    USB_TXD : in std_logic;             -- USB (midi) serial_output

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
  -----------------------------------------------------------------------------;
  signal clk_6m_sig : std_logic;
  signal reset_n_sig : std_logic;
  signal serial_sig  : std_logic;

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component infrastructure is
    port (
      clock_50     : in  std_logic;
      key_0        : in  std_logic;
      usb_txd      : in  std_logic;
      clk_6m       : out std_logic;
      reset_n      : out std_logic;
      usb_txd_sync : out std_logic;
      ledr_0       : out std_logic
      );
  end component infrastructure;

  component uart_top is
    port (
      clk_6m      : in  std_logic;
      reset_n     : in  std_logic;
      serial_in   : in  std_logic;
      rx_data_rdy : out std_logic;
      rx_data     : out std_logic_vector(7 downto 0);
      hex0        : out std_logic_vector(6 downto 0);
      hex1        : out std_logic_vector(6 downto 0)
      );
  end component uart_top;

begin

-----------------------------------------------------------------------------
  -- Architecture Description
-----------------------------------------------------------------------------

  -- instance "infrastructure_1"
  infrastructure_1 : infrastructure
    port map (
      clock_50 => CLOCK_50,
      key_0 => KEY_0,
      usb_txd => USB_TXD,
      clk_6m => clk_6m_sig,
      reset_n => reset_n_sig,
      usb_txd_sync => serial_sig,
      ledr_0 => LEDR_0
      );

  -- instance "uart_top_1"
  uart_top_1 : uart_top
    port map (
      clk_6m => clk_6m_sig,
      reset_n => reset_n_sig,
      serial_in => serial_sig,
      hex0 => HEX0,
      hex1 => HEX1
      );

end architecture struct;

-------------------------------------------------------------------------------

