--
-- Project     : DT Miniprojekt
--
-- File Name   : shift_reg.vhd
-- Description : shifts serial input data from bluetooth 
--               to parallel signal
--
--------------------------------------------------------------------
-- Change History
-- Date     |Name      |Modification
------------|----------|--------------------------------------------
-- 28.11.23 | grundale | file created
-- 05.12.23 | grundale | functionality implemented
--------------------------------------------------------------------

-- Library & Use Statements
library ieee;
use ieee.std_logic_1164.all;

-- Entity Declaration 
entity shiftreg_uart is
  generic (
    width : positive := 10);          -- start + 8 data + stop
  port(clk, reset_n : in  std_logic;
       shift_enable : in  std_logic;
       serial_in    : in  std_logic;
       parallel_out : out std_logic_vector(width-1 downto 0)
       );
end shiftreg_uart;


-- Architecture Declaration
architecture rtl of shiftreg_uart is

  -- Signals & Constants Declaration
  signal shiftreg, next_shiftreg : std_logic_vector(width-1 downto 0);


-- Begin Architecture
begin

  --------------------------------------------------
  -- PROCESS FOR COMBINATORIAL LOGIC
  --------------------------------------------------
  shift_comb : process(all)
  begin
    if shift_enable = '1' then
      next_shiftreg <= (serial_in & shiftreg(width-1 downto 1));  -- shift direction towards LSB
    else 
      next_shiftreg <= shiftreg;
    end if;
  end process shift_comb;

  --------------------------------------------------
  -- PROCESS FOR REGISTERS
  --------------------------------------------------
  shift_dffs : process(clk, reset_n)
  begin
    if reset_n = '0' then
      shiftreg <= (others => '0');
    elsif rising_edge(clk) then
      shiftreg <= next_shiftreg;
    end if;
  end process shift_dffs;

  --------------------------------------------------
  -- CONCURRENT ASSIGNMENTS
  --------------------------------------------------
  parallel_out <= shiftreg;
  
-- End Architecture 
------------------------------------------- 
end rtl;

