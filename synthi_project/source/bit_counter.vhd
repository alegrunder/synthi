--
-- Project     : DT Miniprojekt
--
-- File Name   : bit_counter.vhd
-- Description : counts number of received bits  
--
--------------------------------------------------------------------
-- Change History
-- Date     |Name      |Modification
------------|----------|--------------------------------------------
-- 28.11.23 | grundale | file created
-- 05.12.23 | heinipas | make start_pulse synchronous 
--------------------------------------------------------------------
 
-- Library & Use Statements
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
-- Entity Declaration
entity bit_counter is
  port(
    clk           : in  std_logic;                      -- Input of entity
    reset_n       : in  std_logic;                      -- Input of entity
    baud_tick     : in  std_logic;                      -- Input of entity
    start_pulse   : in  std_logic;                      -- Input of entity
    bit_count     : out std_logic_vector(3 downto 0));  -- Outputs of entity
end bit_counter;
 
-- Architecture Declaration
architecture rtl of bit_counter is
  -- Signals & Constants Declaration
  constant count_width : positive := 4;  
  signal count, next_count : unsigned(count_width-1 downto 0);
 
-- Begin Architecture
begin
  -------------------------------------------
  -- Process for combinatorial logic
  -------------------------------------------
  comb_logic : process(all)
  begin
    if start_pulse = '1' then
      next_count <= to_unsigned(0, count_width);
    elsif (count < 9) and baud_tick = '1' then
      next_count <= count + 1;
    else
      next_count <= count;
    end if;
  end process comb_logic;
 
 
  -------------------------------------------
  -- Process for registers (flip-flops)
  -------------------------------------------
  flip_flops : process(all)
  begin
    if reset_n = '0' then
      count <= to_unsigned(0, count_width);  -- convert integer value 0 to unsigned with 4bits
    elsif rising_edge(clk) then
      count <= next_count;
    end if;
  end process flip_flops;
 
  -------------------------------------------
  -- Concurrent Assignements  
  -- e.g. Assign outputs from intermediate signals
  -------------------------------------------
  -- convert count from unsigned to std_logic (output data-type)
  bit_count <= std_logic_vector(count);
 
-- End Architecture
end rtl;