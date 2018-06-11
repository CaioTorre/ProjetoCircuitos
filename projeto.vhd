library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity projeto is 
	port (entradaSENHA: 	in std_logic_vector(0 to 5);
			chaveE:			in std_logic;
			chaveS: 		in std_logic;
			resetStrikes:	in std_logic;
			masterClock: in std_logic;
			ledEstado: 		out std_logic;
			ledErro:		out std_logic;
			numero0:		out std_logic_vector(0 to 6);
			numero1: 	out std_logic_vector(0 to 6);
			lcd_rw, lcd_rs, lcd_e  : OUT   STD_LOGIC;  --read/write, setup/data, and enable for lcd
			lcd_dataout   : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
			senhaOKLED: out std_logic);
end projeto;

architecture cofre of projeto is
	signal EnterTrigger, PassOK, IsLoggedIn, SystemLockdown, OnKeyUpdate, SetLogin, ResetLogin, NewKey, WrongPass, NewETrig, NewAttempt, ajuste, ResetLockdown: std_logic;
	signal senhaAtual: std_logic_vector(0 to 5);
	signal ultimaTent: std_logic_vector(0 to 5);
	signal bcd0, bcd1: std_logic_vector(0 to 3);
	signal attempts: std_logic_vector(0 to 3);
	signal LCD_BUSY: std_logic;
	signal LCD_UPDT: std_logic;
	signal SYS_STATE: std_logic_vector(0 to 1);
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
	component LCDHandler is
		port (
			clock: in std_logic;
			--updateScreen: in std_logic;
			system_state: in std_logic_vector(0 to 1);
			busy       : OUT   STD_LOGIC := '1';  --lcd controller busy/idle feedback
			rw, rs, e  : OUT   STD_LOGIC;  --read/write, setup/data, and enable for lcd
			lcd_dataout   : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0));
	end component;
begin
	process(IsLoggedIn, SystemLockdown, EnterTrigger)
	begin
		if (SystemLockdown = '0') then 
			SYS_STATE <= "11";
		elsif (IsLoggedIn = '1') then 
			SYS_STATE <= "10";
		elsif (EnterTrigger = '1') then 
			SYS_STATE <= "01";
		else
			SYS_STATE <= "00";
		end if;
	end process;
	masterHandler: LCDHandler port map (masterClock, SYS_STATE, LCD_BUSY, lcd_rw, lcd_rs, lcd_e, lcd_dataout);
	--LCD_UPDT <= IsLoggedIn;
	LCD_UPDT <= '1';
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
		
	num0: bcd port map (bcd0, numero0);
	num1: bcd port map (bcd1, numero1);
	
	ledEstado <= IsLoggedIn;
	ledErro <= not SystemLockdown;
end cofre;