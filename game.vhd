

entity game is
	generic (
		paddlex
		paddley
				);
	port (
		ball_xpos	:	out	integer;
		ball_ypos	:	out	integer;
			);
end game;

architecture behavior of game is
--signals

	signal ballx : integer := 0;
	signal bally : integer := 0;
	signal paddlel : integer := 0;
	signal paddelr : integer := 0;
	
--constants
	--signal paddleSize : integer := 120;

begin

--start with score logic

score:process(ballx, bally)