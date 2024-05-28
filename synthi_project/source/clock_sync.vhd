-------------------------------------------
-- Block code:  clock_sync.vhd
-- History:     4.Sept.2019 - 1st version (gelk)
--                 <date> - <changes>  (<author>)
-- Function: edge detector with rise & fall outputs. 
--           Declaring FFs as a shift-register.
-------------------------------------------

-- Library & Use Statements
library ieee;
use ieee.std_logic_1164.all;

-- Entity Declaration 
entity clock_sync is
  port(data_in  : in  std_logic;
       clk      : in  std_logic;
       sync_out : out std_logic
       );
end clock_sync;

-- Architecture Declaration
architecture rtl of clock_sync is
  -- Signals & Constants Declaration
  signal q_0, q_1 : std_logic := '0';

-- Begin Architecture
begin
  -------------------------------------------
  -- Process for registers (flip-flops)
  -------------------------------------------
  reg_proc : process(all)
  begin
    if rising_edge(clk) then
      q_0 <= data_in;
      q_1 <= q_0;
    end if;

  end process reg_proc;

  -------------------------------------------
  -- Concurrent Assignments  
  -------------------------------------------
  sync_out <= q_1;

end rtl;
