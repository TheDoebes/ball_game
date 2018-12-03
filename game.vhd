

entity game is
	generic (
		paddle_width	: integer := 10;
		paddle_height	: integer := 120;
		ball_size		: integer := 20;
		h_pixels			: integer := 800;
		v_pixels			: integer := 600
				);									--Note that the last lines^^vv MUST omit the semicolon
	port (
		ball_xpos	:	out	integer;
		ball_ypos	:	out	integer;
			);
END game;

architecture behavior of game is
--signals

	--Coordingates of the top-left coordinate (read, smallest) of the square ball.
	signal ballx : integer := 0;
	signal bally : integer := 0;
	
	--Current vertical coordinates of the tops of the left and right paddles.
	signal paddlel : integer := 0;
	signal paddler : integer := 0;
	
	
	--Player scores
	signal score1	: integer :=0;
	signal score2	: integer :=0;
	
	--Game state machine
	signal reset		: std_logic :='1';
	signal ball_reset : std_logic :='1';
--constants
	--signal paddleSize : integer := 120;

BEGIN

--reset logic, trigger on game start and at the end of win seqeunce.
	reset_logic:process(reset, ball_reset)
	BEGIN
	END; --reset_logic
	
	

--scoring logic

	score:process(ballx, bally)
	BEGIN
		if(ballx = 0) then 
		--player 2 scores
			score2 = score2 + 1;
			ball_reset = '1';
		elsif(ballx = h_pixels) then 
		--player 1 scores
			score1 = score1 + 1;
			ball_reset = '1';
		else 
		--ball is in play
		END if;
		
		--check for win conditions
	END; --score
		
		
		
			