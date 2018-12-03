--------------------------------------------------------------------------------
--
--   FileName:         hw_image_generator.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 64-bit Version 12.1 Build 177 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 05/10/2013 Scott Larson
--     Initial Public Release
--    
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY hw_image_generator IS
	GENERIC(
		pixels_y :	INTEGER := 60;    --row that first color will persist until
		pixels_x	:	INTEGER := 40);   --column that first color will persist until
	PORT(
		clk			:	IN		STD_LOGIC;	--50MHz input clock, used for timing 
		disp_ena		:	IN		STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
		row			:	IN		INTEGER;		--row pixel coordinate
		column		:	IN		INTEGER;		--column pixel coordinate
		red			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS

signal loc : integer := 0;
signal delay : integer := 0;

BEGIN
	PROCESS(disp_ena, row, column, clk)
	BEGIN
		IF(disp_ena = '1') THEN		--display time
			IF(row < pixels_y AND column < pixels_x) THEN --blue square
				red <= (OTHERS => '0');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(row < pixels_y XOR column < pixels_x) THEN --teal boxes
				red <= (OTHERS => '0');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
			ELSIF(row > pixels_y AND row < 120 AND column < 120 AND column > pixels_x) THEN --red bars
				IF(row < loc and column < loc) THEN	--purple space
					red <= (OTHERS => '1');
					green	<= (OTHERS => '0');
					blue <= (OTHERS => '1');
				ELSE
					red <= (OTHERS => '1');
					green	<= (OTHERS => '0');
					blue <= (OTHERS => '0');
				END IF;
			--END IF; -- error location
			ELSE 									--yellow space
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '0');
			END IF;
		--END IF;
		ELSE								--blanking time
			red <= (OTHERS => '0');
			green <= (OTHERS => '0');
			blue <= (OTHERS => '0');
		END IF;
	
	END PROCESS;
	
	
	PROCESS(clk)
	BEGIN
		IF (clk'EVENT AND clk = '1')	THEN
			IF(delay = 0) THEN 			--Delay will equal zero at 5Hz.
				IF(loc > 120) THEN
					loc <= 20;
					delay <= 0;
				ELSE
					loc <= loc + 1;
				END IF;
			END IF;
			
			IF(delay < 5000000) THEN
				delay <= delay + 1;
			ELSE
				DELAY <= 0;	
			END IF;
		END IF;
	END PROCESS;
	
END behavior;