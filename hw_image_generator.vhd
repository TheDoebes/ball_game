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
		button0		:	IN		STD_LOGIC;
		button1		:	IN		STD_LOGIC;
		button2		:	IN		STD_LOGIC;
		button3		:	IN		STD_LOGIC;

		red			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); --blue magnitude output to DAC
		seg1			:	out	std_logic_vector(6 downto 0) := (others => '1');
		seg2			:	out	std_logic_vector(6 downto 0) := (others => '1')
		);
		
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS

	constant paddle_width	: integer := 10;
	constant	paddle_height	: integer := 120;
	constant	ball_size		: integer := 20;
	constant h_pixels			: integer := 800;
	constant v_pixels			: integer := 600;
--	constant max_score		: integer := 9;
	constant clk_period		: integer := 20;

	--Coordingates of the top-left coordinate (read, smallest) of the square ball.
	signal ballx : integer := h_pixels/2;
	signal bally : integer := v_pixels/2;
	
	--Current vertical coordinates of the tops of the left and right paddles.
	signal paddle_L : integer := v_pixels/2 - paddle_height/2;
	signal paddle_R : integer := v_pixels/2 - paddle_height/2;
	
	--Counters
--	signal score1	: integer :=0;
--	signal score2	: integer :=0;
	
	signal delay	: integer :=0;
	
	--Game state machine
	signal reset		: std_logic :='1';
	signal ball_reset : std_logic :='1';
	signal moveX		: std_logic :='0';
	signal moveY		: std_logic :='0';
	signal tick			: std_logic :='1';
	
	signal b0,b1,b2,b3	: std_logic;
	
	--Score to seven-segment signals
	signal i1	: std_logic_vector(3 downto 0) := (others => '0');
	signal i2	: std_logic_vector(3 downto 0) := (others => '0');



BEGIN

	b2 <= button0;
	b3 <= button1;
	b0 <= button2;	--deliberately swapped to position them on left and right
	b1 <= button3;
	

	tickRate:process(clk)
		BEGIN
			if(clk'event AND clk = '1') then
				if(delay = clk_period*5*1000) then
					delay <= 0;
					tick	<= NOT tick;
				else
					delay <= delay + 1;
				END if;
			END if;
		END process; --tickRate

	mechanics:process(ballx, bally, movex, movey, reset, ball_reset, tick, paddle_L, paddle_R)--score1, score2, 
	BEGIN
	

		
--	--Win condition logic
--		if(score1 = max_score) then
--		--player 1 wins
--		
--		elsif(score2 = max_score) then
--		--player 2 wins
--		
--		END if; --then continue play normally

		if(tick'event AND tick = '1') then
	--Movement Logic
			if(moveX = '1') then
				ballx <= ballx + 1;
			else
				ballx <= ballx - 1;
			END if;
			if(moveY = '1') then
				bally <= bally + 1;
			else
				bally <= bally - 1;
			END if;
			if(b0 = '1' AND b1 = '0' AND paddle_L + paddle_height <= v_pixels) then
				paddle_L <= paddle_L + 1;
			elsif(b0 = '0' AND b1 = '1' AND paddle_L >= 0 ) then
				paddle_L <= paddle_L - 1;
			END if;
			if(b2 = '1' AND b3 = '0' AND paddle_R + paddle_height <= v_pixels) then
				paddle_R <= paddle_R + 1;
			elsif(b2 = '0' AND b3 = '1' AND paddle_R >= 0) then
				paddle_R <= paddle_R - 1;
			END if;
				
			
	--Score Logic
			if(ballx <= 0) then 
			--player 2 scores
--				score2 <= score2 + 1;
				i2 <= std_logic_vector( unsigned(i2) + 1 );
				ball_reset <= '1';
			elsif(ballx >= h_pixels) then 
			--player 1 scores
--				score1 <= score1 + 1;
				i1 <= std_logic_vector( unsigned(i1) + 1 );
				ball_reset <= '1';
			END if; --ball is in play
			
	--reset logic, trigger on game start and at the end of win seqeunce.
			if(reset = '1') then
			--reset the game state
				ball_reset <= '1';
--				score1 <= 0;
--				score2 <= 0;
				i1 <= (others => '0');
				i2 <= (others => '0');
				reset <= '0';
			End if;
			if(ball_reset = '1') then
			--the ball has scored, and should be moved to the starting location
				ballx <= h_pixels/2;
				bally <= v_pixels/2;
				ball_reset <= '0';
				--i1 <= std_logic_vector(to_unsigned(score1, i1'length));
				--i2 <= std_logic_vector(to_unsigned(score1, i2'length));
				seg1(0) <= not ((not i1(0) and i1(2)) or (not i1(1) and not i1(3)) or ( not i1(0) and i1(1) and i1(3)) or ( i1(0) and i1(1) and i1(2)) or (i1(0) and i1(1) and not i1(3)) or (i1(0) and not i1(1) and not i1(2)) or (i1(0) and not i1(1) and not i1(2) and i1(3)));
				seg1(1) <= not ((not i1(0) and not i1(1)) or (not i1(0) and not i1(2) and not i1(3)) or (not i1(0) and i1(2) and i1(3)) or(i1(0) and not i1(2) and i1(3)) or (i1(0) and not i1(1) and not i1(3)));
				seg1(2) <= not ((not i1(0) and not i1(2)) or (not i1(0) and i1(1)) or (not i1(0) and i1(2) and i1(3)) or (i1(0) and not i1(1)) or (i1(0) and not i1(2) and i1(3)));
				seg1(3) <= not ((not i1(0) and not i1(1) and not i1(3)) or (not i1(1) and i1(2) and i1(3)) or (i1(1) and i1(2) and not i1(3)) or (i1(1) and not i1(2) and i1(3)) or (i1(0) and not i1(2)));
				seg1(4) <= not ((i1(0) and i1(1)) or (i1(0) and i1(2)) or (i1(2) and not i1(3)) or (not i1(1) and not i1(3)));
				seg1(5) <= not ((not i1(0) and i1(1) and not i1(2)) or (not i1(0) and i1(1) and not i1(3)) or (not i1(2) and not i1(3)) or (i1(0) and not i1(1)) or (i1(0) and i1(1) and i1(2)));
				seg1(6) <= ((not i1(0) and not i1(1) and not i1(2)) or (not i1(0) and i1(1) and i1(2) and i1(3)) or(i1(0) and i1(1) and not i1(2) and not i1(3)));
				
				seg2(0) <= not ((not i2(0) and i2(2)) or (not i2(1) and not i2(3)) or ( not i2(0) and i2(1) and i2(3)) or ( i2(0) and i2(1) and i2(2)) or (i2(0) and i2(1) and not i2(3)) or (i2(0) and not i2(1) and not i2(2)) or (i2(0) and not i2(1) and not i2(2) and i2(3)));
				seg2(1) <= not ((not i2(0) and not i2(1)) or (not i2(0) and not i2(2) and not i2(3)) or (not i2(0) and i2(2) and i2(3)) or(i2(0) and not i2(2) and i2(3)) or (i2(0) and not i2(1) and not i2(3)));
				seg2(2) <= not ((not i2(0) and not i2(2)) or (not i2(0) and i2(1)) or (not i2(0) and i2(2) and i2(3)) or (i2(0) and not i2(1)) or (i2(0) and not i2(2) and i2(3)));
				seg2(3) <= not ((not i2(0) and not i2(1) and not i2(3)) or (not i2(1) and i2(2) and i2(3)) or (i2(1) and i2(2) and not i2(3)) or (i2(1) and not i2(2) and i2(3)) or (i2(0) and not i2(2)));
				seg2(4) <= not ((i2(0) and i2(1)) or (i2(0) and i2(2)) or (i2(2) and not i2(3)) or (not i2(1) and not i2(3)));
				seg2(5) <= not ((not i2(0) and i2(1) and not i2(2)) or (not i2(0) and i2(1) and not i2(3)) or (not i2(2) and not i2(3)) or (i2(0) and not i2(1)) or (i2(0) and i2(1) and i2(2)));
				seg2(6) <= ((not i2(0) and not i2(1) and not i2(2)) or (not i2(0) and i2(1) and i2(2) and i2(3)) or(i2(0) and i2(1) and not i2(2) and not i2(3)));
			End if;
			
	--Collision logic
	
			if(ballx <= paddle_width AND
				paddle_L < ballY AND bally + ball_size < paddle_L + paddle_height) then --left paddle hits
				movex <= '1';
			elsif(h_pixels - paddle_width < ballx + ball_size AND
				paddle_R < ballY AND ballY + ball_size < paddle_R + paddle_height) then --right paddle hits
				movex <= '0';
			END if;
			if(bally <= 0) then --see if hitting top or bottom
				movey <= '1';
			elsif(bally + ball_size >= v_pixels) then
				movey <= '0';
			END if; 
		END if;
			
	END process; --mechanics
	
--Rendering Process
	PROCESS(disp_ena, row, column, ballx, bally, paddle_L, paddle_R)
	BEGIN
		IF(disp_ena = '1') THEN		--display time
		
	--render the game elements
	
		--render the white ball
			if(ballx < row AND row < ballx + ball_size AND 
				bally < column AND column < bally + ball_size)
			then 
				red <= (others => '1');
				green	<= (OTHERS => '1');
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
		
		--render the black background and white centerline
			elsif(h_pixels/2 - paddle_width < row AND row < h_pixels/2 + paddle_width)-- AND
			
			then
				red <= "01000000";
				green <= "01000000";
				blue <= "01000000";
			ELSE 
				red <= (OTHERS => '0');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			END IF;
			
			
		ELSE								--blanking time
			red <= (OTHERS => '0');
			green <= (OTHERS => '0');
			blue <= (OTHERS => '0');
		END IF;
	
	END PROCESS;
	
	
END behavior;
