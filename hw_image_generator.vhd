--------------------------------------------------------------------------------
--
--   FileName:         hw_image_generator.vhd
--   Dependencies:     none
--   Design Software:  Quartus Prime 16.1 lite
--			Previously:	Quartus II 64-bit Version 12.1 Build 177 SJ Full Version
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
--	  Later Versions: 12/18 Cade Doebele
--    Component of ball_game, and modifications from the original 
--		are covered under MIT License .
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

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

	constant paddle_width	: integer := 10;
	constant	paddle_height	: integer := 120;
	constant	ball_size		: integer := 20;
	constant h_pixels			: integer := 800;
	constant v_pixels			: integer := 600;

	signal ballx : integer;
	signal bally : integer;
	signal paddle_L : integer;
	signal paddle_R : integer;
	
	signal score1 : integer;
	signal score2 : integer;
	
	component game
		port (
			ball_xpos	: out	integer;
			ball_ypos	: out	integer;
			paddle_Lpos	: out	integer;
			paddle_Rpos	: out integer;
			clk			: in	std_logic
				);
	end component;

BEGIN

	main : game --instatiate the game component.
		port map (ballX,ballY,paddle_L,paddle_R,clk);
	
	
	PROCESS(disp_ena, row, column, clk)
	BEGIN
		IF(disp_ena = '1') THEN		--display time
		
	--render the game elements
	
		--render the purple ball
			if(ballx < row AND row < ballx + ball_size AND 
				bally < column AND column < bally + ball_size)
			then 
				red <= (others => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
		--render the left blue paddle
			elsif(row < paddle_width AND 
					paddle_L < column AND column < paddle_L + paddle_height)
			then 
				red <= (others => '0');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
		--render the right red paddle
			elsif(h_pixels - paddle_width < row AND
					paddle_R < column AND column < paddle_R + paddle_height)
			then
				red <= (others => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
		
		--render the teal background
			ELSE 
				red <= (OTHERS => '0');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
			END IF;
			
			
		ELSE								--blanking time
			red <= (OTHERS => '0');
			green <= (OTHERS => '0');
			blue <= (OTHERS => '0');
		END IF;
	
	END PROCESS;
	
	
END behavior;