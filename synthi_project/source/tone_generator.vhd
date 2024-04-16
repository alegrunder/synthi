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
    note_i     : in  t_tone_array;
    velocity_i : in  t_tone_array;
    tone_on_i  : in  std_logic_vector(9 downto 0);         -- later a vector
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
type t_dds_o_array is array (0 to 9) of std_logic_vector(N_AUDIO-1 downto 0);
signal dds_o_array : t_dds_o_array;
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
      control_reg1 : in std_logic_vector(6 downto 0); -- used for control commands
      step_i     : in  std_logic;
      attenu_i   : in  std_logic_vector(6 downto 0);
      dds_o      : out std_logic_vector(15 downto 0));
  end component dds;

	signal dds_o_LR : std_logic_vector(15 downto 0);
	signal sum_reg : signed(N_AUDIO-1 downto 0);
	signal next_sum_reg : signed(N_AUDIO-1 downto 0);
	
begin  -- architecture str
dds_l_o  <= dds_o_LR;
dds_r_o <= dds_o_LR;
	
  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------

  -- instance "dds_1"
dds_inst_gen : for i in 0 to 9 generate
	dds_1: dds
		 port map (
			clk        => clk,
			reset_n    => rst_n,
			phi_incr_i => LUT_midi2dds(to_integer(unsigned(note_i(i)))),
			tone_on_i  => tone_on_i(i),
			step_i     => step_i,
			control 	  => control,
			control_reg1 => note_i(i),
			attenu_i   => velocity_i(i),
			dds_o      => dds_o_array(i));
end generate dds_inst_gen;
		
	
comb_sum_output : process(all)
	variable var_sum : signed(N_AUDIO-1 downto 0);
	begin
	var_sum := (others => '0');
	if step_i = '1' then
		dds_sum_loop : for i in 0 to 9 loop
			var_sum := var_sum + signed(dds_o_array(i));
		end loop dds_sum_loop;
		next_sum_reg <= var_sum;
	else
		next_sum_reg <= sum_reg;
	end if;
end process comb_sum_output;

reg_sum_output : process(clk, rst_n)
begin
	if rst_n = '0' then
		sum_reg <= (others => '0');
	elsif rising_edge(clk) then
		sum_reg <= next_sum_reg;
	end if;
end process reg_sum_output;

		 

end architecture str;

-------------------------------------------------------------------------------
