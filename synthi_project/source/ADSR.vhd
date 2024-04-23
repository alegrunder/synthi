-------------------------------------------------------------------------------
-- Title      : ADSR
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ADSR.vhd
-- Author     :   <marku@LAPTOP-RDI11CTJ>
-- Company    : 
-- Created    : 2024-04-16
-- Last update: 2024-04-23
-- Platform   : 
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2024 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2024-04-16  1.0      marku   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.tone_gen_pkg.all;

entity ADSR is

  port (
    clk          : in  std_logic;
    reset_n      : in  std_logic;
    phi_incr_i   : in  std_logic_vector(18 downto 0);
    tone_on_i    : in  std_logic;
    velocity_i   : in  std_logic_vector(6 downto 0);
    step_i       : in  std_logic;
    vol_reg_i    : in  std_logic_vector(6 downto 0);
    pitch_reg_i  : in  std_logic_vector(6 downto 0);
    ctrl_reg_i   : in  std_logic_vector(6 downto 0);
    dds_o        : out std_logic_vector(15 downto 0);
    note_valid_o : out std_logic
    );
end ADSR;

architecture ADSR_arch of ADSR is

  -------------------------------------------------------------------------------
  -- Type Declaration
  -------------------------------------------------------------------------------
  type t_fsm_states is (
    S_IDLE,
    S_ATTACK,
    S_DECAY,
    S_SUSTAIN,
    S_RELEASE
    );

  -------------------------------------------------------------------------------
  -- Signal Declaration
  -------------------------------------------------------------------------------
  -- Current and Next Register State
  signal fsm_state, next_fsm_state   : t_fsm_states;
  signal volume, next_volume         : signed(16 downto 0);
  signal note_valid, next_note_valid : std_logic;
  signal velocity                    : std_logic_vector(6 downto 0);
  signal vel                         : integer range 0 to 127;

  constant FREQ_DIVISION         : natural := 4;
  signal freq_div, next_freq_div : integer range 0 to FREQ_DIVISION;

  constant ATTACK_STEP  : natural := 1000;
  constant DECAY_STEP   : natural := 80;
  constant RELEASE_STEP : natural := 20;

  constant SUSTAIN_LEVEL_PROZENT : natural := 10;  -- max 100

  constant SUSTAIN_LEVEL : natural := SUSTAIN_LEVEL_PROZENT*655;  -- DO NOT CHANGE

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component dds is
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
      dds_o       : out std_logic_vector(15 downto 0));
  end component dds;

begin  -- architecture ADSR_arch

  inst_dds : dds
    port map (
      clk         => clk,
      reset_n     => reset_n,
      phi_incr_i  => phi_incr_i,
      tone_on_i   => note_valid,        --tone_on_i,
      velocity_i  => velocity,
      step_i      => step_i,
      vol_reg_i   => vol_reg_i,
      pitch_reg_i => pitch_reg_i,
      ctrl_reg_i  => ctrl_reg_i,
      dds_o       => dds_o);


  -------------------------------------------------------------------------------
  -- Process for combinational logic
  -------------------------------------------------------------------------------
  logic_proc : process(all)
  begin
    -----------------------------------------------------------------------
    -- Default Statement, mostly keep current value
    -----------------------------------------------------------------------
    next_fsm_state <= fsm_state;
    next_volume     <= volume;
    next_note_valid <= note_valid;
    next_freq_div   <= freq_div;

    if (freq_div < FREQ_DIVISION) then
      next_freq_div <= freq_div + 1;
    end if;

    -----------------------------------------------------------------------
    -- State Machine
    -----------------------------------------------------------------------
    case fsm_state is
      --------------------------------------------------------------------
      when S_IDLE =>
        --------------------------------------------------------------------
        next_volume <= to_signed(0, 17);
        if (tone_on_i = '1') then
          next_fsm_state <= S_ATTACK;
        end if;

      --------------------------------------------------------------------
      when S_ATTACK =>
        --------------------------------------------------------------------
        next_note_valid <= '1';
        if (tone_on_i = '0') then
          next_fsm_state <= S_RELEASE;
        elsif (volume < 0) then
          next_volume    <= to_signed(65535, 17);
          next_fsm_state <= S_DECAY;
        else
          next_volume <= volume + ATTACK_STEP;
        end if;

      --------------------------------------------------------------------
      when S_DECAY =>
        --------------------------------------------------------------------
        if (tone_on_i = '0') then
          next_fsm_state <= S_RELEASE;
        elsif (volume < SUSTAIN_LEVEL) and (volume > 0) then
          next_fsm_state <= S_SUSTAIN;
        else
          next_volume <= volume - DECAY_STEP;
        end if;

      --------------------------------------------------------------------
      when S_SUSTAIN =>
        --------------------------------------------------------------------
        next_volume <= volume;
        if (tone_on_i = '0') then
          next_fsm_state <= S_RELEASE;
        end if;
      --------------------------------------------------------------------
      when S_RELEASE =>
        --------------------------------------------------------------------
        next_volume <= volume - RELEASE_STEP;
        if (tone_on_i = '1') then
          next_fsm_state <= S_ATTACK;
        elsif (volume < 0) then         --check on overflow
          next_fsm_state  <= S_IDLE;
          next_note_valid <= '0';
        end if;

    end case;
  end process;  -- comb logic

  -----------------------------------------------------------------------------
  -- CONCURRENT ASSINGMENTS
  -----------------------------------------------------------------------------
  note_valid_o <= note_valid;
  vel      <= to_integer(shift_right(unsigned(abs(volume)), 9));
  velocity <= std_logic_vector(shift_right(to_unsigned(vel, 7) * unsigned(velocity_i), 7)(6 downto 0));

  -----------------------------------------------------------------------------
  -- PROCESS FOR ALL FLIP-FLOPS
  -----------------------------------------------------------------------------
  flip_flops : process(all)
  begin
    if reset_n = '0' then
      note_valid <= '0';
      fsm_state  <= S_IDLE;
      freq_div   <= 0;
      volume     <= to_signed(0, 17);
    elsif rising_edge(clk) then
      fsm_state  <= next_fsm_state;
      note_valid <= next_note_valid;
      if step_i = '1' then
        freq_div <= next_freq_div;
      end if;
      if (freq_div = FREQ_DIVISION) then
        freq_div <= 0;
        volume   <= next_volume;
      end if;
    end if;
  end process flip_flops;
end architecture ADSR_arch;
