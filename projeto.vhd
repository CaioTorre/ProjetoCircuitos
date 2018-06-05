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
	signal EnterTrigger, PassOK, IsLoggedIn, SystemLockdown, SetLogin, ResetLogin: std_logic;
	signal senhaAtual: std_logic_vector(0 to 5);
	signal bcd0, bcd1: std_logic_vector(0 to 3);
	signal attempts: std_logic_vector(0 to 2);
	--signal loggedIn, keyCorrect, updateSENHA: std_logic;
	--signal bcd0, bcd1: std_logic_vector(0 to 3);
	--signal senhaAtual: std_logic_vector(0 to 5);
	component bcd
		port (code: in  std_logic_vector(0 to 3);
				leds: out std_logic_vector(0 to 6));
	end component;
	component flipflopd
		port (d, clock, en, r: in std_logic;
				q 		  : out std_logic);
	end component;
	component latchsr 
		port (s, r: in std_logic;
				q		: out std_logic);
	end component;
begin
	PassOK <=  ((entradaSENHA(0) xnor senhaAtual(0)) and
				(entradaSENHA(1) xnor senhaAtual(1)) and
				(entradaSENHA(2) xnor senhaAtual(2)) and
				(entradaSENHA(3) xnor senhaAtual(3)) and
				(entradaSENHA(4) xnor senhaAtual(4)) and
				(entradaSENHA(5) xnor senhaAtual(5)));
	
	SetLogin <= 	EnterTrigger and PassOK;
	ResetLogin <= 	not EnterTrigger;
	loggedState: latchsr port map (SetLogin, ResetLogin, IsLoggedIn);
	
	senha0: flipflopd port map (entradaSENHA(0), chaveS, IsLoggedIn, '0', senhaAtual(0));
	senha1: flipflopd port map (entradaSENHA(1), chaveS, IsLoggedIn, '0', senhaAtual(1));
	senha2: flipflopd port map (entradaSENHA(2), chaveS, IsLoggedIn, '0', senhaAtual(2));
	senha3: flipflopd port map (entradaSENHA(3), chaveS, IsLoggedIn, '0', senhaAtual(3));
	senha4: flipflopd port map (entradaSENHA(4), chaveS, IsLoggedIn, '0', senhaAtual(4));
	senha5: flipflopd port map (entradaSENHA(5), chaveS, IsLoggedIn, '0', senhaAtual(5));
	
	process(chaveE)
	begin
		if chaveE'event and SystemLockdown = '0' then 
			EnterTrigger <= chaveE;
	end process
	
	strike1: flipflopd port map ( not PassOK, EnterTrigger, '1', IsLoggedIn, attempts(0));
	strike2: flipflopd port map (attempts(0), EnterTrigger, '1', IsLoggedIn, attempts(1));
	strike3: flipflopd port map (attempts(1), EnterTrigger, '1', IsLoggedIn, attempts(2));
	SystemLockdown <= (attempts(0) nand attempts(1) nand attempts(2));
	
	num0: bcd port map (bcd0, numero0);
	num1: bcd port map (bcd1, numero1);
	
	ledEstado <= IsLoggedIn;
	ledErro <= not SystemLockdown;
end memory;