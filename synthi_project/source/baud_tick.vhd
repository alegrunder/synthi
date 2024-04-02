--
-- Project     : DT Miniprojekt
--
-- File Name   : baud_tick.vhd
-- Description : generates a sample signal for uart receiver   
--
--------------------------------------------------------------------
-- Change History
-- Date     |Name      |Modification
------------|----------|--------------------------------------------
-- 28.11.23 | grundale | file created and functionality implemented
--------------------------------------------------------------------

-- Library & Use Statements
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity Declaration 
entity baud_tick is
  port(
    clk           : in  std_logic;  -- Input of entity
    reset_n       : in  std_logic;  -- Input of entity
    start_pulse   : in  std_logic;  -- Input of entity
    baud_rate_i   : in  positive;  -- Input for baud rate
    tick          : out std_logic   -- Output of entity
  );
end baud_tick;

-- Architecture Declaration
architecture rtl of baud_tick is

  -- Signals & Constants Declaration 
  constant clock_freq  : positive := 6_250_000;  -- Clock in Hz
  constant baud_rate   : positive :=   115_200;  -- Baudrate
  constant count_width : positive :=         8;  -- 2^6 = 64 (6'250'000 / 31'250 = 200 needed)
  -- constant one_period  : unsigned(count_width - 1 downto 0) := to_unsigned(clock_freq / baud_rate, count_width);
  -- constant half_period : unsigned(count_width - 1 downto 0) := to_unsigned(clock_freq / baud_rate / 2, count_width);
  signal count, next_count : unsigned(count_width-1 downto 0);

-- Begin Architecture
begin
  -------------------------------------------
  -- Process for combinatorial logic
  ------------------------------------------- 
  comb_logic : process(all)
    variable one_period  : unsigned(count_width-1 downto 0);
    variable half_period : unsigned(count_width-1 downto 0);
  begin
    one_period  := to_unsigned(clock_freq / baud_rate_i, count_width);
    half_period := to_unsigned(clock_freq / baud_rate_i / 2, count_width);
    
    -- default Statements
    tick <= '0';
    
    if (start_pulse = '1') then  -- first pulse
      next_count <= half_period;
    elsif (count = to_unsigned(0, count_width)) then
      next_count <= one_period;
      tick <= '1';
    else
      next_count <= count - 1;
    end if;
  end process comb_logic;

  ------------------------------------------- 
  -- Process for registers (flip-flops)
  -------------------------------------------
  flip_flops : process(all)
  begin
    if reset_n = '0' then
      count <= to_unsigned(0, count_width);  -- convert integer value 0 to unsigned
    elsif rising_edge(clk) then
      count <= next_count;
    end if;
  end process flip_flops;  

-- End Architecture 
end rtl;

