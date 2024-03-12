--------------------------------------------------------------------
-- Project     : PM2 Synthi
--
-- File Name   : i2s_master.vhd
-- Description : Konvertiert die seriellen i2s Daten in ein paralleles signal
--                              und umgekehrt, Hierachie für clock-Teiler, state-machine, schieberegister
--
--------------------------------------------------------------------
-- Change History
-- Date     |Name      |Modification
------------|----------|--------------------------------------------
-- 24.03.14 | loosean  | file created
-- 21.04.14 | loosean  | revised comments
-- 29.03.17 | dqtm     | adapt to reuse on extended DTP2 project 
-- 22.03.22 | gelk     | clk12_m zu clk6_m
--                     | Changes: reuse mod_div, combine bit_cnt & i2s_decoder into i2s_frame_generator)
-- 12.03.24 | heinipas | modification for our project
--------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity i2s_master is
  port(
    clk_6m : in std_logic;              -- Master Clock
    rst_n  : in std_logic;  -- Reset or init used for re-initialisation

    step_o : out std_logic;             -- Pulse once per audio frame 1/48kHz

    --Verbindungen zum audio_controller
    adcdat_pl_o : out std_logic_vector(15 downto 0);  --Ausgang zum audio_controller
    adcdat_pr_o : out std_logic_vector(15 downto 0);

    dacdat_pl_i : in std_logic_vector(15 downto 0);  --Eingang vom audio_controller
    dacdat_pr_i : in std_logic_vector(15 downto 0);

    --Verbindungen zum Audio-Codec
    dacdat_s_o : out std_logic;         --Serielle Daten Ausgang
    ws_o       : out std_logic;         --WordSelect (Links/Rechts)
    adcdat_s_i : in  std_logic);        --Serielle Daten Eingang
end i2s_master;


architecture top of i2s_master is
  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  signal load      : std_logic;
  signal shift_l   : std_logic;
  signal shift_r   : std_logic;
  signal ws_sig    : std_logic;
  signal ser_out_l : std_logic;
  signal ser_out_r : std_logic;

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

  component uni_shiftreg is
    generic (
      width : positive);
    port (
      clk_6m  : in  std_logic;
      rst_n   : in  std_logic;
      par_in  : in  std_logic_vector(width-1 downto 0);
      load    : in  std_logic;
      ser_in  : in  std_logic;
      enable  : in  std_logic;
      ser_out : out std_logic;
      par_out : out std_logic_vector(width-1 downto 0));
  end component uni_shiftreg;

  component i2s_frame_generator is
    port (
      clk_6m  : in  std_logic;
      rst_n   : in  std_logic;
      load    : out std_logic;
      shift_l : out std_logic;
      shift_r : out std_logic;
      ws      : out std_logic);
  end component i2s_frame_generator;


begin
  -----------------------------------------------------------------------------
  -- Concurrent Assignments
  -----------------------------------------------------------------------------
  step_o <= load;
  ws_o   <= ws_sig;

  -----------------------------------------------------------------------------
  -- process for comb output logic
  -----------------------------------------------------------------------------
  out_comb : process (all) is
  begin  -- process out_comb
    dacdat_s_o <= ser_out_l;
    case ws_sig is
      when '1' =>
        dacdat_s_o <= ser_out_r;
      when others => null;
    end case;
  end process out_comb;

  -----------------------------------------------------------------------------
  -- Instances
  -----------------------------------------------------------------------------

  -- instance "uni_shiftreg_out_l"
  uni_shiftreg_out_l : uni_shiftreg
    generic map (
      width => 16)
    port map (
      clk_6m  => clk_6m,
      rst_n   => rst_n,
      par_in  => dacdat_pl_i,
      load    => load,
      ser_in  => '0',
      enable  => shift_l,
      ser_out => ser_out_l
     -- par_out => par_out
      );

  -- instance "uni_shiftreg_out_r"
  uni_shiftreg_out_r : uni_shiftreg
    generic map (
      width => 16)
    port map (
      clk_6m  => clk_6m,
      rst_n   => rst_n,
      par_in  => dacdat_pr_i,
      load    => load,
      ser_in  => '0',
      enable  => shift_r,
      ser_out => ser_out_r
     -- par_out => par_out
      );

  -- instance "uni_shiftreg_in_l"
  uni_shiftreg_in_l : uni_shiftreg
    generic map (
      width => 16)
    port map (
      clk_6m  => clk_6m,
      rst_n   => rst_n,
      par_in  => (others => '0'),
      load    => '0',
      ser_in  => adcdat_s_i,
      enable  => shift_l,
      -- ser_out => ser_out_l,
      par_out => adcdat_pl_o
      );

  -- instance "uni_shiftreg_in_r"
  uni_shiftreg_in_r : uni_shiftreg
    generic map (
      width => 16)
    port map (
      clk_6m  => clk_6m,
      rst_n   => rst_n,
      par_in  => (others => '0'),
      load    => '0',
      ser_in  => adcdat_s_i,
      enable  => shift_r,
      -- ser_out => ser_out_l,
      par_out => adcdat_pr_o
      );

  -- instance "i2s_frame_generator_1"
  i2s_frame_generator_1 : i2s_frame_generator
    port map (
      clk_6m  => clk_6m,
      rst_n   => rst_n,
      load    => load,
      shift_l => shift_l,
      shift_r => shift_r,
      ws      => ws_sig
      );

end top;
