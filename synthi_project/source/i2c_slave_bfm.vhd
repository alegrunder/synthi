
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity i2c_slave_bfm is
  generic(
    verbose : boolean := false
    );
  port(
    AUD_XCK   : in    std_logic;
    I2C_SDAT  : inout std_logic := 'H';
    I2C_SCLK  : inout std_logic := 'H';
    reg_data0 : out   std_logic_vector(31 downto 0);
    reg_data1 : out   std_logic_vector(31 downto 0);
    reg_data2 : out   std_logic_vector(31 downto 0);
    reg_data3 : out   std_logic_vector(31 downto 0);
    reg_data4 : out   std_logic_vector(31 downto 0);
    reg_data5 : out   std_logic_vector(31 downto 0);
    reg_data6 : out   std_logic_vector(31 downto 0);
    reg_data7 : out   std_logic_vector(31 downto 0);
    reg_data8 : out   std_logic_vector(31 downto 0);
    reg_data9 : out   std_logic_vector(31 downto 0)
    );
end entity;


--------------------------------------------------------------------------------
-- begin of Architecture
--------------------------------------------------------------------------------
architecture bfm of i2c_slave_bfm is

  ----------------------------------------------------------------------------
  -- Types / FSM Encoding
  ----------------------------------------------------------------------------

  subtype t_byte is std_logic_vector(7 downto 0);
  subtype t_slv_addr_type is std_logic_vector(6 downto 0);

  -- I2C Transfer-Typ
  type t_data_direction is (UNDEFINED, WRITE_DATA, READ_DATA);
  -- Result of RX/TX processing
  type t_proc_result is (START_COND, STOP_COND, RX_BYTE, TX_BYTE);

  -- FSM Encoding
  type t_state is (S_IDLE, S_RX_ADDR, S_ACTIVE, S_RX_DATA, S_TX_DATA);


  constant addr_reg0 : std_logic_vector(6 downto 0) := "000" & x"0";
  constant addr_reg1 : std_logic_vector(6 downto 0) := "000" & x"1";
  constant addr_reg2 : std_logic_vector(6 downto 0) := "000" & x"2";
  constant addr_reg3 : std_logic_vector(6 downto 0) := "000" & x"3";
  constant addr_reg4 : std_logic_vector(6 downto 0) := "000" & x"4";
  constant addr_reg5 : std_logic_vector(6 downto 0) := "000" & x"5";
  constant addr_reg6 : std_logic_vector(6 downto 0) := "000" & x"6";
  constant addr_reg7 : std_logic_vector(6 downto 0) := "000" & X"7";
  constant addr_reg8 : std_logic_vector(6 downto 0) := "000" & x"8";
  constant addr_reg9 : std_logic_vector(6 downto 0) := "000" & x"9";


  ----------------------------------------------------------------------------
  -- Functions / Procedures
  ----------------------------------------------------------------------------


  ------------------------------------------------------------
  -- Conversion from std_logic values to 'X', '0' and '1' only
  ------------------------------------------------------------
  function zsig_to_X01 (value : std_logic) return std_logic is
  begin
    if value = '1' or value = 'Z' or value = 'H' then
      return '1';
    elsif value = '0' or value = 'L' then
      return '0';
    else
      return 'X';
    end if;
  end function;

  -----------------------------------
  -- Rising edge on 'Z' signal
  -----------------------------------
  function rising_edge_Z (signal s : std_ulogic) return boolean is
  begin
    if s'event and zsig_to_X01(s) = '1' then
      return true;
    end if;
    return false;
  end function;

  -----------------------------------
  -- Falling edge on 'Z' signal
  -----------------------------------
  function falling_edge_Z (signal s : std_ulogic) return boolean is
  begin
    if s'event and zsig_to_X01(s) = '0' then
      return true;
    end if;
    return false;
  end function;

  -----------------------------------
  -- START CONDITION
  -----------------------------------
  function start_cond
    (
      signal scl : std_logic;
      signal sda : std_logic
      ) return boolean
  is
  begin
    if falling_edge_Z(sda) and scl = '1' then
      return true;
    end if;
    return false;
  end;

  -----------------------------------
  -- STOP CONDITION
  -----------------------------------
  function stop_cond
    (
      signal scl : std_logic;
      signal sda : std_logic
      ) return boolean
  is
  begin
    if rising_edge_Z(sda) and scl = '1' then
      return true;
    end if;
    return false;
  end;

  -----------------------------------
  -- SEND BIT
  -----------------------------------
  procedure tx_bit
    (
      signal scl        : in  std_logic;
      signal sda        : out std_logic;
      constant bitvalue : in  std_logic
      )
  is
  begin
    sda <= bitvalue;
    wait until rising_edge_Z(scl);
    wait until falling_edge_Z(scl);
    sda <= 'H';
  end;

  -----------------------------------
  -- SEND BYTE (no start, stop...)
  -----------------------------------
  -- XXX UNTESTED
  procedure tx_byte
    (
      signal scl    : inout std_logic;
      signal sda    : out   std_logic;
      constant byte : in    t_byte
      )
  is
    variable bit_cnt : integer range 0 to 7;
  begin
    for bit_cnt in 7 downto 0 loop      -- MSB First
      tx_bit(scl, sda, byte(bit_cnt));
    end loop;
  end;

  -----------------------------------
  -- RECEIVE BYTE (no start, stop...)
  -----------------------------------
  procedure rx_byte
    (
      signal scl    : in  std_logic;
      signal sda    : in  std_logic;
      variable res  : out t_proc_result;
      variable byte : out t_byte
      )
  is
    variable bit_cnt  : integer range 0 to 7;
    variable bitvalue : std_logic;
  begin
    for bit_cnt in 7 downto 0 loop      -- MSB First
      wait until rising_edge_Z(scl);
      bitvalue := zsig_to_X01(sda);
      assert (bitvalue /= 'X') report "unknown bit received" severity warning;
      wait on scl, sda;

      if start_cond(scl, sda) then
        if bit_cnt /= 7 then
          report "Start condition detected during data transfer" severity error;
        end if;
        res := START_COND;
        return;
      elsif stop_cond(scl, sda) then
        if bit_cnt /= 7 then
          report "Stop condition detected during data transfer" severity error;
        end if;
        res := STOP_COND;
        return;
      elsif falling_edge_Z(scl) then
        byte(bit_cnt) := bitvalue;
      else
        report "illegal condition" severity error;
        wait;
      end if;
    end loop;
    res := RX_BYTE;

  end;

  -----------------------------------
  -- SEND ACKNOWLEDGE
  -----------------------------------
  procedure tx_ack
    (
      signal scl : in  std_logic;
      signal sda : out std_logic
      )
  is
  begin
    tx_bit(scl, sda, '0');
  end;

  -----------------------------------
  -- Receive Slave-Address
  -- Ack is not being sent
  -- no Start- and Stop-Cond !
  -----------------------------------
  procedure rx_slave_addr
    (
      signal scl    : in  std_logic;
      signal sda    : in  std_logic;
      variable addr : out t_slv_addr_type;
      variable trx  : out t_data_direction
      )
  is
    variable byte_addr : t_byte;
    variable res       : t_proc_result;
  begin

    rx_byte(scl, sda, res, byte_addr);


    if res = RX_BYTE then

      addr := byte_addr(7 downto 1);

      if byte_addr(0) = '1' then
        trx := READ_DATA;
      elsif byte_addr(0) = '0' then
        trx := WRITE_DATA;
      end if;
    else
      report "Receiving slave address failed" severity error;
    end if;
  end;


begin

  ----------------------------------------------------------------------------
  -- Main Process
  ----------------------------------------------------------------------------
  main : process

    procedure info (constant txt : in string) is
    begin
      if verbose then
        report txt;
      end if;
    end;

    variable state              : t_state   := S_IDLE;
    variable slv_addr           : t_slv_addr_type;
    variable trx                : t_data_direction;
    variable msb_data, lsb_data : t_byte;
    variable res                : t_proc_result;
    variable msb_flag           : std_logic := '0';


  begin
    case state is

      when S_IDLE =>
        msb_flag := '0';
        if start_cond(I2C_SCLK, I2C_SDAT) then
          info ("I2C Start Condition detected");
          state := S_RX_ADDR;
        end if;

      when S_RX_ADDR =>
        msb_flag := '0';
        rx_slave_addr(I2C_SCLK, I2C_SDAT, slv_addr, trx);
        info ("Slave address received");
        tx_ack(I2C_SCLK, I2C_SDAT);
        state    := S_ACTIVE;


      when S_ACTIVE =>
        if trx = WRITE_DATA then
          state := S_RX_DATA;
        elsif trx = READ_DATA then
          state := S_TX_DATA;
        else
          report "unknown data direction" severity error;
        end if;

      when S_RX_DATA =>
        if msb_flag = '0' then
          rx_byte(I2C_SCLK, I2C_SDAT, res, msb_data);
          msb_flag := '1';
        else
          rx_byte(I2C_SCLK, I2C_SDAT, res, lsb_data);
          msb_flag := '0';
          case msb_data(7 downto 1) is  -- compare address and fill data in
            when addr_reg0 => reg_data0 <= "00000000000000000000000" & msb_data(0) & lsb_data;
            when addr_reg1 => reg_data1 <= "00000000000000000000000" & msb_data(0) & lsb_data;
            when addr_reg2 => reg_data2 <= "00000000000000000000000" & msb_data(0) & lsb_data;
            when addr_reg3 => reg_data3 <= "00000000000000000000000" & msb_data(0) & lsb_data;
            when addr_reg4 => reg_data4 <= "00000000000000000000000" & msb_data(0) & lsb_data;
            when addr_reg5 => reg_data5 <= "00000000000000000000000" & msb_data(0) & lsb_data;
            when addr_reg6 => reg_data6 <= "00000000000000000000000" & msb_data(0) & lsb_data;
            when addr_reg7 => reg_data7 <= "00000000000000000000000" & msb_data(0) & lsb_data;
            when addr_reg8 => reg_data8 <= "00000000000000000000000" & msb_data(0) & lsb_data;
            when addr_reg9 => reg_data9 <= "00000000000000000000000" & msb_data(0) & lsb_data;
            when others    => null;
          end case;
        end if;

        case res is
          when START_COND =>
            info ("I2C Repeated Start Condition detected");
            msb_flag := '0';
            state    := S_RX_ADDR;
          when STOP_COND =>
            info ("I2C Stop Condition detected");
            msb_flag := '0';
            state    := S_IDLE;
          when RX_BYTE =>
            info ("Byte received");
            tx_ack(I2C_SCLK, I2C_SDAT);
            state := S_ACTIVE;

          when others =>
            report "Illegal condition occurred" severity error;
        end case;


      when S_TX_DATA =>
        report "Transmitting data not implemented" severity error;
        wait;

      when others =>
        report "Illegal condition: we should never get here" severity error;
        wait;

    end case;

    wait on I2C_SCLK, I2C_SDAT;

  end process;

end architecture;
