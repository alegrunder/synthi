-------------------------------------------------------------------------------
-- Title      : infrastructure
-- Project    : 
-------------------------------------------------------------------------------
-- File       : infrastructure.vhd
-- Author     : grundale
-- Company    : 
-- Created    : 2024-02-20
-- Last update: 2024-02-20
-- Platform   : 
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2024 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author     Description
-- 2024-02-20  1.0      grundale   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity infrastructure is
  port (
    clock_50     : in  std_logic;
    key_0        : in  std_logic;
    usb_txd      : in  std_logic;
    clk_6m       : out std_logic;
    reset_n      : out std_logic;
    usb_txd_sync : out std_logic;
    ledr_0       : out std_logic
    );

end entity infrastructure;

-------------------------------------------------------------------------------

architecture infra_arch of infrastructure is

  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  signal clk_6m_sig : std_logic;

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

  component modulo_divider is
    port (
      clk    : in  std_logic;
      clk_6m : out std_logic);
  end component modulo_divider;

  component clock_sync is
    port (
      data_in  : in  std_logic;
      clk      : in  std_logic;
      sync_out : out std_logic);
  end component clock_sync;

  component signal_checker is
    port (
      clk, reset_n : in  std_logic;
      data_in      : in  std_logic;
      led_blink    : out std_logic);
  end component signal_checker;

begin  -- architecture infra_arch

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------
  
  clk_6m <= clk_6m_sig;
  
  -- instance "modulo_divider_1"
  modulo_divider_1 : modulo_divider
    port map (
      clk    => clock_50,
      clk_6m => clk_6m_sig);

  -- instance "clock_sync_1"
  clock_sync_1 : clock_sync
    port map (
      data_in  => key_0,
      clk      => clk_6m_sig,
      sync_out => reset_n);

  -- instance "clock_sync_2"
  clock_sync_2 : clock_sync
    port map (
      data_in  => usb_txd,
      clk      => clk_6m_sig,
      sync_out => usb_txd_sync);

  -- instance "signal_checker_1"
  signal_checker_1 : signal_checker
    port map (
      clk       => clock_50,
      reset_n   => key_0,
      data_in   => usb_txd,
      led_blink => ledr_0);

end architecture infra_arch;

-------------------------------------------------------------------------------
