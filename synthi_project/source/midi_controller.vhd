-------------------------------------------------------------------------------
-- Title      : MIDI Controller
-- Project    : synthi
-------------------------------------------------------------------------------
-- File       : midi_controller.vhd
-- Author     : heinipas
-- Company    : 
-- Created    : 2024-03-26
-- Last update: 2024-04-16
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
-- 2024-04-16  2.0      heinipas        MIDI mehrkanalig
-- 2024-04-16  2.1      grundale        added feedback note valid for envelope
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.tone_gen_pkg.all;
-------------------------------------------------------------------------------

entity midi_controller is
  port (
    clk           : in  std_logic;
    reset_n       : in  std_logic;
    rx_data_rdy_i : in  std_logic;
    rx_data_i     : in  std_logic_vector(7 downto 0);
    note_valid_i  : in  std_logic_vector(9 downto 0);
    hex2          : out std_logic_vector(6 downto 0);
    hex3          : out std_logic_vector(6 downto 0);
    note_on_o     : out std_logic_vector(9 downto 0);
    note_o        : out t_tone_array;
    velocity_o    : out t_tone_array;
    vol_reg_o     : out std_logic_vector(6 downto 0);
    pitch_reg_o   : out std_logic_vector(6 downto 0);
    ctrl_reg_o    : out std_logic_vector(6 downto 0)
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

  signal new_data_flag, next_new_data_flag : std_logic := '0';

  signal reg_note_on, next_reg_note_on   : std_logic_vector(9 downto 0);
  signal reg_note, next_reg_note         : t_tone_array;
  signal reg_velocity, next_reg_velocity : t_tone_array;
  signal vol_reg, next_vol_reg           : std_logic_vector(6 downto 0);
  signal pitch_reg, next_pitch_reg       : std_logic_vector(6 downto 0);
  signal ctrl_reg, next_ctrl_reg         : std_logic_vector(6 downto 0);
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
      fsm_state     <= st_wait_status;
      status_reg    <= (others => '0');
      data1_reg     <= (others => '0');
      data2_reg     <= (others => '0');
      new_data_flag <= '0';
      reg_note_on   <= (others => '0');
      for i in 0 to 9 loop
        reg_note(i)     <= (others => '0');
        reg_velocity(i) <= (others => '0');
      end loop;
      vol_reg   <= "1000000";
      pitch_reg <= "1000000";
      ctrl_reg  <= "1000000";
    elsif rising_edge(clk) then
      fsm_state     <= next_fsm_state;
      status_reg    <= next_status_reg;
      data1_reg     <= next_data1_reg;
      data2_reg     <= next_data2_reg;
      new_data_flag <= next_new_data_flag;
      reg_note_on   <= next_reg_note_on;
      reg_note      <= next_reg_note;
      reg_velocity  <= next_reg_velocity;
      vol_reg       <= next_vol_reg;
      pitch_reg     <= next_pitch_reg;
      ctrl_reg      <= next_ctrl_reg;
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
          if (rx_data_i(7) = '0') then  -- Running Status
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
    next_status_reg    <= status_reg;
    next_data1_reg     <= data1_reg;
    next_data2_reg     <= data2_reg;
    next_new_data_flag <= '0';

    -- set next value for registers
    if (rx_data_rdy_i = '1') then
      if (fsm_state = st_wait_status) and (rx_data_i(7) = '1') then
        next_status_reg <= rx_data_i(6 downto 0);
      end if;

      if ((fsm_state = st_wait_status) and (rx_data_i(7) = '0')) or (fsm_state = st_wait_data1) then
        next_data1_reg <= rx_data_i(6 downto 0);
      end if;

      if fsm_state = st_wait_data2 then
        next_data2_reg     <= rx_data_i(6 downto 0);
        next_new_data_flag <= '1';
      end if;
    end if;
  end process reg_logic;

  -----------------------------------------------------------------------------
  -- PROCESS FOR MIDI-ARRAY-LOGIC
  -----------------------------------------------------------------------------
  midi_array_logic : process (all) is
    variable note_available : std_logic := '0';
    variable note_written   : std_logic := '0';
  begin  -- process midi_array_logic
    -- default statements
    note_available    := '0';
    note_written      := '0';
    next_reg_note_on  <= reg_note_on;
    next_reg_note     <= reg_note;
    next_reg_velocity <= reg_velocity;
    next_vol_reg      <= vol_reg;
    next_pitch_reg    <= pitch_reg;
    next_ctrl_reg     <= ctrl_reg;

    -- process new midi command
    if (new_data_flag) then
      -- command En (pitch wheel)
      if (status_reg(6 downto 4) = "110") then
      --if ((status_reg(6 downto 4) = "011") and (data1_reg = "0010000")) then -- used for different Midi keyboard dont delete
        next_pitch_reg <= data2_reg;
      -- command Bn 07 (volume)
      elsif ((status_reg(6 downto 4) = "011") and (data1_reg = "0000111")) then --0000111 --0001111  -- used for different Midi keyboard dont delete
        next_vol_reg <= data2_reg;
      -- command Bn 01 (modulation wheel)
      elsif ((status_reg(6 downto 4) = "011") and (data1_reg = "0000001")) then -- 0000001 --0001110  -- used for different Midi keyboard dont delete
        next_ctrl_reg <= data2_reg;
      -- note_on 9n or note_off 8n
      elsif ((status_reg(6 downto 4) = "001") or (status_reg(6 downto 4) = "000")) then
        ------------------------------------------------------
        -- CHECK IF NOTE IS ALREADY ENTERED IN MIDI ARRAY
        ------------------------------------------------------
        for i in 0 to 9 loop
          if ((reg_note(i) = data1_reg) and (note_valid_i(i) = '1')) then
            -- Found a matching note
            note_available := '1';
            if (status_reg(6 downto 4) = "000") then
              -- turn note off
              next_reg_note_on(i) <= '0';
            elsif (status_reg(6 downto 4) = "001" and data2_reg = "0000000") then
              -- running mode turn off (velocity = 0)
              next_reg_note_on(i) <= '0';
            elsif (status_reg(6 downto 4) = "001") then
              -- change velocity for a note that is already playing
              next_reg_velocity(i) <= data2_reg;
              next_reg_note_on(i)  <= '1';  -- and set register to valid
            end if;
          end if;
        end loop;

        -----------------------------------------
        -- ENTER A NEW NOTE IF STILL EMPTY REGISTERS
        ------------------------------------------
        -- If the new note is not in the midi storage array yet, find a free space
        -- if the valid flag is cleared, the note can be overwritten, at the same time a flag is set to mark that
        -- the new note has found a place.
        if note_available = '0' then
          -- If there is not yet an entry for the note, look for an empty space and write it
          for i in 0 to 9 loop
            -- if the note already written, ignore the remaining loop runs
            if note_written = '0' then
              -- If a free space is found reg_note_on(i) = '0' enter the note number and velocity
              -- note_valid prevents overwriting a note that is still decaing (envelope)
              -- if no space is found, nothing will be written and 11th tone will be discarded
              if ((reg_note_on(i) = '0') and (note_valid_i(i) = '0') and (status_reg(6 downto 4) = "001")) then
                next_reg_note(i)     <= data1_reg;
                next_reg_velocity(i) <= data2_reg;
                next_reg_note_on(i)  <= '1';  -- and set register to valid
                note_written         := '1';  -- flag that note is written to suppress remaining loops
              end if;
            end if;
          end loop;
        end if;  -- note_available = '0'
      end if;  -- note_on or note_off
    end if;  -- new_data_flag

  end process midi_array_logic;

  -----------------------------------------------------------------------------
  -- CONCURRENT ASSINGMENTS
  -----------------------------------------------------------------------------
  note_o      <= reg_note;
  velocity_o  <= reg_velocity;
  note_on_o   <= reg_note_on;
  vol_reg_o   <= vol_reg;
  pitch_reg_o <= pitch_reg;
  ctrl_reg_o  <= ctrl_reg;

  -----------------------------------------------------------------------------
  -- Instances for simulation tests
  -----------------------------------------------------------------------------
  vhdl_hex2sevseg_inst1 : vhdl_hex2sevseg
    port map(data_in => data1_reg(3 downto 0),
             seg_out => hex2);


  vhdl_hex2sevseg_inst2 : vhdl_hex2sevseg
    port map(data_in => ('0' & data1_reg(6 downto 4)),
             seg_out => hex3);

end architecture str;

-------------------------------------------------------------------------------
