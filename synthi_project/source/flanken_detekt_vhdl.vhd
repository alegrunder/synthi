-------------------------------------------
-- Block code:  flanken_detekt_vhdl
-- History:     20.August.2019 - 1st version( gelk)
--                 <date> - <changes>  (<author>)
-- Function: template to be edited by students in order 
--           to describe edge detector with rise & fall outputs. 
--             
-------------------------------------------

-- Library & Use Statements
library ieee;
use ieee.std_logic_1164.all;

-- Entity Declaration 
entity flanken_detekt_vhdl is
  port(data_in     : in  std_logic;
       clock       : in  std_logic;
       reset_n     : in  std_logic;
       fl_steigend : out std_logic;
       fl_fallend  : out std_logic
       );
end flanken_detekt_vhdl;


-- Architecture Declaration
architecture rtl of flanken_detekt_vhdl is

  -- Signals & Constants Declaration
  signal q1 : std_logic;
  signal q2 : std_logic;

-- Begin Architecture
begin
  -------------------------------------------
  -- Process for combinatorial logic
  ------------------------------------------- 
  -- not needed in this file, using concurrent logic

  -------------------------------------------
  -- Process for registers (flip-flops)
  -------------------------------------------
  flip_flops : process(all)
  begin
    if reset_n = '0' then
      q1 <= '0';
      q2 <= '0';
    elsif (rising_edge(clock)) then
      --   HIER MÜSSEN SIE EDITIEREN ...
      q2 <= q1;
      q1 <= data_in;
    end if;
  end process flip_flops;

  -------------------------------------------
  -- Detector Logik Process
  -------------------------------------------
  --   HIER MÜSSEN SIE EDITIEREN ...
  fl_steigend <= q1 and not(q2);
  fl_fallend  <= q2 and not(q1);

end rtl;
