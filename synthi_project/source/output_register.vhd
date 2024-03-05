--
-- Project     : DT Miniprojekt
--
-- File Name   : output_register.vhd
-- Description : split parallel signal to two hex digits (LSB, MSB)
--
--------------------------------------------------------------------
-- Change History
-- Date     |Name      |Modification
------------|----------|--------------------------------------------
-- 05.12.23 | heinipas | file created and functionality implemented
--------------------------------------------------------------------

-- Library & Use Statements
-------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- Entity Declaration 
-------------------------------------------
entity output_register is
  port( 
    clk         : in  std_logic;
    reset_n     : in  std_logic;
    data_valid  : in  std_logic;
    parallel_in : in  std_logic_vector(9 downto 0);
    hex_lsb     : out std_logic_vector(3 downto 0);
    hex_msb     : out std_logic_vector(3 downto 0)
  );
end output_register;


-- Architecture Declaration
-------------------------------------------
architecture rtl of output_register is
-- Signals & Constants Declaration
-------------------------------------------
  signal hex_out : std_logic_vector(9 downto 0);


-- Begin Architecture
-------------------------------------------
begin
  
  --------------------------------------------------
  -- PROCESS FOR COMBINATORIAL LOGIC
  --------------------------------------------------
  comb_logic: process(all)
  begin
      hex_lsb <= hex_out(4 downto 1); -- ignore start bit (0)
      hex_msb <= hex_out(8 downto 5); -- ignore stop bit (9)
  end process comb_logic;   
  
  --------------------------------------------------
  -- PROCESS FOR REGISTERS
  --------------------------------------------------
  flip_flops : process(all)
  begin
    if reset_n = '0' then
      hex_out <=  (others => '0');
    elsif data_valid = '0' then
      hex_out <= hex_out;
    elsif rising_edge(clk) then
      hex_out <= parallel_in;
    end if;
  end process flip_flops;
  
 -- End Architecture 
 ------------------------------------------- 
end rtl;


