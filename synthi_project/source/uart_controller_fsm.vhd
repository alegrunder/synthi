--
-- Project     : DT Miniprojekt
--
-- File Name   : uart_controller_fsm.vhd
-- Description : implements the finite state machine
--               of the bluetooth receiver 
--
--------------------------------------------------------------------
-- Change History
-- Date     |Name      |Modification
------------|----------|--------------------------------------------
-- 05.12.23 | heinipas | file created and functionality implemented
--------------------------------------------------------------------

--------------------------------------------------------------------
-- Library & Use Statements
-------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity Declaration 
-------------------------------------------
entity uart_controller_fsm is
  port(clk            : in  std_logic;
       reset_n        : in  std_logic;
       falling_pulse  : in  std_logic;
       baud_tick      : in  std_logic;
       bit_count      : in  std_logic_vector(3 downto 0);
       parallel_data  : in  std_logic_vector(9 downto 0);
       shift_enable   : out std_logic;
       start_pulse    : out std_logic;
       data_valid     : out std_logic
       );
end uart_controller_fsm;

-- Architecture Declaration
-------------------------------------------
architecture rtl of uart_controller_fsm is
-- Signals & Constants Declaration
-------------------------------------------
  type fsm_type is (st_idle, st_start_pulse, st_wait_rx_byte, st_check_rx); 
  signal fsm_state, next_fsm_state : fsm_type;

-- Begin Architecture
-------------------------------------------
begin
  --------------------------------------------------
  -- PROCESS FOR ALL FLIP-FLOPS
  --------------------------------------------------
  flip_flops : process(all)
  begin
    if reset_n = '0' then
      fsm_state <= st_idle;
    elsif rising_edge(clk) then
      fsm_state <= next_fsm_state;
    end if;
  end process flip_flops;
  
  --------------------------------------------------
  -- PROCESS FOR INPUT-COMB-LOGIC
  --------------------------------------------------
  state_logic : process (all)
  begin
    -- default statements (hold current value)
    next_fsm_state <= fsm_state;

    -- switch fsm_state
    case fsm_state is
      when st_idle => 
        if falling_pulse = '1' then
          next_fsm_state <= st_start_pulse;
        end if;
      when st_start_pulse =>
        next_fsm_state <= st_wait_rx_byte; -- immediately to rx
      when st_wait_rx_byte =>
        -- if last bit received
        if (baud_tick = '1') and (bit_count =  std_logic_vector(to_unsigned(9,4))) then
          next_fsm_state <= st_check_rx;
        end if;
      when st_check_rx =>
        next_fsm_state <= st_idle;         -- immediately to idle
      when others =>
        next_fsm_state <= fsm_state;
    end case;
  end process state_logic;

  --------------------------------------------------
  -- PROCESS FOR OUTPUT-COMB-LOGIC 
  --------------------------------------------------
  fsm_out_logic : process (all)
  begin
    -- default statements
    data_valid <= '0';
    shift_enable <= '0';
    start_pulse <= '0';
    
    case fsm_state is
      when st_start_pulse =>
        start_pulse <= '1';
      when st_wait_rx_byte =>
        if baud_tick = '1' then
          shift_enable <= '1';
        end if;
      when st_check_rx =>
        if (parallel_data(0) = '0') and (parallel_data(9) = '1') then
          data_valid <= '1';
        end if;
      when others => null;
    end case;
  end process fsm_out_logic;


-- End Architecture 
------------------------------------------- 
end rtl;
