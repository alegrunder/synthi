-------------------------------------------
-- Block code:  modulo_divider.vhd
-- History:     4. Sept.2019 - 1st version (gelk)
--               6. Dez.2021 - 2nd version (gelk)
--              2024-02-05 - added 12.5 MHz Clock (heinipas)
-- Function: modulo divider with generic width. Output MSB with 50% duty cycle.
--              Can be used for clock-divider when no exact ratio required.
-------------------------------------------

-- Library & Use Statements
-------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- Entity Declaration 
-------------------------------------------
entity modulo_divider is
  port(clk     : in  std_logic;
       clk_6m  : out std_logic;
       clk_12m : out std_logic
       );
end modulo_divider;


-- Architecture Declaration?
-------------------------------------------
architecture rtl of modulo_divider is
-- Signals & Constants Declaration?
-------------------------------------------
  signal width             : integer                    := 3;
  signal count, next_count : unsigned(width-1 downto 0) := (others => '0');


-- Begin Architecture
-------------------------------------------
begin

  --------------------------------------------------
  -- PROCESS FOR COMBINATORIAL LOGIC
  --------------------------------------------------
  comb_logic : process(count)
  begin
    -- increment        
    next_count <= count + 1;
  end process comb_logic;

  --------------------------------------------------
  -- PROCESS FOR REGISTERS
  --------------------------------------------------
  flip_flops : process(all)
  begin
    if rising_edge(clk) then
      count <= next_count;
    end if;
  end process flip_flops;


  --------------------------------------------------
  -- CONCURRENT ASSIGNMENTS
  --------------------------------------------------
  -- take MSB and convert for output data-type
  clk_6m  <= std_logic(count(width-1));
  -- take one bit below MSB for double frequency
  clk_12m <= std_logic(count(width-2));


-- End Architecture 
------------------------------------------- 
end rtl;

