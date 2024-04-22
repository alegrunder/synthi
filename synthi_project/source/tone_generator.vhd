-------------------------------------------------------------------------------
-- Title      : Tone Generator
-- Project    : synthi
-------------------------------------------------------------------------------
-- File       : tone_generator.vhd
-- Author     : heinipas
-- Company    : 
-- Created    : 2024-03-26
-- Last update: 2024-04-16
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
-- 2024-04-10  2.0      doblesam        implemented tone gen functions
-- 2024-04-16  2.1      grundale        added note valid feedack for midi ctrl
-- 2024-04-16  2.2      heinipas        added synchronous note valid feedback
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.tone_gen_pkg.all;

-------------------------------------------------------------------------------

entity tone_generator is
  port (
    clk          : in  std_logic;
    rst_n        : in  std_logic;
    step_i       : in  std_logic;        -- f_s
    note_i       : in  t_tone_array;
    velocity_i   : in  t_tone_array;
    tone_on_i    : in  std_logic_vector(9 downto 0);
    vol_reg_i    : in  std_logic_vector(6 downto 0);
    pitch_reg_i  : in  std_logic_vector(6 downto 0);
    ctrl_reg_i   : in  std_logic_vector(6 downto 0);  -- used for control commands
	note_valid_o : out std_logic_vector(9 downto 0);
    dds_l_o      : out std_logic_vector(15 downto 0);
    dds_r_o      : out std_logic_vector(15 downto 0)
    );

end entity tone_generator;

-------------------------------------------------------------------------------

architecture str of tone_generator is

  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  type t_dds_o_array is array (0 to 9) of std_logic_vector(N_AUDIO-1 downto 0);
  signal dds_o_array : t_dds_o_array;
  --signal note_valid, next_note_valid : std_logic_vector(9 downto 0);
  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component ADSR is --dds
    port (
      clk         : in  std_logic;
      reset_n     : in  std_logic;
      phi_incr_i  : in  std_logic_vector(18 downto 0);
      tone_on_i   : in  std_logic;
      velocity_i  : in  std_logic_vector(6 downto 0);
      step_i      : in  std_logic;
      vol_reg_i   : in  std_logic_vector(6 downto 0);
      pitch_reg_i : in  std_logic_vector(6 downto 0);
      ctrl_reg_i  : in  std_logic_vector(6 downto 0);
--<<<<<<< Updated upstream
--      dds_o       : out std_logic_vector(15 downto 0));
--  end component dds;
--
--  -- signal dds_o_LR     : std_logic_vector(15 downto 0);
--  signal sum_reg      : signed(N_AUDIO-1 downto 0);
--  signal next_sum_reg : signed(N_AUDIO-1 downto 0);
--=======
      dds_o       : out std_logic_vector(15 downto 0);
		note_valid_o : out std_logic);
  end component ADSR;
-->>>>>>> Stashed changes

signal sum_reg      : signed(N_AUDIO-1 downto 0);
 signal next_sum_reg : signed(N_AUDIO-1 downto 0);

begin  -- architecture str

  -----------------------------------------------------------------------------
  -- CONCURRENT ASSINGMENTS
  -----------------------------------------------------------------------------
  --note_valid_o <= note_valid;
  dds_l_o      <= std_logic_vector(sum_reg);
  dds_r_o      <= std_logic_vector(sum_reg);
  
  -----------------------------------------------------------------------------
  -- PROCESS FOR ALL FLIP-FLOPS
  -----------------------------------------------------------------------------
--<<<<<<< Updated upstream
--  flip_flops : process(all)
--  begin
--    if rst_n = '0' then
--      note_valid <= (others => '0');
--    elsif rising_edge(clk) then
--      note_valid <= next_note_valid;
--    end if;
--  end process flip_flops;
--  
--  -----------------------------------------------------------------------------
--  -- PROCESS FOR COMB-LOGIC 
--  -----------------------------------------------------------------------------
--  comb_logic : process (all)
--  begin
--    -- default statements (hold current value)
--    next_note_valid <= note_valid;
-- 
--    -- set next value for registers
--    next_note_valid <= tone_on_i;
--  end process comb_logic;
  
--=======
----  flip_flops : process(all)
----  begin
----    if rst_n = '0' then
----      note_valid <= (others => '0');
----    elsif rising_edge(clk) then
----      note_valid <= next_note_valid;
----    end if;
----  end process flip_flops;
----
----  -----------------------------------------------------------------------------
----  -- PROCESS FOR COMB-LOGIC 
----  -----------------------------------------------------------------------------
----  comb_logic : process (all)
----  begin
----    -- default statements (hold current value)
----    next_note_valid <= note_valid;
----
----    -- set next value for registers
----    next_note_valid <= tone_on_i;
----  end process comb_logic;
--
-->>>>>>> Stashed changes
  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------
  -- instance "dds_1"
  --dds_inst_gen : for i in 0 to 9 generate
  --  inst_dds : dds
  ADSR_inst_gen : for i in 0 to 9 generate
    inst_adsr : ADSR
      port map (
        clk         => clk,
        reset_n     => rst_n,
        phi_incr_i  => LUT_midi2dds(to_integer(unsigned(note_i(i)))),
        tone_on_i   => tone_on_i(i),
        velocity_i  => velocity_i(i),
        step_i      => step_i,
        vol_reg_i   => vol_reg_i,
        pitch_reg_i => pitch_reg_i,
        ctrl_reg_i  => ctrl_reg_i,
--<<<<<<< Updated upstream
--        dds_o       => dds_o_array(i));
--  end generate dds_inst_gen;
--=======
        dds_o       => dds_o_array(i),
		  note_valid_o => note_valid_o(i));
  end generate ADSR_inst_gen;
-->>>>>>> Stashed changes


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
