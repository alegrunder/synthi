-------------------------------------------------------------------------------
-- Title      : fm block
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fm.vhd
-- Author     : heinipas
-- Company    : 
-- Created    : 2024-04-30
-- Last update: 2024-04-30
-- Platform   : 
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2024 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2024-04-30  1.0      heinipas        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.tone_gen_pkg.all;
use work.presets_pkg.all;

-------------------------------------------------------------------------------

entity fm is

  port (
    clk          : in  std_logic;
    reset_n      : in  std_logic;
    phi_incr_i   : in  std_logic_vector(18 downto 0);
    tone_on_i    : in  std_logic;
    velocity_i   : in  std_logic_vector(6 downto 0);
    step_i       : in  std_logic;
    pitch_reg_i  : in  std_logic_vector(6 downto 0);
    ctrl_reg_i   : in  std_logic_vector(6 downto 0);
    fm_attack_i  : in  t_fm_adsr;
    fm_decay_i   : in  t_fm_adsr;
    fm_sustain_i : in  t_fm_adsr;
    fm_release_i : in  t_fm_adsr;
    fm_amp_i     : in  t_fm_amp_frq;
    fm_freq_i    : in  t_fm_amp_frq;
    fm_mode_i    : in  std_logic_vector(1 downto 0);
    dds_o        : out std_logic_vector(15 downto 0);
    note_valid_o : out std_logic
    );

end entity fm;

-------------------------------------------------------------------------------

architecture str of fm is

  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  type t_phi_incr is array (0 to 2) of std_logic_vector(18 downto 0);

  signal phi_incr_sig        : t_phi_incr;
  signal tone_on_sig         : std_logic_vector(2 downto 0);
  signal velocity_adsr_sig   : t_fm_adsr;
  signal note_valid_adsr_sig : std_logic_vector(2 downto 0);

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component ADSR is
    port (
      clk               : in  std_logic;
      reset_n           : in  std_logic;
      phi_incr_i        : in  std_logic_vector(18 downto 0);
      tone_on_i         : in  std_logic;
      velocity_i        : in  std_logic_vector(6 downto 0);
      step_i            : in  std_logic;
      pitch_reg_i       : in  std_logic_vector(6 downto 0);
      ctrl_reg_i        : in  std_logic_vector(6 downto 0);
      attack_step_i     : in  unsigned(6 downto 0);
      decay_step_i      : in  unsigned(6 downto 0);
      release_step_i    : in  unsigned(6 downto 0);
      sustain_percent_i : in  unsigned(6 downto 0);
      dds_o             : out std_logic_vector(15 downto 0);
      note_valid_o      : out std_logic);
  end component ADSR;

begin  -- architecture str
  -----------------------------------------------------------------------------
  -- CONCURRENT ASSIGNMENTS
  -----------------------------------------------------------------------------
  note_valid_o <= note_valid_adsr_sig(0) or note_valid_adsr_sig(1) or note_valid_adsr_sig(2);
  phi_incr_sig(0)      <= phi_incr_i;
  phi_incr_sig(1)      <= phi_incr_i;
  phi_incr_sig(2)      <= phi_incr_i(18 downto 2) & "00";
  velocity_adsr_sig(0) <= unsigned(velocity_i);
  velocity_adsr_sig(1) <= unsigned(velocity_i);
  velocity_adsr_sig(2) <= unsigned(velocity_i);

  -----------------------------------------------------------------------------
  -- INSTANCES 
  -----------------------------------------------------------------------------
  ADSR_inst_gen : for i in 0 to 2 generate
    inst_adsr : ADSR
      port map (
        clk               => clk,
        reset_n           => reset_n,
        phi_incr_i        => phi_incr_sig(i),
        tone_on_i         => tone_on_sig(i),
        velocity_i        => std_logic_vector(velocity_adsr_sig(i)),
        step_i            => step_i,
        pitch_reg_i       => pitch_reg_i,
        ctrl_reg_i        => ctrl_reg_i,
        attack_step_i     => fm_attack_i(i),
        decay_step_i      => fm_decay_i(i),
        release_step_i    => fm_release_i(i),
        sustain_percent_i => fm_sustain_i(i),
        -- dds_o        => dds_o_array(i),
        note_valid_o      => note_valid_adsr_sig(i));
  end generate ADSR_inst_gen;


  -----------------------------------------------------------------------------
  -- PROCESS FOR COMB-LOGIC 
  -----------------------------------------------------------------------------
  comb_logic : process(all)
  begin
    -- default assigments
    tone_on_sig <= (others => tone_on_i);
    
    for i in 0 to 2 loop
      if (fm_amp_i(i) = 0) then
        tone_on_sig(i) <= '0';
      end if;
    end loop;
    
  end process comb_logic;

end architecture str;

-------------------------------------------------------------------------------
