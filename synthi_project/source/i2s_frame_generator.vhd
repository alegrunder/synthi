-------------------------------------------------------------------------------
-- Title      : I2S Frame Generator
-- Project    : PM2 Synthi
-------------------------------------------------------------------------------
-- File       : i2s_frame_generator.vhd
-- Author     : heinipas
-- Company    : 
-- Created    : 2024-03-12
-- Last update: 2024-03-12
-- Platform   : 
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: generates the signals for the shiftregs used in I2S master
-------------------------------------------------------------------------------
-- Copyright (c) 2024 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2024-03-12  1.0      heinipas        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity i2s_frame_generator is

  port (
    clk_6m  : in  std_logic;
    rst_n   : in  std_logic;
    load    : out std_logic;
    shift_l : out std_logic;
    shift_r : out std_logic;
    ws      : out std_logic);

end entity i2s_frame_generator;

-------------------------------------------------------------------------------

architecture str of i2s_frame_generator is

  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  constant width                       : positive := 7;  -- 0..127 is 7 bits
  signal bit_counter, next_bit_counter : unsigned(width-1 downto 0);

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

begin  -- architecture str

  --------------------------------------------------
  -- PROCESS FOR COMBINATORIAL LOGIC
  --------------------------------------------------
  comb_logic : process(all)
  begin
    -- increment counter
    next_bit_counter <= bit_counter + 1;

    -- output logic default assignments
    ws      <= '0';
    shift_l <= '0';
    shift_r <= '0';
    load    <= '0';

    -- condition for write select
    if bit_counter >= 64 then
      ws <= '1';
    end if;

    -- condition load, shift_l, shift_r
    case to_integer(bit_counter) is     -- must convert to integer for such conditions
      when 0 =>
        load <= '1';
      when 1 to 16 =>
        shift_l <= '1';
      when 65 to 80 =>
        shift_r <= '1';
      when others => null;
    end case;
  end process comb_logic;

  --------------------------------------------------
  -- PROCESS FOR REGISTERS
  --------------------------------------------------
  flip_flops : process(all)
  begin
    if rst_n = '0' then
      bit_counter <= to_unsigned(0, width);  -- convert integer value 0 to unsigned
    elsif rising_edge(clk_6m) then
      bit_counter <= next_bit_counter;
    end if;
  end process flip_flops;

end architecture str;

-------------------------------------------------------------------------------