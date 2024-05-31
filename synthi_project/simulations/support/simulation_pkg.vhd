-------------------------------------------------------------------------------
-- Title      : simulation_pkg
-- Project    : PM2
-------------------------------------------------------------------------------
-- File       : simulation_pkg.vhd
-- Author     : Hans-Joachim Gelke
-- Company    : 
-- Created    : 2018-10-21
-- Last update: 2024-05-31
-- Platform   : 
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Simulation Support for PM2 Simulation
-------------------------------------------------------------------------------
-- Copyright (c) 2018 - 2020
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-02-13  1.0      Hans-Joachim    Created
-- 2019-03-03  1.1      Hans-Joachim    Extended timing for i2C simulation
-- 2020-02-11  2.0      Hans-Joachim    Reports failing line in testcase.cmd

-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use std.env.all;

package simulation_pkg is

  file cmdfile : text;                  -- Define the file 'handle'
  file outfile : text;                  -- Define the file 'handle'


  type test_vect is record
    arg1         : std_logic_vector(7 downto 0);
    arg2         : std_logic_vector(7 downto 0);
    arg3         : std_logic_vector(7 downto 0);
    arg4         : std_logic_vector(7 downto 0);
    obs_data     : std_logic_vector(31 downto 0);
    fail_flag    : boolean;
    clock_period : time;

  end record;

  procedure end_simulation
    (
      variable fail_counter : in integer range 0 to 20000
      );

  procedure read_arguments
    (
      variable lincnt  : in    integer;
      variable tv      : out   test_vect;
      variable line_in : inout line;
      variable cmd     : out   line
      );

  function str_compare(str1 : string; str2 : string) return boolean;


end simulation_pkg;

package body simulation_pkg is

  -------------------------------------
  -- End Simulation
  -------------------------------------

  procedure end_simulation
    (
      variable fail_counter : in integer range 0 to 20000
      ) is

    variable line_out : line;

  begin
    if fail_counter = 0 then
      write(line_out, string'(" CONGRATULATIONS ALL TESTS PASS "));
      writeline(OUTPUT, line_out);      -- write the message
      writeline(outfile, line_out);
      --report "Succesfull end of Verification Tests";
      stop(0);
    else

      write(line_out, string'("ERRORS IN SIMULATION: Simulation found "));
      write(line_out, fail_counter);
      write(line_out, string'(" failures "));
      writeline(OUTPUT, line_out);      -- write the message
      writeline(outfile, line_out);
      --report "=== ERRORS in TESTS ====";
      stop(0);

    end if;
  end end_simulation;

  -----------------------------------------------------------------------------
  -- String compare
  -----------------------------------------------------------------------------
  function str_compare(str1 : string; str2 : string) return boolean is
    variable match    : boolean := true;
    variable line_out : line;
  begin
    for i in str1'range loop
      if (str1(i) = str2(i)) and match = true then
        match := true;
      else
        match := false;
      end if;
    end loop;
    return match;
    report str1;
    report str2;
  end function str_compare;

  -------------------------------------
  -- Read Arguments
  -------------------------------------

  procedure read_arguments
    (
      variable lincnt  : in    integer;
      variable tv      : out   test_vect;
      variable line_in : inout line;
      variable cmd     : out   line
      ) is

    variable good       : boolean;
    variable linelength : integer range 0 to 100;
    variable line_out   : line;
    variable cmd_length : integer range 0 to 100;
    variable line_out2  : line;
    -- variable lincnt  : integer;


  begin
    linelength := line_in'length;

    for i in line_in'range loop
      if line_in.all(i) = ' ' then
        cmd_length := i - 1;
        exit;
      end if;
    end loop;

    if cmd_length = 0 then
      write(line_out2, string'("!!!!! LINE NO: "));
      write(line_out2, lincnt);
      write(line_out2, string'(" No command found"));
      writeline(outfile, line_out2);

      report "No command found. Line: " & natural'image(lincnt)
        severity error;
    end if;

    cmd := new string(1 to cmd_length);

    read(line_in, cmd.all, good);       -- Read the command
    assert good
      report "COMMAND NAME MUST HAVE EXACTLY 7 CHARACTERS, ARGUMENTS ONE BYTE. CHECK IN 'testcase.dat' LINE: "& integer'image(lincnt)
      severity error;

    linelength := line_in'length;  -- checks wether there are more arguments in the line
    if linelength > 2 then  --at least 2 characters must be left in the line
      hread(line_in, tv.arg1, good);    -- Read 
      assert good
        report "COMMAND NAME MUST HAVE EXACTLY 7 CHARACTERS, ARGUMENTS ONE BYTE. CHECK IN 'testcase.dat' LINE: "& integer'image(lincnt)
        severity error;
    end if;

    linelength := line_in'length;  -- checks wether there are more arguments in the line
    if linelength > 2 then  --at least 2 characters must be left in the line
      hread(line_in, tv.arg2, good);    -- Read 
      assert good
        report "COMMAND NAME MUST HAVE EXACTLY 7 CHARACTERS, ARGUMENTS ONE BYTE. CHECK IN 'testcase.dat' LINE: "& integer'image(lincnt)
        severity error;
    end if;

    linelength := line_in'length;  -- checks wether there are more arguments in the line
    if linelength > 2 then  --at least 2 characters must be left in the line
      hread(line_in, tv.arg3, good);    -- Read 
      assert good
        report "COMMAND NAME MUST HAVE EXACTLY 7 CHARACTERS, ARGUMENTS ONE BYTE. CHECK IN 'testcase.dat' LINE: "& integer'image(lincnt)
        severity error;
    end if;

    linelength := line_in'length;  -- checks wether there are more arguments in the line
    if linelength > 2 then  --at least 2 characters must be left in the line
      hread(line_in, tv.arg4, good);    -- Read 

      assert good
        report "COMMAND NAME MUST HAVE EXACTLY 7 CHARACTERS, ARGUMENTS ONE BYTE. CHECK IN 'testcase.dat' LINE: "& integer'image(lincnt)
        severity error;
    end if;


  end read_arguments;

end simulation_pkg;
