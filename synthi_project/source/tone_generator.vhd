-------------------------------------------------------------------------------
-- Title      : Tone Generator
-- Project    : Synthi Pro
-------------------------------------------------------------------------------
-- File       : tone_generator.vhd
-- Author     : heinipas
-- Company    : 
-- Created    : 2024-03-26
-- Last update: 2024-05-31
-- Platform   : 
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Contains everything related to tone generation, receives notes
--              from midi_controller, sends dds_l/r_o to path_control
-------------------------------------------------------------------------------
-- Copyright (c) 2024 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2024-03-26  1.0      heinipas        Created
-- 2024-04-10  2.0      doblesam        implemented tone gen functions
-- 2024-04-16  2.1      grundale        added note valid feedack for midi ctrl
-- 2024-04-16  2.2      heinipas        added synchronous note valid feedback
-- 2024-04-20  3.0      doblesam        added low pass filter
-- 2024-05-01  4.0      heinipas        added presets, fm, lut_midi2incr
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.tone_gen_pkg.all;
use work.presets_pkg.all;

-------------------------------------------------------------------------------
entity tone_generator is
  port (
    clk               : in  std_logic;
    rst_n             : in  std_logic;
    step_i            : in  std_logic;  -- f_s
    note_i            : in  t_tone_array;  -- defined in tone_gen_pkg
    velocity_i        : in  t_tone_array;  -- defined in tone_gen_pkg
    tone_on_i         : in  std_logic_vector(9 downto 0);
    vol_reg_i         : in  std_logic_vector(6 downto 0);
    pitch_reg_i       : in  std_logic_vector(6 downto 0);
    ctrl_reg_i        : in  std_logic_vector(6 downto 0);  -- used for control commands
    low_pass_enable_i : in  std_logic;
    preset_sel_i      : in  std_logic_vector(2 downto 0);  -- select presets
    note_valid_o      : out std_logic_vector(9 downto 0);
    dds_l_o           : out std_logic_vector(15 downto 0);
    dds_r_o           : out std_logic_vector(15 downto 0)
    );

end entity tone_generator;

-------------------------------------------------------------------------------

architecture str of tone_generator is
  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  -- type definitions
  type t_dds_o_array is array (0 to 9) of std_logic_vector(N_AUDIO-1 downto 0);
  type t_phi_incr_array is array (0 to 9) of std_logic_vector(18 downto 0);
  signal dds_o_array    : t_dds_o_array;
  signal phi_incr_array : t_phi_incr_array;

  -- types defined in presets_pkg
  signal fm_attack, next_fm_attack   : t_fm_adsr;
  signal fm_decay, next_fm_decay     : t_fm_adsr;
  signal fm_sustain, next_fm_sustain : t_fm_adsr;
  signal fm_release, next_fm_release : t_fm_adsr;
  signal fm_freq, next_fm_freq       : t_fm_amp_frq;
  signal fm_amp, next_fm_amp         : t_fm_amp_frq;
  signal fm_mode, next_fm_mode       : std_logic_vector(1 downto 0);

  -- output sum and filter
  signal sum_reg            : signed(N_AUDIO-1 downto 0);
  signal next_sum_reg       : signed(N_AUDIO-1 downto 0);
  signal final_sum_reg      : signed(N_AUDIO-1 downto 0);
  signal next_final_sum_reg : signed(N_AUDIO-1 downto 0);
  signal filtered           : signed(N_AUDIO-1 downto 0);
  signal Volume_adj         : signed(N_AUDIO-1 downto 0);

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component fm is
    port (
      clk          : in  std_logic;
      reset_n      : in  std_logic;
      phi_incr_i   : in  std_logic_vector(18 downto 0);
      tone_on_i    : in  std_logic;
      velocity_i   : in  std_logic_vector(6 downto 0);
      step_i       : in  std_logic;
      pitch_reg_i  : in  std_logic_vector(6 downto 0);
      ctrl_reg_i   : in  std_logic_vector(6 downto 0);
      fm_attack_i  : in  t_fm_adsr;     -- types defined in presets_pkg
      fm_decay_i   : in  t_fm_adsr;     -- types defined in presets_pkg
      fm_sustain_i : in  t_fm_adsr;     -- types defined in presets_pkg
      fm_release_i : in  t_fm_adsr;     -- types defined in presets_pkg
      fm_amp_i     : in  t_fm_amp_frq;  -- types defined in presets_pkg
      fm_freq_i    : in  t_fm_amp_frq;  -- types defined in presets_pkg
      fm_mode_i    : in  std_logic_vector(1 downto 0);
      dds_o        : out std_logic_vector(15 downto 0);
      note_valid_o : out std_logic
      );
  end component fm;

  component lut_midi2incr is
    port (
      note_i     : in  std_logic_vector(6 downto 0);
      phi_incr_o : out std_logic_vector(18 downto 0));
  end component lut_midi2incr;

begin  -- architecture str
  -----------------------------------------------------------------------------
  -- CONCURRENT ASSINGMENTS
  -----------------------------------------------------------------------------
  Volume_adj <= shift_right(signed(filtered)*to_signed(to_integer(unsigned(vol_reg_i)), 8), 7)(N_AUDIO-1 downto 0);
  dds_l_o    <= std_logic_vector(Volume_adj);
  dds_r_o    <= std_logic_vector(Volume_adj);


  -----------------------------------------------------------------------------
  -- Instances
  -----------------------------------------------------------------------------
  -- generate 10 fm blocks
  fm_inst_gen : for i in 0 to 9 generate
    inst_fm : fm
      port map (
        clk          => clk,
        reset_n      => rst_n,
        phi_incr_i   => phi_incr_array(i),
        tone_on_i    => tone_on_i(i),
        velocity_i   => velocity_i(i),
        step_i       => step_i,
        pitch_reg_i  => pitch_reg_i,
        ctrl_reg_i   => ctrl_reg_i,
        fm_attack_i  => fm_attack,
        fm_decay_i   => fm_decay,
        fm_sustain_i => fm_sustain,
        fm_release_i => fm_release,
        fm_freq_i    => fm_freq,
        fm_amp_i     => fm_amp,
        fm_mode_i    => fm_mode,
        dds_o        => dds_o_array(i),
        note_valid_o => note_valid_o(i));
  end generate fm_inst_gen;

  -- generate 10 lut_midi2incr blocks
  lut_midi2incr_inst_gen : for i in 0 to 9 generate
    inst_lut_midi2incr : lut_midi2incr
      port map (
        note_i     => note_i(i),
        phi_incr_o => phi_incr_array(i));
  end generate lut_midi2incr_inst_gen;

  -----------------------------------------------------------------------------
  -- PROCESS FOR PRESET COMB-LOGIC 
  -----------------------------------------------------------------------------
  preset_select : process(all)
    variable idx : natural;
  begin
    -- set presets from presets_pkg
    idx             := to_integer(unsigned(preset_sel_i));
    next_fm_attack  <= FM_ATTACK_PRESET(idx);
    next_fm_decay   <= FM_DECAY_PRESET(idx);
    next_fm_sustain <= FM_SUSTAIN_PRESET(idx);
    next_fm_release <= FM_RELEASE_PRESET(idx);
    next_fm_freq    <= FM_FREQ_PRESET(idx);
    next_fm_amp     <= FM_AMP_PRESET(idx);
    next_fm_mode    <= FM_MODE_PRESET(idx);
  end process preset_select;

  -----------------------------------------------------------------------------
  -- PROCESS FOR OUTPUT COMB-LOGIC 
  -----------------------------------------------------------------------------
  sum_output : process(all)
    variable var_sum : signed(N_AUDIO-1 downto 0);
  begin
    var_sum := (others => '0');
    if step_i = '1' then
      dds_sum_loop : for i in 0 to 9 loop
        var_sum := var_sum + signed(dds_o_array(i));
      end loop dds_sum_loop;

      next_final_sum_reg <= shift_right(sum_reg + final_sum_reg*31, 5)(N_AUDIO-1 downto 0);
      next_sum_reg       <= var_sum;
    else
      next_final_sum_reg <= final_sum_reg;
      next_sum_reg       <= sum_reg;
    end if;
  end process sum_output;

  -----------------------------------------------------------------------------
  -- PROCESS FOR FLIP-FLOPS
  -----------------------------------------------------------------------------
  reg_sum_output : process(clk, rst_n)
  begin
    if rst_n = '0' then
      sum_reg       <= (others => '0');
      final_sum_reg <= (others => '0');
      fm_attack     <= FM_ATTACK_PRESET(0);
      fm_decay      <= FM_DECAY_PRESET(0);
      fm_sustain    <= FM_SUSTAIN_PRESET(0);
      fm_release    <= FM_RELEASE_PRESET(0);
      fm_freq       <= FM_FREQ_PRESET(0);
      fm_amp        <= FM_AMP_PRESET(0);
      fm_mode       <= FM_MODE_PRESET(0);
    elsif rising_edge(clk) then
      sum_reg       <= next_sum_reg;
      final_sum_reg <= next_final_sum_reg;
      fm_attack     <= next_fm_attack;
      fm_decay      <= next_fm_decay;
      fm_sustain    <= next_fm_sustain;
      fm_release    <= next_fm_release;
      fm_freq       <= next_fm_freq;
      fm_amp        <= next_fm_amp;
      fm_mode       <= next_fm_mode;
      if low_pass_enable_i = '1' then
        filtered <= final_sum_reg + final_sum_reg;
      else
        filtered <= sum_reg(N_AUDIO-1 downto 0);
      end if;

    end if;
  end process reg_sum_output;

end architecture str;

-------------------------------------------------------------------------------
