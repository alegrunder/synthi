-------------------------------------------------------------------------------
-- Title      : codec_controller
-- Project    : synthi
-------------------------------------------------------------------------------
-- File       : codec_controller.vhd
-- Author     : doblesam, grundale, heinipas
-- Company    : 
-- Created    : 2024-03-05
-- Last update: 2024-03-05
-- Platform   : 
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: block for codec controller
-------------------------------------------------------------------------------
-- Copyright (c) 2024 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2024-03-05  1.0      heini   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity codec_controller is

  port (
    clk          : in  std_logic;
    reset_n      : in  std_logic;
    mode         : in  std_logic_vector(2 downto 0);
    write_done_i : in  std_logic;
    ack_error_i  : in  std_logic;
    write_o      : out std_logic;
    write_data_o : out std_logic_vector(15 downto 0)
    );

end entity codec_controller;

-------------------------------------------------------------------------------

architecture str of codec_controller is

  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

begin  -- architecture str

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------

end architecture str;

-------------------------------------------------------------------------------
