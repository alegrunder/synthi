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
  type t_dds_o_array is array (0 to 9) of std_logic_vector(N_AUDIO-1 downto 0);

  signal phi_incr_sig        : t_phi_incr;
  signal tone_on_sig         : std_logic_vector(2 downto 0);
  signal velocity_adsr_sig   : t_fm_adsr;
  signal note_valid_adsr_sig : std_logic_vector(2 downto 0);

  signal dds_o_array  : t_dds_o_array;

  signal sum_sig      : signed(N_AUDIO-1 downto 0);
  
  -- feedback factor of modulation output to phi_incr of carrier
  -- constant MOD_INTENS : integer := 10;  -- 0 to 10, 10 for control by presets
  
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
  dds_o <= std_logic_vector(sum_sig);

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
        dds_o             => dds_o_array(i),
        note_valid_o      => note_valid_adsr_sig(i));
  end generate ADSR_inst_gen;


  -----------------------------------------------------------------------------
  -- PROCESS FOR COMB-LOGIC 
  -----------------------------------------------------------------------------
  comb_logic : process(all)
    -- one bit more than phi_incr_i
    type t_signed_incr is array (0 to 2) of integer;
    variable var_incr : t_signed_incr;
    variable var_out  : signed(N_AUDIO-1 downto 0);
    variable var_vel  : integer;
    variable var_mod  : integer;
  begin
    -- DEFAULT ASSIGNMENTS
    
    -- TONE_ON_SIG
    tone_on_sig <= (others => tone_on_i);
    for i in 0 to 2 loop
      -- switch off all tones, where fm_amp is 0
      if (fm_amp_i(i) = 0) then
        tone_on_sig(i) <= '0';
      end if;
    end loop;
    
    -- AMPLITUDES
    for i in 0 to 2 loop
    -- fm_amp_i(i) is 4 bits
      -- velocity_adsr_sig(i) <= "1000000";
      --var_vel := (127 * 12 + 1) / 15;
      var_vel := to_integer(unsigned(velocity_i)) * (to_integer(fm_amp_i(i))+1) / 16;
      velocity_adsr_sig(i) <= to_unsigned(var_vel, velocity_adsr_sig(i)'length);
    end loop;
    
    -- INPUT AND OUTPUT SUMS
    -- MODE 0 --------------------------
    --          [1] [2] [3]
    --           \   |   /
    --             [out]
    -- MODE 1 --------------------------
    --              [3]
    --               |
    --              [2]
    --               | 
    --              [1]
    --               |
    --             [out]
    -- MODE 2 --------------------------
    --            [2]
    --             | 
    --            [1] [3]
    --             \   /
    --             [out]
    -- MODE 3 --------------------------
    --            [2] [3]
    --             \   /
    --              [1]
    --               |
    --             [out]
    var_out := (others => '0');
    -- calculate increments depending on fm_amp_i(i)
    -- fm_freq_i(i) is 4 bits
    -- freq = (fm_freq_i(i) + 1) / 2 * base frequency
    -- fm_freq_i(i) = 0 => 0.5 * base freq
    -- fm_freq_i(i) = 1 => 1 * base freq
    -- fm_freq_i(i) = 5 => 3 * base freq
    for i in 0 to 2 loop
      var_incr(i) := to_integer(signed(phi_incr_i)) * (to_integer(fm_freq_i(i)) + 1) / 2;
    end loop;
    
    case fm_mode_i is
      when "00" =>
        -- no change to increments
        var_out := signed(dds_o_array(0)) + signed(dds_o_array(1)) + signed(dds_o_array(2));
      when "01" =>
        -- mod 3 on 2
        -- scale to input of 3
        var_mod := var_incr(2) * to_integer(signed(dds_o_array(2))) / 4096;
        var_incr(1) := var_incr(1) + var_mod;
        -- mod 2 on 1
        -- scale to input of 2
        var_mod := var_incr(1) * to_integer(signed(dds_o_array(1))) / 4096;
        var_incr(0) := var_incr(0) + var_mod;
        var_out := signed(dds_o_array(0));                                -- 1 on output
      when "10" =>
        -- mod 2 on 1
        var_mod := var_incr(1) * to_integer(signed(dds_o_array(1))) / 4096;
        var_incr(0) := var_incr(0) + var_mod;
        var_out := signed(dds_o_array(0)) + signed(dds_o_array(2));       -- 1 + 3 on otput
      when others =>
        -- mod (2+3) on 1
        var_mod := (var_incr(1) * to_integer(signed(dds_o_array(1))) + var_incr(2) * to_integer(signed(dds_o_array(2)))) / 4096;
        var_incr(0) := var_incr(0) + var_mod;
        var_out := signed(dds_o_array(0));                                -- 1 on output
    end case;
    -- assign variables to signals
    for i in 0 to 2 loop
      --if (var_incr(i) < 0) then
      --  phi_incr_sig(i) <= std_logic_vector(to_unsigned(1,19));
      --else
      --  phi_incr_sig(i) <= std_logic_vector(to_unsigned(var_incr(i),19));
      --end if;
      phi_incr_sig(i) <= std_logic_vector(to_signed(var_incr(i),19));
    end loop;
    sum_sig       <= var_out;
  end process comb_logic;
end architecture str;

-------------------------------------------------------------------------------
