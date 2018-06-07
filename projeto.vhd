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
--	signal EnterTrigger, PassOK, IsLoggedIn, SystemLockdown, OnKeyUpdate, SetLogin, ResetLogin, NewKey, WrongPass, NewETrig, NewAttempt, ajuste, ResetLockdown, ClearE: std_logic;
--	signal senhaAtual: std_logic_vector(0 to 5);
--	signal ultimaTent: std_logic_vector(0 to 5);
--	signal bcd0, bcd1: std_logic_vector(0 to 3);
--	signal bcdA: std_logic_vector(0 to 7);
--	signal senhaaux: std_logic_vector(0 to 7);
--	--signal bcd6: std_logic_vector(0 to 7);
--	signal attempts: std_logic_vector(0 to 2);
----	signal dezena: std_logic_vector(0 to 1);
	signal EnterTrigger, PassOK, IsLoggedIn, SystemLockdown, OnKeyUpdate, SetLogin, ResetLogin, NewKey, WrongPass, NewETrig, NewAttempt, ajuste, ResetLockdown: std_logic;
	signal senhaAtual: std_logic_vector(0 to 5);
	signal ultimaTent: std_logic_vector(0 to 5);
	signal bcd0, bcd1: std_logic_vector(0 to 3);
	signal bcd6: std_logic_vector(0 to 7);
	signal attempts: std_logic_vector(0 to 2);
	signal dezena: std_logic_vector(0 to 1);
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
	strike1: flipflopd port map (  WrongPass, EnterTrigger, '1', ResetLockdown, attempts(0));
	strike2: flipflopd port map (attempts(0), EnterTrigger, '1', ResetLockdown, attempts(1));
	strike3: flipflopd port map (attempts(1), EnterTrigger, '1', ResetLockdown, attempts(2));
	
	SystemLockdown <= not ((attempts(0) and attempts(1)) and attempts(2));
	ResetLockdown <= IsLoggedIn or resetStrikes;
		
	num0: bcd port map (bcd0, numero0);
	num1: bcd port map (bcd1, numero1);

--	process(entradaSENHA, chaveE)
--	begin
--		bcdA(6 to 7) <= "00";
--		bcdA(0) <= entradaSENHA(5);
--		bcdA(1) <= entradaSENHA(4);
--		bcdA(2) <= entradaSENHA(3);
--		bcdA(3) <= entradaSENHA(2);
--		bcdA(4) <= entradaSENHA(1);
--		bcdA(5) <= entradaSENHA(0);
--		senhaaux <= bcdA;
--		bcd0 <= "0000";
--		bcd1 <= "0000";
--
--		display: for i in 0 to 6 loop
--			if bcdA > "00001001" then
--			bcdA <= senhaaux - "00001010";
--			senhaaux <= ("0000" & bcd1) + "00000001";
--			bcd1 <= senhaaux (4 to 7);
--			senhaaux <= bcdA;
--			end if;
--		end loop;
--		bcd0 <= senhaaux(4 to 7);
--	end process;
	
	ledEstado <= IsLoggedIn;
	ledErro <= not SystemLockdown;
end cofre;
