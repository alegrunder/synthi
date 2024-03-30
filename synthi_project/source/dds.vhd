-------------------------------------------------------------------------------
-- Title      : DDS
-- Project    : 
-------------------------------------------------------------------------------
-- File       : dds.vhd
-- Author     : doblesam
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
-- Date        Version  Author  Description
-- 2024-03-26  1.0      marku	Created
-------------------------------------------------------------------------------


library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library work;
	use work.tone_gen_pkg.all;
	

entity dds is
  
  port (
    clk         : in std_logic;
    reset_n     : in std_logic;
    phi_incr_i  : in std_logic_vector(18 downto 0);
    tone_on_i   : in std_logic;
    step_i      : in std_logic;
    attenu_i    : in std_logic_vector(6 downto 0);
    dds_o       : out std_logic_vector(15 downto 0)
    );
end entity dds;

architecture dds_arch of dds is

 signal count, next_count : unsigned(N_CUM-1 downto 0);
 
   

begin  -- architecture dds_arch
 

 phase_counter_logic:PROCESS(all) is
   VARIABLE lut_val :   signed(N_AUDIO-1 downto 0);
	VARIABLE lut_addr :  integer range 0 to L-1;
	VARIABLE atte :   integer range -64 to 64;
 begin


   lut_addr := to_integer(count(N_CUM-1 downto N_CUM - N_LUT));
   lut_val := to_signed(LUT(lut_addr),N_AUDIO);
	
	atte := to_integer(unsigned(attenu_i));
	
	case atte is
		when 0 => dds_o <= std_logic_vector(lut_val);
		when 1 => dds_o <= std_logic_vector(shift_right(lut_val,1));
		when 2 => dds_o <= std_logic_vector(shift_right(lut_val,2));
		
		when others => dds_o <= std_logic_vector(shift_right(lut_val,3));
	end case;

 end process phase_counter_logic;

 proc_input_comb: process (all) is
 begin  -- process proc_input_comb
    if  (step_i = '1') then
      next_count <= count + unsigned(phi_incr_i);
    else
      next_count <= count;
    end if;
	 
end process proc_input_comb;
  
 flip_flops : PROCESS(all)
  BEGIN	
  	IF reset_n = '0' THEN
		count <= to_unsigned(0,N_CUM); -- convert integer value 0 to unsigned with 4bits
		
    ELSIF falling_edge(clk) THEN
		count <= next_count ;
    END IF;
  END PROCESS flip_flops;
  
end architecture dds_arch;
