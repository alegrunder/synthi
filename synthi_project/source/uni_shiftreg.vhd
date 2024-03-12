-------------------------------------------------------------------------------
-- Title      : Universal Shift Register
-- Project    : PM2 Synthi
-------------------------------------------------------------------------------
-- File       : uni_shiftreg.vhd
-- Author     : heinipas
-- Company    : 
-- Created    : 2024-03-12
-- Last update: 2024-03-12
-- Platform   : 
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2024 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2024-03-12  1.0      heinipas        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity uni_shiftreg is

  generic (
    width : positive := 16);
  port(
    clk_6m  : in  std_logic;
    rst_n   : in  std_logic;
    par_in  : in  std_logic_vector(width-1 downto 0);
    load    : in  std_logic;
    ser_in  : in  std_logic;
    enable  : in  std_logic;
    ser_out : out std_logic;
    par_out : out std_logic_vector(width-1 downto 0));

end entity uni_shiftreg;

-------------------------------------------------------------------------------

architecture str of uni_shiftreg is

  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  signal shiftreg, next_shiftreg : std_logic_vector(width-1 downto 0);

begin  -- architecture str

  -----------------------------------------------------------------------------
  -- PROCESS FOR COMBINATORIAL LOGIC
  -----------------------------------------------------------------------------
  shift_comb : process(all)
  begin
    next_shiftreg <= shiftreg;
    if load = '1' then
      next_shiftreg <= par_in;          -- load value
    elsif enable = '1' then
      next_shiftreg <= shiftreg(width-2 downto 0) & ser_in;  -- shift direction towards MSB
    end if;
  end process shift_comb;

  -----------------------------------------------------------------------------
  -- PROCESS FOR REGISTERS
  -----------------------------------------------------------------------------
  shift_dffs : process(all)
  begin
    if rst_n = '0' then
      shiftreg <= (others => '0');
    elsif rising_edge(clk_6m) then      -- output should be with falling edge
                                        -- of BCLK
      shiftreg <= next_shiftreg;
    end if;
  end process shift_dffs;

  -----------------------------------------------------------------------------
  -- CONCURRENT ASSIGNMENTS
  -----------------------------------------------------------------------------
  -- take MSB of shiftreg as serial output
  ser_out <= shiftreg(width - 1);
  -- shiftreg to parallel_out
  par_out <= shiftreg;

end architecture str;

-------------------------------------------------------------------------------
