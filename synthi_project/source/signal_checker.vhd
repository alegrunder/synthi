-------------------------------------------
-- Block code:  signal_checker.vhd
-- History:     15.Jan.2017 - 1st version (dqtm)
--              19.Jan.2017 - further reduction for SEP HS1
--					  3.Sept.2019 - Separate Bit counter from FSM
--                 <date> - <changes>  (<author>)
-- Function: fsm and registers for UART-RX in DTP1 Mini-project alternative implementation.
--                      This block is the central piece of the UART-RX, coordinating byte reception and storage of 1 byte.
-------------------------------------------

-- Library & Use Statements
-------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity Declaration 
-------------------------------------------
entity signal_checker is

  port(clk, reset_n  : in  std_logic;
       data_in     : in  std_logic;
       led_blink     	: out  std_logic
       );
end signal_checker;

-- Architecture Declaration
-------------------------------------------
architecture rtl of signal_checker is
-- Signals & Constants Declaration�
-------------------------------------------

 constant width : positive := 22;
 signal bit_count_i, next_bit_count_i : unsigned(width downto 0);
 signal pulse_count, next_pulse_count : unsigned(7 downto 0);
  signal sync_q1, sync_q2, sync_q3 : std_logic;
  -- shifted into shift register

-- Begin Architecture
-------------------------------------------
begin

  --------------------------------------------------
  -- PROCESS FOR ALL FLIP-FLOPS
  --------------------------------------------------
  flip_flops : process(clk, reset_n)
  begin
    if reset_n = '0' then
      bit_count_i <= (others => '0');
      sync_q1 <= '1';
      sync_q2 <= '1';
      sync_q3 <= '1';
      pulse_count <= (others => '0');
    elsif rising_edge(clk) then
      bit_count_i <= next_bit_count_i;
      sync_q3 <= sync_q2;
      sync_q2 <= sync_q1;
      sync_q1 <= data_in;
      pulse_count <= next_pulse_count;
    end if;
  end process flip_flops;


  --------------------------------------------------
  -- PROCESS FOR Bit-Count
  --------------------------------------------------
  pulse_counter: process (all) is
  begin  -- process pulse_counter
    if pulse_count > 0 and bit_count_i = 1 then
      next_pulse_count <= pulse_count - 1;
    elsif not sync_q2 and sync_q3 then
        next_pulse_count <= pulse_count + 1;
    else
        next_pulse_count <= pulse_count;
    end if;
      
  end process pulse_counter;

  signal_checker : process (all)
  begin
   
    if bit_count_i > 0  then
      next_bit_count_i <= bit_count_i - 1;
      
    elsif (pulse_count > 0) and (bit_count_i = 0) then
      next_bit_count_i <= (others => '1');

    else
      next_bit_count_i <= bit_count_i;
      
    end if;

  end process;

edout: process (all) is
begin  -- process edout
  led_blink <= '0';
  if bit_count_i(width) = '1' then
    led_blink <= '1';
  end if;
end process;

-- End Architecture 
------------------------------------------- 
end rtl;

