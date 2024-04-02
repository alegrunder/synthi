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
    control	  	 : in std_logic; -- used for control commands
    control_reg1 : in std_logic_vector(6 downto 0); -- used for control commands
    attenu_i    : in std_logic_vector(6 downto 0);
    dds_o       : out std_logic_vector(15 downto 0)
    );
end dds;

architecture dds_arch of dds is

 signal count, next_count : unsigned(N_CUM-1 downto 0);
 
 constant AVERAGE_BUFFER :				natural := 6; 
   

begin  -- architecture dds_arch

 

 phase_counter_logic:PROCESS(all) is
	VARIABLE lut_val :   signed(N_AUDIO-1 downto 0);
   VARIABLE lut_val_sin :   signed(N_AUDIO-1+AVERAGE_BUFFER downto 0);
	VARIABLE lut_val_rec :   signed(N_AUDIO-1+AVERAGE_BUFFER downto 0);
	VARIABLE lut_val_saw :   signed(N_AUDIO-1+AVERAGE_BUFFER downto 0);
	VARIABLE lut_addr :  integer range 0 to L-1;
	VARIABLE atte :   integer range -64 to 64;
	VARIABLE Wavetable_switch : integer range 127 downto 0; 
 begin


   lut_addr := to_integer(count(N_CUM-1 downto N_CUM - N_LUT));
   ----------------------------------------------------------------
	-- Wavetable
	----------------------------------------------------------------
	
	-- Sinus
	lut_val_sin := to_signed(LUT(lut_addr),N_AUDIO+AVERAGE_BUFFER);
	
	-- Rectangle
	if lut_addr > 127 then
		lut_val_rec := to_signed(4095,N_AUDIO+AVERAGE_BUFFER);
	else
		lut_val_rec := to_signed(-4096,N_AUDIO+AVERAGE_BUFFER);
	end if;
	
	-- Sawtooth
	lut_val_saw := to_signed((lut_addr*32)-4095,N_AUDIO+AVERAGE_BUFFER);
	
	-- Switching logic
	if control = '1' then
		if control_reg1 = "0001110" then
			Wavetable_switch := to_integer(unsigned(attenu_i));
		end if;
	end if;
	
	if Wavetable_switch < 64 then
		lut_val := shift_right((lut_val_sin * Wavetable_switch) + (lut_val_rec * (64-Wavetable_switch)),6)(N_AUDIO-1 downto 0);
	else
		lut_val := shift_right((lut_val_saw * (Wavetable_switch -64)) + (lut_val_sin*(64-(Wavetable_switch -64))),6)(N_AUDIO-1 downto 0);
	end if;
	
	
	-- Attenuation logic:
	if control = '0' then
		atte := to_integer(unsigned(attenu_i));
		
		case atte is
			when 0 => dds_o <= std_logic_vector(shift_right(lut_val,3));
			when 1 => dds_o <= std_logic_vector(shift_right(lut_val,2));
			when 2 => dds_o <= std_logic_vector(shift_right(lut_val,1));
			
			when others => dds_o <= std_logic_vector(lut_val);
		end case;
	end if;
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
  	IF reset_n = '0' or tone_on_i = '0' THEN
		count <= to_unsigned(0,N_CUM); -- convert integer value 0 to unsigned with 4bits
		
    ELSIF rising_edge(clk) THEN
		count <= next_count ;
    END IF;
  END PROCESS flip_flops;
  
end architecture dds_arch;
