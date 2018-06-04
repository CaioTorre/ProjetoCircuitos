library ieee;
use ieee.std_logic_1164.all;
entity projeto is 
	port (entradaSENHA: 	in std_logic_vector(0 to 5);
			chaveE:			in std_logic;
			chaveS: 			in std_logic;
			ledEstado: 		out std_logic;
			ledErro:			out std_logic;
			numero0:			out std_logic_vector(0 to 6);
			numero1: 		out std_logic_vector(0 to 6));
end projeto;

architecture memory of projeto is
	signal loggedIn, keyCorrect, updateSENHA: std_logic;
	signal bcd0, bcd1: std_logic_vector(0 to 3);
	signal senhaAtual: std_logic_vector(0 to 5);
	component bcd
		port (code: in  std_logic_vector(0 to 3);
				leds: out std_logic_vector(0 to 6));
	end component;
	component flipflopd
		port (d, clock: in std_logic;
				q 		  : out std_logic);
	end component;
begin
	loggedState: flipflopd port map (keyCorrect, chaveE, loggedIn);
	senha0: flipflopd port map (entradaSENHA(0), updateSENHA, senhaAtual(0));
	senha1: flipflopd port map (entradaSENHA(1), updateSENHA, senhaAtual(1));
	senha2: flipflopd port map (entradaSENHA(2), updateSENHA, senhaAtual(2));
	senha3: flipflopd port map (entradaSENHA(3), updateSENHA, senhaAtual(3));
	senha4: flipflopd port map (entradaSENHA(4), updateSENHA, senhaAtual(4));
	senha5: flipflopd port map (entradaSENHA(5), updateSENHA, senhaAtual(5));
	num0: bcd port map (bcd0, numero0);
	num1: bcd port map (bcd1, numero1);
	process(chaveE)
	begin
		if chaveE'event and chaveE = '1' then 
			keyCorrect <= 	(entradaSENHA(0) xnor senhaAtual(0)) and
								(entradaSENHA(1) xnor senhaAtual(1)) and
								(entradaSENHA(2) xnor senhaAtual(2)) and
								(entradaSENHA(3) xnor senhaAtual(3)) and
								(entradaSENHA(4) xnor senhaAtual(4)) and
								(entradaSENHA(5) xnor senhaAtual(5));
	end process
	process(keyCorrect)
		
end memory;