library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity projeto is 
	port (entradaSENHA: 	in std_logic_vector(0 to 5);
			chaveE:			in std_logic;
			chaveS: 		in std_logic;
			resetStrikes:	in std_logic;
			ledEstado: 		out std_logic;
			ledErro:		out std_logic;
			numero0:		out std_logic_vector(0 to 6);
			numero1: 	out std_logic_vector(0 to 6);
			senhaOKLED: out std_logic);
end projeto;

architecture cofre of projeto is
	signal EnterTrigger, PassOK, IsLoggedIn, SystemLockdown, OnKeyUpdate, SetLogin, ResetLogin, NewKey, WrongPass, NewETrig, NewAttempt, ajuste, ResetLockdown: std_logic;
	signal senhaAtual: std_logic_vector(0 to 5);
	signal ultimaTent: std_logic_vector(0 to 5);
	signal bcd0, bcd1: std_logic_vector(0 to 3);
	signal attempts: std_logic_vector(0 to 3);
	signal AUX0, AUX1, AUX2, AUXILIAR, RESULT: std_logic_vector(0 to 7);
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
	component upcounter is 
		port (
			clock: in std_logic;
			enable: in std_logic;
			reset: in std_logic;
			output: out std_logic_vector(0 to 1));
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
	tentaE: flipflopd port map (EnterTrigger, OnKeyUpdate, '1', IsLoggedIn, NewETrig);
	
	guardaUltimaTent: memoryLine port map (entradaSENHA, OnKeyUpdate, '1', '0', ultimaTent);
	checkForNewAttempt: compare port map (entradaSENHA, ultimaTent, NewAttempt);
	
	process(EnterTrigger)
	begin 
		OnKeyUpdate <= EnterTrigger and (NewETrig nand NewAttempt);
	end process;
	
	WrongPass <= not PassOK;
	--countLockdown: upcounter port map (OnKeyUpdate, not IsLoggedIn, ResetLockdown, attempts);
	strike1: flipflopd port map (  WrongPass, EnterTrigger, not IsLoggedIn, ResetLockdown, attempts(0));
	strike2: flipflopd port map (attempts(0), EnterTrigger, not IsLoggedIn, ResetLockdown, attempts(1));
	strike3: flipflopd port map (attempts(1), EnterTrigger, not IsLoggedIn, ResetLockdown, attempts(2));
	
	SystemLockdown <= not (attempts(0) and attempts(1) and attempts(2));
	ResetLockdown <= IsLoggedIn or not resetStrikes;
	
	AUX0 <= ("0000" & ENTRADASENHA(2 TO 5));
	AUX2 <= AUX0 + 6 WHEN (AUX0 > 9) ELSE AUX0;
	AUX1 <= AUX2 + "00110010" WHEN (ENTRADASENHA(0) = '1') ELSE AUX2;
	AUXILIAR <= AUX1 + "00010110" WHEN (ENTRADASENHA(1) = '1') ELSE AUX1;
	RESULT <= AUXILIAR + 6 WHEN AUXILIAR(4 TO 7) > 9 ELSE AUXILIAR;
	
	BCD0 <= RESULT(4 TO 7);
	BCD1 <= RESULT(0 TO 3);
		
	num0: bcd port map (bcd0, numero0);
	num1: bcd port map (bcd1, numero1);
	
	ledEstado <= IsLoggedIn;
	ledErro <= not SystemLockdown;
end cofre;