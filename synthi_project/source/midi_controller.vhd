-------------------------------------------------------------------------------
-- Title      : MIDI Controller
-- Project    : synthi
-------------------------------------------------------------------------------
-- File       : midi_controller.vhd
-- Author     : heinipas
-- Company    : 
-- Created    : 2024-03-26
-- Last update: 2024-03-26
-- Platform   : 
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2024 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2024-03-26  1.0      heinipas        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity midi_controller is
  port (
    clk           : in  std_logic;
    reset_n       : in  std_logic;
    rx_data_rdy_i : in  std_logic;
    rx_data_i     : in  std_logic_vector(7 downto 0);
    hex2          : out std_logic_vector(6 downto 0);
    hex3          : out std_logic_vector(6 downto 0);
    note_on_o     : out std_logic;
	 control_o     : out std_logic; -- used for control commands
    note_o        : out std_logic_vector(6 downto 0);
    velocity_o    : out std_logic_vector(6 downto 0)
    );

end entity midi_controller;

-------------------------------------------------------------------------------

architecture str of midi_controller is

  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  type fsm_type is (st_wait_status, st_wait_data1, st_wait_data2);  -- state machine
                                                                    -- type definition
  signal fsm_state, next_fsm_state : fsm_type;
  
  signal status_reg, next_status_reg : std_logic_vector(6 downto 0);
  signal data1_reg, next_data1_reg   : std_logic_vector(6 downto 0);
  signal data2_reg, next_data2_reg   : std_logic_vector(6 downto 0);
  
  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component vhdl_hex2sevseg
    port(data_in : in  std_logic_vector(3 downto 0);
         seg_out : out std_logic_vector(6 downto 0)
         );
  end component;
  
begin  -- architecture str
  --------------------------------------------------
  -- PROCESS FOR ALL FLIP-FLOPS
  --------------------------------------------------
  flip_flops : process(all)
  begin
    if reset_n = '0' then
      fsm_state <= st_wait_status;
      status_reg   <= (others => '0');
      data1_reg    <= (others => '0');
      data2_reg    <= (others => '0');
    elsif rising_edge(clk) then
      fsm_state <= next_fsm_state;
      status_reg   <= next_status_reg;
      data1_reg    <= next_data1_reg;
      data2_reg    <= next_data2_reg;
    end if;
  end process flip_flops;

  --------------------------------------------------
  -- PROCESS FOR INPUT-COMB-LOGIC FSM
  --------------------------------------------------
  state_logic : process (all)
  begin
    -- default statements (hold current value)
    next_fsm_state <= fsm_state;
    
    -- switch fsm_state
    if (rx_data_rdy_i = '1') then
      case fsm_state is
        when st_wait_status =>
          if (rx_data_i(7) = '0') then -- Running Status
            next_fsm_state <= st_wait_data2; 
          else
            next_fsm_state <= st_wait_data1;
          end if;
        when st_wait_data1 =>
            next_fsm_state <= st_wait_data2;
        when st_wait_data2 =>
            next_fsm_state <= st_wait_status;
        when others =>
          next_fsm_state <= fsm_state;
      end case;
    end if;
  end process state_logic;
  
  --------------------------------------------------
  -- PROCESS FOR INPUT-COMB-LOGIC REGISTERS
  --------------------------------------------------
  reg_logic : process (all)
  begin
    -- default statements (hold current value)
    next_status_reg <= status_reg;
    next_data1_reg <= data1_reg;
    next_data2_reg <= data2_reg;
    
    -- set next value for registers
    if (rx_data_rdy_i = '1') then
      if (fsm_state = st_wait_status) and (rx_data_i(7) = '1') then
        next_status_reg <= rx_data_i(6 downto 0);
      end if;
  
      if ((fsm_state = st_wait_status) and (rx_data_i(7) = '0')) or (fsm_state = st_wait_data1) then
        next_data1_reg <= rx_data_i(6 downto 0);
      end if;
      
      if fsm_state = st_wait_data2 then
        next_data2_reg <= rx_data_i(6 downto 0);
      end if;
    end if;
  end process reg_logic;
  
  -----------------------------------------------------------------------------
  -- PROCESS FOR OUTPUT-COMB-LOGIC
  -----------------------------------------------------------------------------
  fsm_out_logic : process (all) is
  begin  -- process fsm_out_logic
    -- default statements
    note_on_o                   <= '0';
    control_o						  <= '0';
    
    -- vereinfachte Logik, andere Steuersignale werden allenfalls nicht richtig erkannt
    if status_reg(6 downto 4) = "001" then
      note_on_o <= '1';
	 elsif status_reg(6 downto 4) = "011" then -- used for control commands
      control_o <= '1';
    end if; 
  end process fsm_out_logic;
  
  -----------------------------------------------------------------------------
  -- CONCURRENT ASSINGMENTS
  -----------------------------------------------------------------------------
  note_o <= data1_reg;
  velocity_o <= data2_reg;
  
  -----------------------------------------------------------------------------
  -- Instances
  -----------------------------------------------------------------------------
  vhdl_hex2sevseg_inst1 : vhdl_hex2sevseg
  port map(data_in => data1_reg(3 downto 0),
           seg_out => hex2);


  vhdl_hex2sevseg_inst2 : vhdl_hex2sevseg
    port map(data_in => ('0' & data1_reg(6 downto 4)),
             seg_out => hex3);
  
end architecture str;

-------------------------------------------------------------------------------
