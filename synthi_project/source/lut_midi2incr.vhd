-------------------------------------------------------------------------------
-- Title      : LUT MIDI to DDS increment
-- Project    : Synthi Pro
-------------------------------------------------------------------------------
-- File       : lut_midi2incr.vhd
-- Author     : heinipas
-- Company    : 
-- Created    : 2024-05-01
-- Last update: 2024-05-28
-- Platform   : 
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: wrapper for LUT_midi2dds
-------------------------------------------------------------------------------
-- Copyright (c) 2024 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2024-05-01  1.0      heinipas        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.tone_gen_pkg.all;

-------------------------------------------------------------------------------

entity lut_midi2incr is
  port (
    note_i     : in  std_logic_vector(6 downto 0);
    phi_incr_o : out std_logic_vector(18 downto 0)
    );

end entity lut_midi2incr;

-------------------------------------------------------------------------------

architecture str of lut_midi2incr is

begin  -- architecture str
  -----------------------------------------------------------------------------
  -- Concurrent Assignments
  -----------------------------------------------------------------------------
  phi_incr_o <= LUT_midi2dds(to_integer(unsigned(note_i)));

end architecture str;

-------------------------------------------------------------------------------
