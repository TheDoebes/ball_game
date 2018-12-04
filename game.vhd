LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity game is
--a generic is a sepcial constant. Think of it as a parameter that is only optionally specified. 
	generic ( 
	--below is the syntax for generics with default values, used when unspecified
		paddle_width	: integer := 10;
		paddle_height	: integer := 120;
		ball_size		: integer := 20;
		h_pixels			: integer := 800;
		v_pixels			: integer := 600;
		max_score		: integer := 9;
				);									--Note that the last lines^^vv MUST omit the semicolon
	port (
		ball_xpos	:	out	integer;
		ball_ypos	:	out	integer
			);
END game;

architecture behavior of game is
--signals

	--Coordingates of the top-left coordinate (read, smallest) of the square ball, and its direction.
	signal ballx : integer := h_pixels/2;
	signal bally : integer := v_pixels/2;
	signal movex : std_logic := '0';
	signal movey : std_logic := '0';
	
	--Current vertical coordinates of the tops of the left and right paddles.
	signal paddle_L : integer := (v_pixels + paddle_height)/2;
	signal paddle_R : integer := (v_pixels + paddle_height)/2;
	
	--Player scores
	signal score1	: integer :=0;
	signal score2	: integer :=0;
	
	--Game state machine
	signal reset		: std_logic :='1';
	signal ball_reset : std_logic :='1';
--constants
	--signal paddleSize : integer := 120;

BEGIN


	mechanics:process(ballx, bally, movex, movey, reset, ball_reset)
	BEGIN
	
	--Score Logic
		if(ballx = 0) then 
		--player 2 scores
			score2 <= score2 + 1;
			ball_reset <= '1';
		elsif(ballx = h_pixels) then 
		--player 1 scores
			score1 <= score1 + 1;
			ball_reset <= '1';
		END if; --ball is in play
		
	--Win condition logic
		if(score1 = max_score) then
		--player 1 wins
		
		elsif(score2 = max_score) then
		--player 2 wins
		
		END if; --then continue play normally
		
	--reset logic, trigger on game start and at the end of win seqeunce.
		if(reset = '1') then
		--reset the game state
			ball_reset <= '1';
			score1 <= 0;
			score2 <= 0;
			paddle_L <= (v_pixels + paddle_height)/2;
			paddle_R <= (v_pixels + paddle_height)/2;
			reset <= '0';
		End if;
		if(ball_reset = '1') then
		--the ball has scored, and should be moved to the starting location
			ballx <= h_pixels/2;
			bally <= v_pixels/2;
			ball_reset <= '0';
		END if;
		
	--Collision logic
	
		if(ballx = 0 + paddle_width AND bally - ball_size < paddle_L AND bally > paddle_L - paddle_height) then --left paddle hits
		--then it should start moving in the x-direction
			movex <= '1';
			
		elsif(ballx + ball_size = h_pixels - paddle_width AND bally - ball_size < paddle_R AND bally > paddle_R - paddle_height) then --right paddle hits
		--and vice versa
			movex <= '0';
		END if;
		if(bally - ball_size = 0) then --see if hitting top or bottom
		--move with y axis
			movey <= '1';
		elsif(bally = v_pixels) then
		--move against y axis
			movey <= '0';
		END if; 
		
	--Movement logic
		
		
		
	END; --mechanics
		
		
		
			