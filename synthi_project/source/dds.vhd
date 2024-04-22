-------------------------------------------------------------------------------
-- Title      : DDS
-- Project    : 
-------------------------------------------------------------------------------
-- File       : dds.vhd
-- Author     : doblesam
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
-- Date        Version  Author  Description
-- 2024-03-26  1.0      marku   Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.tone_gen_pkg.all;


entity dds is

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
    dds_o       : out std_logic_vector(15 downto 0)
    );
end dds;

architecture dds_arch of dds is

  signal count, next_count : unsigned(N_CUM-1 downto 0);

  constant AVERAGE_BUFFER : natural := 6;


begin  -- architecture dds_arch



  phase_counter_logic : process(all) is
    variable lut_val          : signed(N_AUDIO-1 downto 0);
    variable lut_val_sin      : signed(N_AUDIO-1+AVERAGE_BUFFER downto 0);
    variable lut_val_rec      : signed(N_AUDIO-1+AVERAGE_BUFFER downto 0);
    variable lut_val_saw      : signed(N_AUDIO-1+AVERAGE_BUFFER downto 0);
    variable lut_addr         : integer range 0 to L-1;
    variable atte             : integer range 0 to 15;
    variable Wavetable_switch : integer range 127 downto 0;
  begin


    lut_addr := to_integer(count(N_CUM-1 downto N_CUM - N_LUT));
    ----------------------------------------------------------------
    -- Wavetable
    ----------------------------------------------------------------

    -- Sinus
    lut_val_sin := to_signed(LUT(lut_addr), N_AUDIO+AVERAGE_BUFFER);

    -- Rectangle
    if lut_addr > 127 then
      lut_val_rec := to_signed(4095, N_AUDIO+AVERAGE_BUFFER);
    else
      lut_val_rec := to_signed(-4096, N_AUDIO+AVERAGE_BUFFER);
    end if;

    -- Sawtooth
    lut_val_saw := to_signed((lut_addr*32)-4095, N_AUDIO+AVERAGE_BUFFER);

    -- Switching logic
    -- if control = '1' then
    --  if control_reg1 = "0000111" then
    --          Wavetable_switch := to_integer(unsigned(attenu_i));
    --  end if;
    -- end if;

    Wavetable_switch := to_integer(unsigned(ctrl_reg_i));

    if Wavetable_switch < 64 then
      lut_val := shift_right((lut_val_sin * Wavetable_switch) + (lut_val_rec * (64-Wavetable_switch)), 6)(N_AUDIO-1 downto 0);
    else
      lut_val := shift_right((lut_val_saw * (Wavetable_switch -64)) + (lut_val_sin*(64-(Wavetable_switch -64))), 6)(N_AUDIO-1 downto 0);
    end if;


    -- Attenuation logic:
    --if control = '0' then
    --  atte := to_integer(unsigned(velocity_i(6 downto 3)));
    -- end if;
	 

    atte := to_integer(unsigned(velocity_i(6 downto 3)));

    case atte is
      when 0      => dds_o <= std_logic_vector(shift_right(lut_val, 15));
      when 1      => dds_o <= std_logic_vector(shift_right(lut_val, 14));
      when 2      => dds_o <= std_logic_vector(shift_right(lut_val, 13));
      when 3      => dds_o <= std_logic_vector(shift_right(lut_val, 12));
      when 4      => dds_o <= std_logic_vector(shift_right(lut_val, 11));
      when 5      => dds_o <= std_logic_vector(shift_right(lut_val, 10));
      when 6      => dds_o <= std_logic_vector(shift_right(lut_val, 9));
      when 7      => dds_o <= std_logic_vector(shift_right(lut_val, 8));
      when 8      => dds_o <= std_logic_vector(shift_right(lut_val, 7));
      when 9      => dds_o <= std_logic_vector(shift_right(lut_val, 6));
      when 10     => dds_o <= std_logic_vector(shift_right(lut_val, 5));
      when 11     => dds_o <= std_logic_vector(shift_right(lut_val, 4));
      when 12     => dds_o <= std_logic_vector(shift_right(lut_val, 3));
      when 13     => dds_o <= std_logic_vector(shift_right(lut_val, 2));
      when 14     => dds_o <= std_logic_vector(shift_right(lut_val, 1));
      when others => dds_o <= std_logic_vector(lut_val);
    end case;
	 
	 
	 dds_o <= std_logic_vector(shift_right(signed(lut_val)* to_signed(to_integer(unsigned(velocity_i)),8),7)(15 downto 0));
  end process phase_counter_logic;

  proc_input_comb : process (all) is
  begin  -- process proc_input_comb
    if (step_i = '1') then
      next_count <= count + unsigned(phi_incr_i);
    else
      next_count <= count;
    end if;

  end process proc_input_comb;

  flip_flops : process(all)
  begin
    if reset_n = '0' or tone_on_i = '0' then
      count <= to_unsigned(0, N_CUM);  -- convert integer value 0 to unsigned with 4bits

    elsif rising_edge(clk) then
      count <= next_count;
    end if;
  end process flip_flops;

end architecture dds_arch;
