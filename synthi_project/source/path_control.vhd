--------------------------------------------------------------------
-- Project     : PM2 Synthi Pro
--
-- File Name   : path_control.vhd
-- Description : Multiplexer für die parallelen Daten des i2s_master.vhd
--                                      Bei Digital-Loop werden die Daten des i2s_master direkt
--                                      an ihn zurückgegeben, bei aktivem synthesizer werden die
--                                      Daten des synthesizer an den i2s_master gesendet.
--
--------------------------------------------------------------------
-- Change History
-- Date     |Name      |Modification
------------|----------|--------------------------------------------
-- 24.03.14 | loosean  | file created
-- 21.04.14 | loosean  | revised comments
-- 29.03.17 | dqtm     | adapt to reuse on extended DTP2 project with DAFX
-- 12.03.24 | heinipas | modification for our project
-- 31.05.24 | heinipas | beautified, sw_3 renamed to sw_i
--------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity path_control is
  port(
    sw_i        : in  std_logic;                      --Wahl des Path
    -- Audio data generated inside FPGA
    dds_l_i     : in  std_logic_vector(15 downto 0);  --Eingang vom Synthesizer
    dds_r_i     : in  std_logic_vector(15 downto 0);
    -- Audio data coming from codec
    adcdat_pl_i : in  std_logic_vector(15 downto 0);  --Eingang vom i2s_master
    adcdat_pr_i : in  std_logic_vector(15 downto 0);
    -- Audio data towards codec
    dacdat_pl_o : out std_logic_vector(15 downto 0);  --Ausgang zum i2s_master
    dacdat_pr_o : out std_logic_vector(15 downto 0));
end path_control;

architecture arch of path_control is


begin  -- architecture arch

  -- purpose: assign dacdat depending on sw_i
  -- type   : combinational
  -- inputs : all
  -- outputs: dacdat_pl_o, dacdat_pr_o
  comb : process (all) is
  begin  -- process comb
    -- default statements
    dacdat_pl_o <= dds_l_i;
    dacdat_pr_o <= dds_r_i;

    case sw_i is
      when '1' =>                       -- digital loop
        dacdat_pl_o <= adcdat_pl_i;
        dacdat_pr_o <= adcdat_pr_i;
      when others => null;
    end case;
  end process comb;

end architecture arch;

-------------------------------------------------------------------------------
