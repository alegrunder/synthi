-------------------------------------------
-- Block code:  modulo_divider.vhd
-- History: 	4. Sept.2019 - 1st version (gelk)
--               6. Dez.2021 - 2nd version (gelk)
-- Function: modulo divider with generic width. Output MSB with 50% duty cycle.
--		Can be used for clock-divider when no exact ratio required.
-------------------------------------------

-- Library & Use Statements
-------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


-- Entity Declaration 
-------------------------------------------
ENTITY modulo_divider IS
  PORT( clk				: IN    std_logic;
    	   clk_6m     : OUT   std_logic
    	);
END modulo_divider;


-- Architecture Declaration?
-------------------------------------------
ARCHITECTURE rtl OF modulo_divider IS
-- Signals & Constants Declaration?
-------------------------------------------
signal width : integer := 3;
signal count, next_count: unsigned(width-1 downto 0) := (others => '0');	 


-- Begin Architecture
-------------------------------------------
BEGIN

  --------------------------------------------------
  -- PROCESS FOR COMBINATORIAL LOGIC
  --------------------------------------------------
  comb_logic: PROCESS(count)
  BEGIN	
	-- increment	
	next_count <= count + 1 ;
  END PROCESS comb_logic;   
  
  --------------------------------------------------
  -- PROCESS FOR REGISTERS
  --------------------------------------------------
  flip_flops : PROCESS(all)
  BEGIN	
    IF rising_edge(clk) THEN
		count <= next_count ;
    END IF;
  END PROCESS flip_flops;		
  
  
  --------------------------------------------------
  -- CONCURRENT ASSIGNMENTS
  --------------------------------------------------
  -- take MSB and convert for output data-type
  clk_6m <= std_logic(count(width-1));
  
  
 -- End Architecture 
------------------------------------------- 
END rtl;

