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
          temp(i)(j) := to_unsigned(50, 7);  -- 100
      end loop;
    end loop;
    -- preset 0 - basic sound
    -- preset 1
    -- preset 2 - organ
    temp(2)(0) := to_unsigned(100, 7); 
    temp(2)(1) := to_unsigned(100, 7); 
    temp(2)(2) := to_unsigned(80 , 7); 
    -- preset 3 - brass
    temp(3)(0) := to_unsigned(100, 7); 
    temp(3)(1) := to_unsigned(40, 7);
    temp(3)(2) := to_unsigned(100, 7); 
    -- preset 4 - bell
    temp(4)(0) := to_unsigned(127, 7); 
    temp(4)(1) := to_unsigned(127, 7); 
    temp(4)(2) := to_unsigned(127, 7); 
    -- preset 5 - guitar
    temp(5)(0) := to_unsigned(127, 7); 
    temp(5)(1) := to_unsigned(127, 7); 
    temp(5)(2) := to_unsigned(127, 7); 
    -- preset 6 - ghost
    temp(6)(0) := to_unsigned(80, 7); 
    temp(6)(1) := to_unsigned(60, 7); 
    temp(6)(2) := to_unsigned(70, 7); 
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
          temp(i)(j) := to_unsigned(50, 7);
      end loop;
    end loop;
    -- preset 0 - basic sound
    -- preset 1
    -- preset 2 - organ
      -- not relevant, as sustain is 100%
    -- preset 3 - brass
    temp(3)(2) := to_unsigned(20, 7);
    -- preset 4 - bell
    temp(4)(0) := to_unsigned(30, 7);
    temp(4)(1) := to_unsigned(10, 7);
    temp(4)(2) := to_unsigned(30, 7);
    -- preset 5 - guitar
    temp(5)(0) := to_unsigned(50, 7);
    temp(5)(1) := to_unsigned(10, 7);
    temp(5)(2) := to_unsigned(100, 7);
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
    -- preset 0 - basic sound
    -- preset 1
    temp(1)(0) := to_unsigned(65, 7);
    temp(1)(1) := to_unsigned(70, 7);
    temp(1)(2) := to_unsigned(50, 7);
    -- preset 2 - organ
    temp(2)(0) := to_unsigned(100, 7);
    temp(2)(1) := to_unsigned(100, 7);
    temp(2)(2) := to_unsigned(100, 7);
    -- preset 3 - brass
    temp(3)(0) := to_unsigned(75, 7);
    temp(3)(1) := to_unsigned(100, 7);
    temp(3)(2) := to_unsigned(65, 7);
    -- preset 4
    temp(4)(0) := to_unsigned(1, 7);
    temp(4)(1) := to_unsigned(1, 7);
    temp(4)(2) := to_unsigned(1, 7);
    -- preset 5 - guitar
    temp(5)(0) := to_unsigned(1, 7);
    temp(5)(1) := to_unsigned(80, 7);
    temp(5)(2) := to_unsigned(40, 7);
    -- preset 6 - ghost
    temp(6)(0) := to_unsigned(99, 7); 
    temp(6)(1) := to_unsigned(99, 7); 
    temp(6)(2) := to_unsigned(99, 7); 
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
          temp(i)(j) := to_unsigned(50, 7);
      end loop;
    end loop;
    -- preset 0 - basic sound
    temp(0)(0) := to_unsigned(50, 7);
    -- preset 1
    -- preset 2
    -- preset 3 - brass
    temp(3)(0) := to_unsigned(80, 7);
    temp(3)(1) := to_unsigned(80, 7);
    temp(3)(2) := to_unsigned(80, 7);
    -- preset 4 - bell
    temp(4)(0) := to_unsigned(60, 7);
    temp(4)(1) := to_unsigned(20, 7);
    temp(4)(2) := to_unsigned(60, 7);
    -- preset 5 - guitar
    temp(5)(0) := to_unsigned(60, 7);
    temp(5)(1) := to_unsigned(50, 7);
    temp(5)(2) := to_unsigned(30, 7);
    -- preset 6 - ghost
    temp(6)(0) := to_unsigned(60, 7); 
    temp(6)(1) := to_unsigned(60, 7); 
    temp(6)(2) := to_unsigned(30, 7); 
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
      temp(i)(1) := to_unsigned(5,4);  -- 3 * base
      temp(i)(2) := to_unsigned(9,4);  -- 5 * base
    end loop;
    -- preset 0 - basic sound
    -- preset 1 
    temp(1)(0) := to_unsigned(1,4);  -- 1 is base frequency
    temp(1)(1) := to_unsigned(1,4);  -- 4 * base
    temp(1)(2) := to_unsigned(0,4);  -- 0.5 * base
    -- preset 2 - organ
    temp(2)(0) := to_unsigned(0,4);  -- 0.5 * base
    temp(2)(1) := to_unsigned(3,4);  -- 2 * base
    temp(2)(2) := to_unsigned(1,4);  -- 1 * base
    -- preset 3 - brass
    temp(3)(0) := to_unsigned(1,4);
    temp(3)(1) := to_unsigned(2,4);  -- 1.5 * base
    temp(3)(2) := to_unsigned(0,4);  -- 0.5 * base
    -- preset 4 - bell
    temp(4)(0) := to_unsigned(1,4);
    temp(4)(1) := to_unsigned(6,4);  -- 3.5 * base
    temp(4)(2) := to_unsigned(1,4);
    -- preset 5 - guitar
    temp(5)(0) := to_unsigned(1,4);  -- 1 * base
    temp(5)(1) := to_unsigned(2,4);  -- 1.5 * base
    temp(5)(2) := to_unsigned(6,4);  -- 3.5 * base
    -- preset 6 - ghost
    temp(6)(0) := to_unsigned(1, 4); 
    temp(6)(1) := to_unsigned(1, 4); 
    temp(6)(2) := to_unsigned(4, 4); -- 2.5 * base
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
    -- preset 0 - basic sound
    temp(0)(1) := to_unsigned(0,4);     -- no overtone
    temp(0)(2) := to_unsigned(0,4);     -- no overtone
    -- preset 1
    temp(1)(0) := to_unsigned(15,4);    -- 15 is max. amplitude
    temp(1)(1) := to_unsigned(8,4);
    temp(1)(2) := to_unsigned(8,4); 
    -- preset 2 - organ
    temp(2)(0) := to_unsigned(7,4);    -- 15 is max. amplitude
    temp(2)(1) := to_unsigned(7,4);
    temp(2)(2) := to_unsigned(7,4); 
    -- preset 3 - brass
    temp(3)(0) := to_unsigned(14,4);    -- 15 is max. amplitude
    temp(3)(1) := to_unsigned(12,4);
    temp(3)(2) := to_unsigned(12,4); 
    -- preset 4 - bell
    temp(4)(0) := to_unsigned(15,4);
    temp(4)(1) := to_unsigned(11,4);
    temp(4)(2) := to_unsigned(9,4); 
    -- preset 5 - guitar
    temp(5)(0) := to_unsigned(15,4);
    temp(5)(1) := to_unsigned(4,4);
    temp(5)(2) := to_unsigned(8,4); 
    -- preset 6 - ghost
    temp(6)(0) := to_unsigned(15, 4); 
    temp(6)(1) := to_unsigned(4, 4); 
    temp(6)(2) := to_unsigned(11, 4); -- 2.5 * base
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
    -- default values
    for i in 0 to 7 loop
      temp(i) := "00";
    end loop;
    -- preset 0
    temp(0) := "00";    -- no modulation
    -- preset 1
    temp(1) := "11";
    -- preset 2 - organ
    temp(2) := "00";
    -- preset 3 - brass
    temp(3) := "01";
    -- preset 4 - bell
    temp(4) := "10";
    -- preset 5 - guitar
    temp(5) := "01";
    -- preset 6 - ghost
    temp(6) := "11";
    -- preset 7
    return temp;
  end function mode_preset_init;
  
  constant FM_MODE_PRESET : t_fm_mode := mode_preset_init;

end package body presets_pkg;