-------------------------------------------------------------------------------
-- Title      : standard_driver_pkg
-- Project    : DTP2
-------------------------------------------------------------------------------
-- File       : standard_driver_pkg.vhd
-- Author     : Hans-Joachim Gelke
-- Company    : 
-- Created    : 2018-10-21
-- Last update: 2019-2-13
-- Platform   : 
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Standard Driver for DTP2 Simulation
-------------------------------------------------------------------------------
-- Copyright (c) 2018 - 2019
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-02-13  1.0      Hans-Joachim    Created
-- 2019-03-03  1.1      Hans-Joachim    Extended timing for i2C simulation
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.simulation_pkg.all;

package standard_driver_pkg is


  procedure rst_sim
    (
      variable tv    : inout test_vect;
      signal reset_n : out   std_logic

      );

  procedure run_sim
    (
      variable tv : inout test_vect

      );

  procedure gpo_chk
    (
      variable tv   : inout test_vect;
      signal in_sig : in    std_logic_vector(31 downto 0)

      );

  procedure gpi_sim
    (
      variable tv    : inout test_vect;
      signal out_sig : out   std_logic_vector(31 downto 0)
      );

  procedure uar_sim
    (
      variable tv   : inout test_vect;
      signal tx_sig : out   std_logic
      );

  procedure hex_chk
    (
      variable tv  : inout test_vect;
      signal seg_o : in    std_logic_vector(6 downto 0)
      );

  procedure i2s_chk
    (
      variable tv     : inout test_vect;
      signal ws       : in    std_logic;
      signal bclk     : in    std_logic;
      signal dacdat_s : in    std_logic;
      signal obs_data : out   std_logic_vector(31 downto 0)
      );

  procedure ini_cod
    (
      variable tv             : inout test_vect;
      signal codec_mode       : out   std_logic_vector(2 downto 0);
      signal codec_initialize : out   std_logic
      );

  procedure i2s_sim
    (
      variable tv    : inout test_vect;
      signal ws      : in    std_logic;
      signal bclk    : in    std_logic;
      signal acdat_s : out   std_logic
      );

end package standard_driver_pkg;

package body standard_driver_pkg is

  constant baud_period_31_250      : time := 32 us;    -- Baud Rate Midi
  constant baud_period_115_200_000 : time := 8.68 us;  -- Baud Rate Bluetooth


  -------------------------------------
  -- Reset
  -------------------------------------

  procedure rst_sim
    (
      variable tv    : inout test_vect;
      signal reset_n : out   std_logic
      ) is

    variable line_out : line;           -- Line buffers

  begin
    reset_n <= '0';
    wait for (to_integer(unsigned(tv.arg1)))*(tv.clock_period);  -- wait for arg1 clock_periods
    reset_n <= '1';


    write(line_out, string'("LOGIC HAS BEEN RESET FOR "));
    write(line_out, (to_integer(unsigned(tv.arg1)))*(tv.clock_period));
    writeline(OUTPUT, line_out);        -- write the message

  end procedure rst_sim;

  -------------------------------------
  -- Run100
  -------------------------------------

  procedure run_sim
    (
      variable tv : inout test_vect
      ) is

    variable line_out     : line;       -- Line buffers
    variable sim_duration : std_logic_vector(31 downto 0) := (others => '0');

  begin
    sim_duration := tv.arg1 & tv.arg2 & tv.arg3 & tv.arg4;
    wait for to_integer(unsigned(sim_duration))*tv.clock_period;  -- wait for sim_duration clock_periods


    write(line_out, string'("SIMULATED FOR "));
    hwrite(line_out, sim_duration);
    write(line_out, string'(" CLOCKS"));
    writeline(OUTPUT, line_out);        -- write the message

  end procedure run_sim;

  -------------------------------------
  -- GPIO Set
  -------------------------------------

  procedure gpi_sim
    (
      variable tv    : inout test_vect;
      signal out_sig : out   std_logic_vector(31 downto 0)
      ) is

    variable line_out : line;           -- Line buffers

  begin
    out_sig(31 downto 24) <= tv.arg1(7 downto 0);
    out_sig(23 downto 16) <= tv.arg2(7 downto 0);
    out_sig(15 downto 8)  <= tv.arg3(7 downto 0);
    out_sig(7 downto 0)   <= tv.arg4(7 downto 0);


    write(line_out, string'("HEX VALUE "));
    hwrite(line_out, tv.arg1);
    hwrite(line_out, tv.arg2);
    hwrite(line_out, tv.arg3);
    hwrite(line_out, tv.arg4);
    write(line_out, string'(" APPLIED to DUT"));
    writeline(OUTPUT, line_out);        -- write the message
  end gpi_sim;


  -------------------------------------
  -- GPIO Check
  -------------------------------------

  procedure gpo_chk
    (
      variable tv   : inout test_vect;
      signal in_sig : in    std_logic_vector(31 downto 0)

      ) is

    variable line_out : line;           -- Line buffers

  begin
    if tv.arg1 = in_sig(31 downto 24) and
      tv.arg2 = in_sig(23 downto 16) and
      tv.arg3 = in_sig(15 downto 8) and
      tv.arg4 = in_sig(7 downto 0)

    then
      tv.fail_flag := false;
      hwrite(line_out, tv.arg1);
      hwrite(line_out, tv.arg2);
      hwrite(line_out, tv.arg3);
      hwrite(line_out, tv.arg4);
      write(line_out, string'(" RETURNED FROM DUT, O.K. "));
      writeline(OUTPUT, line_out);      -- write the message
    else
      tv.fail_flag := true;
      write(line_out, string'("ERROR: COMPARE FAILED. SIGNALS RETURNED "));
      hwrite(line_out, in_sig);
      write(line_out, string'(" SIGNALS EXPECTED "));
      hwrite(line_out, tv.arg1);
      hwrite(line_out, tv.arg2);
      hwrite(line_out, tv.arg3);
      hwrite(line_out, tv.arg4);
      writeline(OUTPUT, line_out);
    end if;

  end gpo_chk;

  procedure uar_sim
    (
      variable tv   : inout test_vect;
      signal tx_sig : out   std_logic
      ) is

    variable line_out    : line;        -- Line buffers
    variable baud_period : time      := 8.68 us;
    variable stop_bit    : std_logic := '0';

  begin
    -- arg2 = 1 Baud rate is 31_250 (midi)
    if tv.arg2 = std_logic_vector(to_unsigned(1, 8)) then
      baud_period := baud_period_31_250;
    else
      baud_period := baud_period_115_200_000;
    end if;

    -- If arg3 is '1' the Stop bit will not be sent correctly
    if tv.arg3 = std_logic_vector(to_unsigned(1, 8)) then
      stop_bit := '0';
    else
      stop_bit := '1';
    end if;

    tx_sig <= '1';  -- set tx signal to one inbetween transmissions
    wait for 2* baud_period;

    tx_sig <= '0';                      -- This is the start bit
    wait for baud_period;               --Apply start bit for one baud period
    txloop : for i in 0 to 7 loop       --Transmit eight Bytes
      tx_sig <= tv.arg1(i);
      wait for baud_period;
    end loop txloop;

    tx_sig <= stop_bit;                 -- This is the stop bit
    wait for baud_period;
    tx_sig <= '1';                      -- Pull Signal high for next start bit

    hwrite(line_out, tv.arg1);
    write(line_out, string'(" SENT TO DUT"));
    writeline(OUTPUT, line_out);        -- write the message
    --writeline(outfile,line_out);

  end procedure uar_sim;

  procedure hex_chk
    (
      variable tv  : inout test_vect;
      signal seg_o : in    std_logic_vector(6 downto 0)
      ) is

    variable line_out : line;           -- Line buffers

    constant display_0     : std_logic_vector(6 downto 0) := "1000000";
    constant display_1     : std_logic_vector(6 downto 0) := "1111001";
    constant display_2     : std_logic_vector(6 downto 0) := "0100100";
    constant display_3     : std_logic_vector(6 downto 0) := "0110000";
    constant display_4     : std_logic_vector(6 downto 0) := "0011001";
    constant display_5     : std_logic_vector(6 downto 0) := "0010010";
    constant display_6     : std_logic_vector(6 downto 0) := "0000010";
    constant display_7     : std_logic_vector(6 downto 0) := "1111000";
    constant display_8     : std_logic_vector(6 downto 0) := "0000000";
    constant display_9     : std_logic_vector(6 downto 0) := "0010000";
    constant display_A     : std_logic_vector(6 downto 0) := "0001000";
    constant display_B     : std_logic_vector(6 downto 0) := "0000011";
    constant display_C     : std_logic_vector(6 downto 0) := "1000110";
    constant display_D     : std_logic_vector(6 downto 0) := "0100001";
    constant display_E     : std_logic_vector(6 downto 0) := "0000110";
    constant display_F     : std_logic_vector(6 downto 0) := "0001110";
    constant display_blank : std_logic_vector(6 downto 0) := (others => '1');

    variable hex_value : natural range 0 to 17;

  begin

    case seg_o is
      when display_0     => hex_value := 00;
      when display_1     => hex_value := 01;
      when display_2     => hex_value := 02;
      when display_3     => hex_value := 03;
      when display_4     => hex_value := 04;
      when display_5     => hex_value := 05;
      when display_6     => hex_value := 06;
      when display_7     => hex_value := 07;
      when display_8     => hex_value := 08;
      when display_9     => hex_value := 09;
      when display_A     => hex_value := 10;
      when display_B     => hex_value := 11;
      when display_C     => hex_value := 12;
      when display_D     => hex_value := 13;
      when display_E     => hex_value := 14;
      when display_F     => hex_value := 15;
      when display_blank => hex_value := 16;
      when others        => hex_value := 17;
    end case;


    if (tv.arg1(7 downto 0) = std_logic_vector(to_unsigned(hex_value, 8))) then
      tv.fail_flag := false;
      write(line_out, string'("DISPLAY OUTPUT O.K., received 0x"));
      hwrite(line_out, tv.arg1);
      writeline(OUTPUT, line_out);      -- write the message
    --writeline(outfile,line_out);
    else
      tv.fail_flag := true;
      write(line_out, string'("ERROR: Received: 0x"));
      hwrite(line_out, std_logic_vector(to_unsigned(hex_value, 8)));
      write(line_out, string'(" Expected: 0x"));
      hwrite(line_out, tv.arg1);
      writeline(OUTPUT, line_out);
    --writeline(outfile,line_out);
    end if;


  end procedure hex_chk;

  -----------------------------------------------------------------------------
  -- I2S BFM Serial Receive
  -----------------------------------------------------------------------------
  procedure i2s_chk
    (
      variable tv     : inout test_vect;
      signal ws       : in    std_logic;
      signal bclk     : in    std_logic;
      signal dacdat_s : in    std_logic;
      signal obs_data : out   std_logic_vector(31 downto 0)
      ) is

    variable line_out     : line;
    variable dacdat_reg_l : std_logic_vector(15 downto 0);
    variable dacdat_reg_r : std_logic_vector(15 downto 0);

  begin
    wait until ws = '0';
    wait until bclk = '1';
    wait until bclk = '0';
    wait until bclk = '1';
    for abit in 15 downto 0 loop
      dacdat_reg_l(abit)     := dacdat_s;
      obs_data(31 downto 16) <= dacdat_reg_l;
      wait until bclk = '0';
      wait until bclk = '1';

    end loop;  -- abit

    wait until ws = '1';
    wait until bclk = '1';
    wait until bclk = '0';
    wait until bclk = '1';
    for abit in 15 downto 0 loop
      dacdat_reg_r(abit)    := dacdat_s;
      obs_data(15 downto 0) <= dacdat_reg_r;
      wait until bclk = '0';
      wait until bclk = '1';
    end loop;

    if (
      (tv.arg1(7 downto 0) = dacdat_reg_l(15 downto 8)) and
      (tv.arg2(7 downto 0) = dacdat_reg_l(7 downto 0)) and
      (tv.arg3(7 downto 0) = dacdat_reg_r(15 downto 8)) and
      (tv.arg4(7 downto 0) = dacdat_reg_r(7 downto 0))
      ) then
      tv.fail_flag := false;
      write(line_out, string'("AUDIO DATA RECEIVED BY CODEC, O.K. "));
      hwrite(line_out, tv.arg1);
      hwrite(line_out, tv.arg2);
      hwrite(line_out, tv.arg3);
      hwrite(line_out, tv.arg4);
      writeline(OUTPUT, line_out);      -- write the message
    --writeline(outfile,line_out);
    else
      tv.fail_flag := true;
      write(line_out, string'("ERROR:CODEC RECEIVED WRONG AUDIO DATA "));
      hwrite(line_out, dacdat_reg_l & dacdat_reg_r);
      write(line_out, string'(" EXPECTED "));
      hwrite(line_out, tv.arg1);
      hwrite(line_out, tv.arg2);
      hwrite(line_out, tv.arg3);
      hwrite(line_out, tv.arg4);
      writeline(OUTPUT, line_out);
    --writeline(outfile,line_out);
    end if;


  end procedure i2s_chk;

  procedure ini_cod
    (
      variable tv             : inout test_vect;
      signal codec_mode       : out   std_logic_vector(2 downto 0);
      signal codec_initialize : out   std_logic
      ) is

    variable line_out : line;           -- Line buffers



  begin
    codec_initialize <= '1';
    codec_mode       <= tv.arg1(2 downto 0);
    wait for 8*tv.clock_period;

    codec_initialize <= '0'; -- activate initialize signal
    wait for 4*tv.clock_period; --for one 12.5MHz cycle
    codec_initialize <= '1';

    wait for 48000 * tv.clock_period; -- Run simulation to the end

  end procedure ini_cod;

  -----------------------------------------------------------------------------
  -- I2S Stimuli Sends Serial Data to I2S s2p FIFO
  -----------------------------------------------------------------------------

  procedure i2s_sim
    (
      variable tv    : inout test_vect;
      signal ws      : in    std_logic;
      signal bclk    : in    std_logic;
      signal acdat_s : out   std_logic
      ) is

    variable line_out : line;           -- Line buffers

  begin
    acdat_s <= 'X';                     -- set i2s to undefined value
    wait until ws = '0';                --wait until falling edge of ws signals
    wait until bclk = '1';
    wait until bclk = '0';
    --beginn of left channel transmit
    i2sloop1 : for i in 7 downto 0 loop  --transmit MSB left channel
      acdat_s <= tv.arg1(i);
      wait until bclk = '1';
      wait until bclk = '0';
    end loop i2sloop1;

    i2sloop2 : for i in 7 downto 0 loop  --transmit LSB left channel
      acdat_s <= tv.arg2(i);
      wait until bclk = '1';
      wait until bclk = '0';
    end loop i2sloop2;
    acdat_s <= 'X';
    wait until ws = '1';
    wait until bclk = '1';
    wait until bclk = '0';
    i2sloop3 : for i in 7 downto 0 loop  --transmit MSB right channel
      acdat_s <= tv.arg3(i);
      wait until bclk = '1';
      wait until bclk = '0';
    end loop i2sloop3;

    i2sloop4 : for i in 7 downto 0 loop  --transmit LSB right channel
      acdat_s <= tv.arg4(i);
      wait until bclk = '1';
      wait until bclk = '0';
    end loop i2sloop4;
    acdat_s <= 'X';         --set i2s to undefined value after transmit
    wait until bclk = '1';  --wait one more bclk cycle until data is
    wait until bclk = '0';  --in shift register before going to next
--command, which might be a compare

    hwrite(line_out, tv.arg1);
    hwrite(line_out, tv.arg2);
    hwrite(line_out, tv.arg3);
    hwrite(line_out, tv.arg4);
    write(line_out, string'(" WRITTEN TO I2S BUS(CODEC ANALOG OUT) "));
    writeline(OUTPUT, line_out);        -- write the message
    --writeline(outfile,line_out);

  end procedure i2s_sim;


end package body standard_driver_pkg;
