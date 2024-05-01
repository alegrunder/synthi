-------------------------------------------------------------------------------
-- Title      : presets_pkg
-- Project    : Synthi
-------------------------------------------------------------------------------
-- File       : presets_pkg.vhd
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

-------------------------------------------------------------------------------
-- Package  Declaration
-------------------------------------------------------------------------------
package presets_pkg is
  type t_fm_adsr is array (0 to 2) of unsigned(6 downto 0);
  type t_fm_amp_frq is array (0 to 2) of unsigned(3 downto 0);
  type t_fm_adsr_preset is array (0 to 7) of t_fm_adsr;
  type t_fm_amp_frq_preset is array (0 to 7) of t_fm_amp_frq;
  type t_fm_mode is array (0 to 7) of std_logic_vector(1 downto 0);
  
  -------------------------------------------------------------------------------
  -- PRESET CONSTANTS (INIT FUNCTIONS SEE BELOW)
  -------------------------------------------------------------------------------
  function attack_preset_init return t_fm_adsr_preset;
  constant FM_ATTACK_PRESET : t_fm_adsr_preset;
  
  function decay_preset_init return t_fm_adsr_preset;
  constant FM_DECAY_PRESET : t_fm_adsr_preset;
  
  function sustain_preset_init return t_fm_adsr_preset;
  constant FM_SUSTAIN_PRESET : t_fm_adsr_preset;
  
  function release_preset_init return t_fm_adsr_preset;
  constant FM_RELEASE_PRESET : t_fm_adsr_preset;
  
  function freq_preset_init return t_fm_amp_frq_preset;
  constant FM_FREQ_PRESET : t_fm_amp_frq_preset;
  
  function amp_preset_init return t_fm_amp_frq_preset;
  constant FM_AMP_PRESET : t_fm_amp_frq_preset;
  
  function mode_preset_init return t_fm_mode;
  constant FM_MODE_PRESET : t_fm_mode;
  
end package presets_pkg;

-------------------------------------------------------------------------------
-- Package  Body
-------------------------------------------------------------------------------
package body presets_pkg is
  -------------------------------------------------------------------------------
  -- ATTACK
  -------------------------------------------------------------------------------
  function attack_preset_init return t_fm_adsr_preset is
    variable temp : t_fm_adsr_preset;
  begin
    -- default values
    for i in 0 to 7 loop
      for j in 0 to 2 loop
          temp(i)(j) := to_unsigned(100, 7);  -- 100
      end loop;
    end loop;
    -- preset 0
    -- preset 1
    -- preset 2
    -- preset 3
    -- preset 4
    -- preset 5
    -- preset 6
    -- preset 7
    return temp;
  end function attack_preset_init;
  
  constant FM_ATTACK_PRESET : t_fm_adsr_preset := attack_preset_init;
  
  -------------------------------------------------------------------------------
  -- DECAY
  -------------------------------------------------------------------------------
  function decay_preset_init return t_fm_adsr_preset is
    variable temp : t_fm_adsr_preset;
  begin
    -- default values
    for i in 0 to 7 loop
      for j in 0 to 2 loop
          temp(i)(j) := to_unsigned(8, 7);
      end loop;
    end loop;
    -- preset 0
    -- preset 1
    -- preset 2
    -- preset 3
    -- preset 4
    -- preset 5
    -- preset 6
    -- preset 7
    return temp;
  end function decay_preset_init;
  
  constant FM_DECAY_PRESET : t_fm_adsr_preset := decay_preset_init;
  
  -------------------------------------------------------------------------------
  -- SUSTAIN
  -------------------------------------------------------------------------------
  function sustain_preset_init return t_fm_adsr_preset is
    variable temp : t_fm_adsr_preset;
  begin
    -- default values
    for i in 0 to 7 loop
      for j in 0 to 2 loop
          temp(i)(j) := to_unsigned(50, 7);
      end loop;
    end loop;
    -- preset 0
    -- preset 1
    temp(1)(0) := to_unsigned(65, 7);
    temp(1)(1) := to_unsigned(70, 7);
    temp(1)(2) := to_unsigned(50, 7);
    -- preset 2
    -- preset 3
    -- preset 4
    -- preset 5
    -- preset 6
    -- preset 7
    return temp;
  end function sustain_preset_init;
  
  constant FM_SUSTAIN_PRESET : t_fm_adsr_preset := sustain_preset_init;

  -------------------------------------------------------------------------------
  -- RELEASE
  -------------------------------------------------------------------------------
  function release_preset_init return t_fm_adsr_preset is
    variable temp : t_fm_adsr_preset;
  begin
    -- default values
    for i in 0 to 7 loop
      for j in 0 to 2 loop
          temp(i)(j) := to_unsigned(8, 7);
      end loop;
    end loop;
    -- preset 0
    -- preset 1
    -- preset 2
    -- preset 3
    -- preset 4
    -- preset 5
    -- preset 6
    -- preset 7
    return temp;
  end function release_preset_init;
  
  constant FM_RELEASE_PRESET : t_fm_adsr_preset := release_preset_init;

  -------------------------------------------------------------------------------
  -- FREQ
  -------------------------------------------------------------------------------
  function freq_preset_init return t_fm_amp_frq_preset is
    variable temp : t_fm_amp_frq_preset;
  begin
    -- freq = (value + 1) / 2 * base frequency
    -- 0.5 ... 8 * base frequency
    
    -- default values
    for i in 0 to 7 loop
      temp(i)(0) := to_unsigned(1,4);  -- 1 is base frequency
      temp(i)(1) := to_unsigned(15,4);  -- 3 * base
      temp(i)(2) := to_unsigned(15,4);  -- 5 * base
    end loop;
    -- preset 0
    -- preset 1
    temp(1)(0) := to_unsigned(1,4);  -- 1 is base frequency
    temp(1)(1) := to_unsigned(1,4);  -- 4 * base
    temp(1)(2) := to_unsigned(5,4);  -- 0.5 * base
    -- preset 2
    -- preset 3
    -- preset 4
    -- preset 5
    -- preset 6
    -- preset 7
    return temp;
  end function freq_preset_init;
  
  constant FM_FREQ_PRESET : t_fm_amp_frq_preset := freq_preset_init;

  -------------------------------------------------------------------------------
  -- AMP
  -------------------------------------------------------------------------------
  function amp_preset_init return t_fm_amp_frq_preset is
    variable temp : t_fm_amp_frq_preset;
  begin
    -- default values
    for i in 0 to 7 loop
      temp(i)(0) := to_unsigned(15,4);  -- 15 is max. amplitude
      temp(i)(1) := to_unsigned(12,4);
      temp(i)(2) := to_unsigned(9,4); 
    end loop;
    -- preset 0
    -- preset 1
    temp(1)(0) := to_unsigned(15,4);  -- 15 is max. amplitude
    temp(1)(1) := to_unsigned(15,4);
    temp(1)(2) := to_unsigned(10,4); 
    -- preset 2
    -- preset 3
    -- preset 4
    -- preset 5
    -- preset 6
    -- preset 7
    return temp;
  end function amp_preset_init;
  
  constant FM_AMP_PRESET : t_fm_amp_frq_preset := amp_preset_init;
  
  -------------------------------------------------------------------------------
  -- FM MODE
  -------------------------------------------------------------------------------
  function mode_preset_init return t_fm_mode is
    variable temp : t_fm_mode;
  begin
    -- default values
    for i in 0 to 7 loop
      temp(i) := "00";
    end loop;
    -- preset 0
    -- preset 1
    temp(1) := "01";
    -- preset 2
    temp(2) := "10";
    -- preset 3
    temp(3) := "11";
    -- preset 4
    -- preset 5
    -- preset 6
    -- preset 7
    return temp;
  end function mode_preset_init;
  
  constant FM_MODE_PRESET : t_fm_mode := mode_preset_init;

end package body presets_pkg;