-------------------------------------------------------------------------------
-- Title      : Source Select
-- Project    : Synthi
-------------------------------------------------------------------------------
-- File       : source_select.vhd
-- Author     : heinipas
-- Company    : 
-- Created    : 2024-04-02
-- Last update: 2024-04-02
-- Platform   : 
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: select source signal from PC or MIDI
-------------------------------------------------------------------------------
-- Copyright (c) 2024 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2024-04-02  1.0      heinipas        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity source_select is
  port (
    clk         : in  std_logic;
    reset_n     : in  std_logic;
    usb_i       : in  std_logic;        -- Data Input from USB
    midi_i      : in  std_logic;        -- Data Input from MIDI
    sw_i        : in  std_logic;        -- select source: 0=MIDI, 1=USB
    data_o      : out std_logic;        -- Data Output
    baud_rate_o : out positive          -- baud rate output
    );

end entity source_select;

-------------------------------------------------------------------------------

architecture str of source_select is

  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  constant baud_rate_midi : positive := 31_250;  -- Baudrate MIDI
  constant baud_rate_usb  : positive := 115_200;  -- Baudrate UART

  signal baud_rate, next_baud_rate : positive;
  signal data, next_data           : std_logic;

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

begin  -- architecture str
  --------------------------------------------------
  -- PROCESS FOR ALL FLIP-FLOPS
  --------------------------------------------------
  flip_flops : process(all)
  begin
    if reset_n = '0' then
      baud_rate <= baud_rate_midi;  -- convert integer value 0 to unsigned with 4bits
      data      <= '1';
    elsif rising_edge(clk) then
      baud_rate <= next_baud_rate;
      data      <= next_data;
    end if;
  end process flip_flops;


  -----------------------------------------------------------------------------
  -- PROCESS FOR COMB-LOGIC
  -----------------------------------------------------------------------------
  comb_logic : process (all) is
  begin  -- process fsm_out_logic
    -- default statements
    next_baud_rate <= baud_rate_midi;
    next_data      <= midi_i;

    if sw_i = '1' then
      next_baud_rate <= baud_rate_usb;
      next_data      <= usb_i;
    end if;
  end process comb_logic;

  -----------------------------------------------------------------------------
  -- CONCURRENT ASSIGNMENTS
  -----------------------------------------------------------------------------
  data_o      <= data;
  baud_rate_o <= baud_rate;

end architecture str;

-------------------------------------------------------------------------------
