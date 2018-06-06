library ieee;
use ieee.std_logic_1164.all;
entity projeto is 
	port (entradaSENHA: 	in std_logic_vector(0 to 5);
			chaveE:			in std_logic;
			chaveS: 		in std_logic;
			resetStrikes:	in std_logic;
			ledEstado: 		out std_logic;
			ledErro:		out std_logic;
			numero0:		out std_logic_vector(0 to 6);
			numero1: 		out std_logic_vector(0 to 6);
			senhaOKLED: out std_logic);
end projeto;

architecture cofre of projeto is
	signal EnterTrigger, PassOK, IsLoggedIn, SystemLockdown, OnKeyUpdate, SetLogin, ResetLogin, NewKey, WrongPass, NewETrig, NewAttempt: std_logic;
	signal senhaAtual: std_logic_vector(0 to 5);
	signal ultimaTent: std_logic_vector(0 to 5);
	signal bcd0, bcd1: std_logic_vector(0 to 3);
	signal attempts: std_logic_vector(0 to 2);
	component bcd
		port (code: in  std_logic_vector(0 to 3);
				leds: out std_logic_vector(0 to 6));
	end component;
	component flipflopd
		port (d, clock, en, r: in std_logic;
				q 		  : out std_logic);
	end component;
	component compare
		port (inp1, inp2: in std_logic_vector(0 to 5);
				res: out std_logic);
	end component;
	component memoryLine
		port (Data: in std_logic_vector(0 to 5);
				Clock, Enable, Reset: in std_logic;
				Qout: out std_logic_vector(0 to 5));
	end component;
begin
	senhaOKLED <= PassOK;
	checkPass: compare port map (entradaSENHA, senhaAtual, PassOK);
	
	NewKey <= not chaveS;
	EnterTrigger <= chaveE and SystemLockdown;
	loggedState: flipflopd port map (SetLogin, OnKeyUpdate, '1', ResetLogin, IsLoggedIn);
	SetLogin <= IsLoggedIn or PassOK;
	ResetLogin <= not EnterTrigger;
	
	guardaSenha: memoryLine port map (entradaSENHA, NewKey, IsLoggedIn, '0', senhaAtual);
	tentaE: flipflopd port map (   EnterTrigger, OnKeyUpdate, '1', IsLoggedIn, NewETrig);
	
	guardaUltimaTent: memoryLine port map (entradaSENHA, OnKeyUpdate, '1', '0', ultimaTent);
	checkForNewAttempt: compare port map (entradaSENHA, ultimaTent, NewAttempt);
	
	process(EnterTrigger)
	begin 
		OnKeyUpdate <= ((EnterTrigger and ((NewETrig xor EnterTrigger))) or (EnterTrigger and (not NewAttempt)));
	end process;
	
	WrongPass <= not PassOK;
	strike1: flipflopd port map (  WrongPass, EnterTrigger, '1', IsLoggedIn, attempts(0));
	strike2: flipflopd port map (attempts(0), EnterTrigger, '1', IsLoggedIn, attempts(1));
	strike3: flipflopd port map (attempts(1), EnterTrigger, '1', IsLoggedIn, attempts(2));
	
	SystemLockdown <= ((attempts(0) nand attempts(1)) nand attempts(2));
	
	num0: bcd port map (bcd0, numero0);
	num1: bcd port map (bcd1, numero1);
	
	ledEstado <= IsLoggedIn;
	ledErro <= not SystemLockdown;
end cofre;