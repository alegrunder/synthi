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
		use ieee.numeric_std.all;
library work;
	use work.tone_gen_pkg.all;

-------------------------------------------------------------------------------

entity tone_generator is
  port (
    clk        : in  std_logic;
    rst_n      : in  std_logic;
    step_i     : in  std_logic;         -- f_s
    note_i     : in  std_logic_vector(6 downto 0);
    velocity_i : in  std_logic_vector(6 downto 0);
    tone_on_i  : in  std_logic;         -- later a vector
	 control		: in std_logic;
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

  component dds is
    port (
      clk        : in  std_logic;
      reset_n    : in  std_logic;
      phi_incr_i : in  std_logic_vector(18 downto 0);
      tone_on_i  : in  std_logic;
		control	  : in  std_logic; -- used for control commands
      step_i     : in  std_logic;
      attenu_i   : in  std_logic_vector(6 downto 0);
      dds_o      : out std_logic_vector(15 downto 0));
  end component dds;

	signal dds_o_LR : std_logic_vector(15 downto 0);
begin  -- architecture str
dds_l_o  <= dds_o_LR;
dds_r_o <= dds_o_LR;
	
  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------

  -- instance "dds_1"
  dds_1: dds
    port map (
      clk        => clk,
      reset_n    => rst_n,
      phi_incr_i => LUT_midi2dds(to_integer(unsigned(note_i))),
      tone_on_i  => tone_on_i,
      step_i     => step_i,
		control 	  => control,
      attenu_i   => velocity_i,
      dds_o      => dds_o_LR);
		

		 

end architecture str;

-------------------------------------------------------------------------------
