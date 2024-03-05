--
-- Project     : DT
--
-- File Name   : vhdl_hex2sevseg
-- Description : 7-seg decoder with mux, lt and blank
--
-- Features:     grundale
--
--------------------------------------------------------------------
-- Change History
-- Date     |Name      |Modification
------------|----------|--------------------------------------------
-- 15.10.14 |  dqtm    | file created
-- 15.10.14 |  rosn    | small changes, comments
-- 11.10.19 |  gelk    | adapted for 2025

--------------------------------------------------------------------

-- Library & Use Statements
library ieee;
use ieee.std_logic_1164.all;

-- Entity Declaration 
entity vhdl_hex2sevseg is
  port(
    data_in    : in  std_logic_vector(3 downto 0);    -- Input of entity
    seg_out    : out std_logic_vector(6 downto 0)     -- Output of entity
  );
end vhdl_hex2sevseg;

-- Architecture Declaration
architecture comb of vhdl_hex2sevseg is

  -- Signals & Constants Declaration 
  constant hex0 : std_logic_vector(6 downto 0) := "1000000";
  constant hex1 : std_logic_vector(6 downto 0) := "1111001";
  constant hex2 : std_logic_vector(6 downto 0) := "0100100";
  constant hex3 : std_logic_vector(6 downto 0) := "0110000";
  constant hex4 : std_logic_vector(6 downto 0) := "0011001";
  constant hex5 : std_logic_vector(6 downto 0) := "0010010";
  constant hex6 : std_logic_vector(6 downto 0) := "0000010";
  constant hex7 : std_logic_vector(6 downto 0) := "1111000";
  constant hex8 : std_logic_vector(6 downto 0) := "0000000";
  constant hex9 : std_logic_vector(6 downto 0) := "0010000";
  constant hexA : std_logic_vector(6 downto 0) := "0001000";
  constant hexB : std_logic_vector(6 downto 0) := "0000011";
  constant hexC : std_logic_vector(6 downto 0) := "1000110";
  constant hexD : std_logic_vector(6 downto 0) := "0100001";
  constant hexE : std_logic_vector(6 downto 0) := "0000110";
  constant hexF : std_logic_vector(6 downto 0) := "0001110";
  constant blk  : std_logic_vector(6 downto 0) := "1111111";

-- Begin Architecture
begin
  -- Process for combinatorial logic
  hex2seven : process (all) is
    begin
      case data_in is
        when x"0" =>  seg_out <= hex0;
        when x"1" =>  seg_out <= hex1;
        when x"2" =>  seg_out <= hex2;
        when x"3" =>  seg_out <= hex3;
        when x"4" =>  seg_out <= hex4;
        when x"5" =>  seg_out <= hex5;
        when x"6" =>  seg_out <= hex6;
        when x"7" =>  seg_out <= hex7;
        when x"8" =>  seg_out <= hex8;
        when x"9" =>  seg_out <= hex9;
        when x"A" =>  seg_out <= hexA;
        when x"B" =>  seg_out <= hexB;
        when x"C" =>  seg_out <= hexC;
        when x"D" =>  seg_out <= hexD;
        when x"E" =>  seg_out <= hexE;
        when x"F" =>  seg_out <= hexF;
        when others => seg_out <= blk;
      end case;
  end process hex2seven;
-- End Architecture 
end comb;

