-------------------------------------------------------------------------------
-- Project     : Synthi Pro
-- Description : i2c interface to initialize audio codec WM8731
--
--               sda_io is bidirectional: 
--               output sda = '1' means high impedance
--               output sda = '0' means pull down to ground
--
-------------------------------------------------------------------------------
--
-- Change History
-- Date       |Name      |Modification
--------------|----------|-----------------------------------------------------
-- 2013-02-26 | dqtm     | file created for DTP2 Lab4
-- 2024-03-05 | heinipas | beautify template
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity i2c_master is
  port(
    clk     : in std_logic;
    reset_n : in std_logic;

    write_i      : in std_logic;
    write_data_i : in std_logic_vector(15 downto 0);

    sda_io : inout std_logic;
    scl_o  : out   std_logic;

    write_done_o : out std_logic;
    ack_error_o  : out std_logic
    );
end entity;


-- begin of Architecture
architecture rtl of i2c_master is

-------------------------------------------------------------------------------
-- Constant Declaration
-------------------------------------------------------------------------------
  constant C_BYTE_COUNT_SIZE   : natural := 2;  -- must be big enough to contain C_TRANSMITTED_BYTES
  constant C_BIT_COUNT_SIZE    : natural := 3;
  constant C_TRANSMITTED_BYTES : natural := 3;  -- 1xAddress + 2xData
  constant C_DATA_BUFFER_SIZE  : natural := 8 * C_TRANSMITTED_BYTES;

  constant C_I2C_ADDRESS : std_logic_vector(6 downto 0) := "0011010";  -- if csb = 0 (pin 22 of SSOP package)
  constant C_I2C_WRITE   : std_logic                    := '0';
  constant C_I2C_READ    : std_logic                    := '1';

  constant C_SCL_NEG_EDGE : std_logic_vector(2 downto 0) := "100";
  constant C_SDA_POS_EDGE : std_logic_vector(2 downto 0) := "101";
  constant C_SCL_POS_EDGE : std_logic_vector(2 downto 0) := "110";
  constant C_SDA_NEG_EDGE : std_logic_vector(2 downto 0) := "111";

  constant C_DIVIDER_VALUE : natural := 5;  -- fifth power of 2 = 32
                                            -- (50MHz ÷ 32 = 384kHz)
                                            -- according to WM8731 spec also possible faster
-------------------------------------------------------------------------------
-- Type Declaration
-------------------------------------------------------------------------------
  type t_fsm_states is (
    S_IDLE,
    S_WAIT_FOR_START,
    S_START,
    S_WAIT_FOR_NEXT_BYTE,
    S_SEND_BYTE,
    S_ACK_BYTE,
    S_WAIT_FOR_STOP,
    S_STOP
    );

-------------------------------------------------------------------------------
-- Signal Declaration
-------------------------------------------------------------------------------
-- Current and Next Register State
  signal fsm_state, next_fsm_state         : t_fsm_states;
  signal clk_divider, next_clk_divider     : std_logic_vector(C_DIVIDER_VALUE-1 downto 0);
  signal clk_mask, next_clk_mask           : std_logic_vector(1 downto 0);
  signal clk_edge_mask, next_clk_edge_mask : std_logic_vector(2 downto 0);
  signal scl, next_scl                     : std_logic;
  signal sda, next_sda                     : std_logic;
  signal data, next_data                   : std_logic_vector(C_DATA_BUFFER_SIZE-1 downto 0);
  signal bit_count, next_bit_count         : unsigned(C_BIT_COUNT_SIZE-1 downto 0);
  signal byte_count, next_byte_count       : unsigned(C_BYTE_COUNT_SIZE-1 downto 0);
  signal ack, next_ack                     : std_logic;
  signal ack_error, next_ack_error         : std_logic;
  signal write_done, next_write_done       : std_logic;


-------------------------------------------------------------------------------
-- Begin Architecture
-------------------------------------------------------------------------------
begin


  -------------------------------------------------------------------------------
  -- Process for combinational logic
  -------------------------------------------------------------------------------
  logic_proc : process(fsm_state, clk_divider, clk_mask, clk_edge_mask, scl, sda, data,
                       bit_count, byte_count, ack, ack_error, write_i, write_data_i, sda_io)

    variable scl_en     : std_logic;
    variable edge_check : std_logic_vector(1 downto 0);  -- re-check scl-clock-gen later for possible simplification

  begin

    -----------------------------------------------------------------------
    -- Default Statement, mostly keep current value
    -----------------------------------------------------------------------
    next_fsm_state     <= fsm_state;
    next_clk_divider   <= clk_divider;
    next_clk_mask      <= clk_mask;
    next_clk_edge_mask <= clk_edge_mask;
    next_scl           <= scl;
    next_sda           <= sda;
    next_data          <= data;
    next_bit_count     <= bit_count;
    next_ack           <= ack;
    next_byte_count    <= byte_count;
    next_ack_error     <= '0';
    next_write_done    <= '0';

    scl_en     := '0';                  -- SCL is disabled on default
    edge_check := clk_mask;             -- keep previous until update
    -----------------------------------------------------------------------
    -- State Machine
    -----------------------------------------------------------------------
    -- creates a write transaction of C_TRANSMITTED_BYTES = 3 bytes
    -- first byte is address following 2 bytes of data

    case fsm_state is
      --------------------------------------------------------------------
      when S_IDLE =>
        --------------------------------------------------------------------
        next_sda <= '1';

        -- wait until a write request is asserted
        if (write_i = '1') then
          next_ack_error                                              <= '0';
          next_data(C_DATA_BUFFER_SIZE-1 downto C_DATA_BUFFER_SIZE-7) <= C_I2C_ADDRESS;
          next_data(C_DATA_BUFFER_SIZE-8)                             <= C_I2C_WRITE;
          next_data(C_DATA_BUFFER_SIZE-9 downto 0)                    <= write_data_i;
          next_fsm_state                                              <= S_WAIT_FOR_START;
        end if;

      --------------------------------------------------------------------
      when S_WAIT_FOR_START =>
        --------------------------------------------------------------------
        -- wait for next positive edge of sda_clk to send start condition
        if (clk_edge_mask = C_SDA_POS_EDGE) then
          next_sda       <= '0';
          next_fsm_state <= S_START;
        end if;

      --------------------------------------------------------------------
      when S_START =>
        --------------------------------------------------------------------
        -- send start
        scl_en := '1';

        if (clk_edge_mask = C_SDA_POS_EDGE) then
          next_sda        <= data(data'high);
          next_data       <= data(data'high-1 downto 0) & '0';
          next_byte_count <= to_unsigned(0, C_BYTE_COUNT_SIZE);
          next_bit_count  <= to_unsigned(0, C_BIT_COUNT_SIZE);
          next_fsm_state  <= S_SEND_BYTE;
        end if;

      --------------------------------------------------------------------
      when S_WAIT_FOR_NEXT_BYTE =>
        --------------------------------------------------------------------
        scl_en := '1';

        -- wait for next positive edge of sda_clk to send next_byte
        if (clk_edge_mask = C_SDA_POS_EDGE) then
          next_sda       <= data(data'high);
          next_data      <= data(data'high-1 downto 0) & '0';
          next_fsm_state <= S_SEND_BYTE;
        end if;

      --------------------------------------------------------------------
      when S_SEND_BYTE =>
        --------------------------------------------------------------------
        scl_en := '1';

        -- shift left
        if (clk_edge_mask = C_SDA_POS_EDGE) then
          if (bit_count = to_unsigned(7, C_BIT_COUNT_SIZE)) then
            next_sda        <= '1';
            next_byte_count <= byte_count + to_unsigned(1, C_BYTE_COUNT_SIZE);
            next_bit_count  <= to_unsigned(0, C_BIT_COUNT_SIZE);
            next_fsm_state  <= S_ACK_BYTE;
          else
            next_sda       <= data(data'high);
            next_data      <= data(data'high-1 downto 0) & '0';
            next_bit_count <= bit_count + to_unsigned(1, C_BIT_COUNT_SIZE);
          end if;
        end if;

      --------------------------------------------------------------------
      when S_ACK_BYTE =>
        --------------------------------------------------------------------
        -- check if slave sends acknowledge
        -- (check data on positive and negative edge of SCL, they must not change)
        scl_en := '1';

        if (clk_edge_mask = C_SCL_POS_EDGE) then
          next_ack <= sda_io;
        end if;
        if (clk_edge_mask = C_SCL_NEG_EDGE) then
          if ((ack = '0') and (sda_io = '0')) then
            -- acknowledge
            if (byte_count = to_unsigned(C_TRANSMITTED_BYTES, C_BYTE_COUNT_SIZE)) then
              next_fsm_state <= S_WAIT_FOR_STOP;
            else
              next_fsm_state <= S_WAIT_FOR_NEXT_BYTE;
            end if;
          else
            -- not acknowledge
            next_ack_error <= '1';
            next_fsm_state <= S_WAIT_FOR_STOP;
          end if;
        end if;

      --------------------------------------------------------------------
      when S_WAIT_FOR_STOP =>
        --------------------------------------------------------------------
        scl_en := '1';

        -- wait for next positive edge of sda_clk to send stop condition
        if (clk_edge_mask = C_SDA_POS_EDGE) then
          next_sda       <= '0';
          next_fsm_state <= S_STOP;
        end if;

      --------------------------------------------------------------------
      when S_STOP =>
        --------------------------------------------------------------------
        -- send stop
        if (clk_edge_mask = C_SDA_POS_EDGE) then
          if (ack_error = '0') then
            next_write_done <= '1';
          end if;
          next_sda       <= '1';
          next_fsm_state <= S_IDLE;
        end if;

    end case;

    -----------------------------------------------------------------------
    -- Clock Generation
    -----------------------------------------------------------------------

    -- generate 2 pseudo clocks (scl_clk and sda_clk) of 90° phase shift
    -- SDA changes at positive edge of sda_clk and scl_clk is SCL

    -- clk_divider |  0  1  2  3  0  1  2  3  0  1  2  3
    --             |         _____       _____       _____       _____       _____
    -- scl_clk     |  ______|     |_____|     |_____|     |_____|     |_____|     
    --             |      _____       _____       _____       _____       _____   
    -- sda_clk     |  ___|     |_____|     |_____|     |_____|     |_____|     |__
    --             |
    --             |
    --             |  ___             _____ _____ _____ _____ _____ _____ _____ __
    -- sda_o       |     |_____S_____|_____0_____|_____1_____|_____2_____|_____3__
    --             | _____________       _____       _____       _____       _____
    -- scl_o       |              |_____|     |_____|     |_____|     |_____|     

    next_clk_divider <= std_logic_vector(unsigned(clk_divider) + to_unsigned(1, C_DIVIDER_VALUE));
    next_clk_mask    <= clk_divider((C_DIVIDER_VALUE - 1) downto (C_DIVIDER_VALUE - 2));
    -- intermediate solution until re-check scl-clock-gen for possible simplification
    edge_check       := clk_divider((C_DIVIDER_VALUE - 1) downto (C_DIVIDER_VALUE - 2));  --next_clk_mask; 

    -- edge detection / third bit is the edge mark
    if (clk_mask /= edge_check) then
      next_clk_edge_mask <= '1' & clk_mask;
    else
      next_clk_edge_mask <= '0' & clk_mask;
    end if;

    -- generate SCL
    if (clk_edge_mask = C_SCL_POS_EDGE) then
      next_scl <= '1';
    end if;
    if ((clk_edge_mask = C_SCL_NEG_EDGE) and (scl_en = '1')) then
      next_scl <= '0';
    end if;

  end process;  -- comb logic

  -------------------------------------------------------------------------------
  -- Process for clocked logic (FFs)
  -------------------------------------------------------------------------------
  clk_proc : process(clk, reset_n)
  begin
    if reset_n = '0' then
      -- Reset Register (Asynchronous)
      fsm_state     <= S_IDLE;
      clk_divider   <= (others => '0');
      clk_mask      <= (others => '0');
      clk_edge_mask <= (others => '0');
      scl           <= '1';
      sda           <= '1';
      data          <= (others => '0');
      bit_count     <= (others => '0');
      ack           <= '0';
      byte_count    <= (others => '0');
      ack_error     <= '0';
      write_done    <= '0';

    elsif rising_edge(clk) then
      fsm_state     <= next_fsm_state;
      clk_divider   <= next_clk_divider;
      clk_mask      <= next_clk_mask;
      clk_edge_mask <= next_clk_edge_mask;
      scl           <= next_scl;
      sda           <= next_sda;
      data          <= next_data;
      bit_count     <= next_bit_count;
      ack           <= next_ack;
      byte_count    <= next_byte_count;
      ack_error     <= next_ack_error;
      write_done    <= next_write_done;
    end if;
  end process;  -- FFs


  -----------------------------------------------------------------------
  -- Concurrent Assignments for Output Signals                                                      
  -----------------------------------------------------------------------
  -- two wire control interface (i2c)
  scl_o  <= scl;
  sda_io <= 'Z' when sda = '1' else '0';

  -- status
  ack_error_o  <= ack_error;
  write_done_o <= write_done;
  -----------------------------------------------------------------------


end architecture;  -- rtl for i2c_master
