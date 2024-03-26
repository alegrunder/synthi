-------------------------------------------------------------------------------
-- Title      : Tone Generator
-- Project    : synthi
-------------------------------------------------------------------------------
-- File       : tone_generator.vhd
-- Author     : heinipas
-- Company    : 
-- Created    : 2024-03-26
-- Last update: 2024-03-26
-- Platform   : 
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2024 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2024-03-26  1.0      heinipas        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity tone_generator is
  port (
    clk        : in  std_logic;
    rst_n      : in  std_logic;
    step_i     : in  std_logic;         -- f_s
    note_i     : in  std_logic_vector(6 downto 0);
    velocity_i : in  std_logic_vector(6 downto 0);
    tone_on_i  : in  std_logic;         -- later a vector
    dds_l_o    : out std_logic_vector(15 downto 0);
    dds_r_o    : out std_logic_vector(15 downto 0)
    );

end entity tone_generator;

-------------------------------------------------------------------------------

architecture str of tone_generator is

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
