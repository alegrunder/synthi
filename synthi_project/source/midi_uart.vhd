-------------------------------------------------------------------------------
-- Title      : midi_uart
-- Project    : Synthi Pro
-------------------------------------------------------------------------------
-- File       : midi_uart.vhd
-- Author     : heinipas
-- Company    : 
-- Created    : 2018-03-08
-- Last update: 2024-05-31
-- Platform   : 
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: UART receiver for MIDI signals
-------------------------------------------------------------------------------
-- Copyright (c) 2018 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
--             1.0      heinipas
-- 2024-03-26  1.1      heinipas        renamed uart_top to midi_uart
-- 2024-05-31  1.2      heinipas        beautified
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;

entity midi_uart is
  port
    (
      clk_6m      : in  std_logic;
      reset_n     : in  std_logic;
      serial_in   : in  std_logic;
      baud_rate_i : in  positive;
      rx_data_rdy : out std_logic;
      rx_data     : out std_logic_vector(7 downto 0);
      hex0        : out std_logic_vector(6 downto 0);
      hex1        : out std_logic_vector(6 downto 0)
      );
end midi_uart;

architecture uart_arch of midi_uart is

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component flanken_detekt_vhdl
    port(data_in     : in  std_logic;
         clock       : in  std_logic;
         reset_n     : in  std_logic;
         fl_steigend : out std_logic;
         fl_fallend  : out std_logic
         );
  end component;

  component signal_checker
    port(clk       : in  std_logic;
         reset_n   : in  std_logic;
         data_in   : in  std_logic;
         led_blink : out std_logic
         );
  end component;

  component vhdl_hex2sevseg
    port(data_in : in  std_logic_vector(3 downto 0);
         seg_out : out std_logic_vector(6 downto 0)
         );
  end component;

  component clock_sync
    port(data_in  : in  std_logic;
         clk      : in  std_logic;
         sync_out : out std_logic
         );
  end component;

  component baud_tick
    port(clk         : in  std_logic;
         reset_n     : in  std_logic;
         start_pulse : in  std_logic;
         baud_rate_i : in  positive;
         tick        : out std_logic
         );
  end component;

  component bit_counter
    port(clk         : in  std_logic;
         reset_n     : in  std_logic;
         baud_tick   : in  std_logic;
         start_pulse : in  std_logic;
         bit_count   : out std_logic_vector(3 downto 0)
         );
  end component;

  component uart_controller_fsm
    port(clk           : in  std_logic;
         reset_n       : in  std_logic;
         falling_pulse : in  std_logic;
         baud_tick     : in  std_logic;
         bit_count     : in  std_logic_vector(3 downto 0);
         parallel_data : in  std_logic_vector(9 downto 0);
         shift_enable  : out std_logic;
         start_pulse   : out std_logic;
         data_valid    : out std_logic
         );
  end component;

  component shiftreg_uart
    generic (width : integer
             );
    port(clk          : in  std_logic;
         reset_n      : in  std_logic;
         shift_enable : in  std_logic;
         serial_in    : in  std_logic;
         parallel_out : out std_logic_vector(9 downto 0)
         );
  end component;

  component output_register
    port(clk         : in  std_logic;
         reset_n     : in  std_logic;
         data_valid  : in  std_logic;
         parallel_in : in  std_logic_vector(9 downto 0);
         hex_lsb     : out std_logic_vector(3 downto 0);
         hex_msb     : out std_logic_vector(3 downto 0)
         );
  end component;

  component modulo_divider
    port(clk    : in  std_logic;
         clk_6m : out std_logic
         );
  end component;

  signal tick          : std_logic;
  signal start_pulse   : std_logic;
  signal falling_pulse : std_logic;
  signal data_valid    : std_logic;
  signal shift_enable  : std_logic;
  signal bit_count     : std_logic_vector(3 downto 0);
  signal hex_lsb_out   : std_logic_vector(3 downto 0);
  signal hex_msb_out   : std_logic_vector(3 downto 0);
  signal parallel_data : std_logic_vector(9 downto 0);
  signal baud_rate_sig : positive;


begin
  -----------------------------------------------------------------------------
  -- Concurrent Assignments
  -----------------------------------------------------------------------------
  rx_data       <= parallel_data(8 downto 1);
  rx_data_rdy   <= data_valid;
  baud_rate_sig <= baud_rate_i;

  -----------------------------------------------------------------------------
  -- Instances
  -----------------------------------------------------------------------------
  flanken_detekt_vhdl_inst1 : flanken_detekt_vhdl
    port map(data_in    => serial_in,
             clock      => clk_6m,
             reset_n    => reset_n,
             fl_fallend => falling_pulse);


  vhdl_hex2sevseg_inst1 : vhdl_hex2sevseg
    port map(data_in => hex_lsb_out,
             seg_out => hex0);


  vhdl_hex2sevseg_inst2 : vhdl_hex2sevseg
    port map(data_in => hex_msb_out,
             seg_out => hex1);


  baud_tick_inst1 : baud_tick
    port map(clk         => clk_6m,
             reset_n     => reset_n,
             start_pulse => start_pulse,
             baud_rate_i => baud_rate_sig,
             tick        => tick);


  bit_counter_inst1 : bit_counter
    port map(clk         => clk_6m,
             reset_n     => reset_n,
             baud_tick   => tick,
             start_pulse => start_pulse,
             bit_count   => bit_count);


  uart_controller_fsm_inst1 : uart_controller_fsm
    port map(clk           => clk_6m,
             reset_n       => reset_n,
             falling_pulse => falling_pulse,
             baud_tick     => tick,
             bit_count     => bit_count,
             parallel_data => parallel_data,
             shift_enable  => shift_enable,
             start_pulse   => start_pulse,
             data_valid    => data_valid);


  shiftreg_uart_inst1 : shiftreg_uart
    generic map(width => 10)
    port map(clk          => clk_6m,
             reset_n      => reset_n,
             shift_enable => shift_enable,
             serial_in    => serial_in,
             parallel_out => parallel_data);


  output_register_inst1 : output_register
    port map(clk         => clk_6m,
             reset_n     => reset_n,
             data_valid  => data_valid,
             parallel_in => parallel_data,
             hex_lsb     => hex_lsb_out,
             hex_msb     => hex_msb_out);


end uart_arch;
