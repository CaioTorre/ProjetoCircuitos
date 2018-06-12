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
	TYPE CONTROL IS (waiting_input, test_input, login_success, read_new_key, out_of_attempts);
	SIGNAL STATE: CONTROL;
	
--	signal EnterTrigger, PassOK, IsLoggedIn, SystemLockdown, OnKeyUpdate, SetLogin, ResetLogin, NewKey, WrongPass, NewETrig, NewAttempt, ajuste, ResetLockdown: std_logic;
--	signal senhaAtual: std_logic_vector(0 to 5);
--	signal ultimaTent: std_logic_vector(0 to 5);
--	signal bcd0, bcd1: std_logic_vector(0 to 3);
--	signal attempts: std_logic_vector(0 to 3);
--	signal LCD_BUSY: std_logic;
--	signal LCD_UPDT: std_logic;
--	signal SYS_STATE: std_logic_vector(0 to 1);
--	signal LCD_TRIG: std_logic;

	component bcd
		port (code: in  std_logic_vector(0 to 3);
				leds: out std_logic_vector(0 to 6));
	end component;
--	
--	component flipflopd
--		port (d, clock, en, r: in std_logic;
--				q 		  : out std_logic);
--	end component;

	component compare
		port (inp1, inp2: in std_logic_vector(0 to 5);
				res: out std_logic);
	end component;

--	component memoryLine
--		port (Data: in std_logic_vector(0 to 5);
--				Clock, Enable, Reset: in std_logic;
--				Qout: out std_logic_vector(0 to 5));
--	end component;
--	
	component LCDHandler is
		port (
			clock: in std_logic;
			storePrint:	in std_logic;
			system_state: in std_logic_vector(0 to 1);
			busy       : OUT   STD_LOGIC := '1';  --lcd controller busy/idle feedback
			rw, rs, e  : OUT   STD_LOGIC;  --read/write, setup/data, and enable for lcd
			lcd_dataout   : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0));
	end component;
	
	--signal PassEQ:	std_logic := '1';
	--signal PassOK:	std_logic := '0';
	signal lastE:	std_logic := '1';
	signal lastK:	std_logic_vector(0 to 5) := "000000";
	signal storeK:	std_logic_vector(0 to 5) := "000000";
	
	signal update_LCD:	std_logic := '0';
	signal storePrint:	std_logic := '0';
	signal printState:	std_logic_vector(0 to 1) := "00";
	signal print_busy:	std_logic := '0';
	
	signal bcd0, bcd1:	std_logic_vector(0 to 3);
	signal AUX0, AUX1, AUX2, AUXILIAR, RESULT: std_logic_vector(0 to 7);
begin
	--compareLast:	compare port map(entradaSENHA, lastK, PassEQ);
	--compareKey:		compare port map(entradaSENHA, storeK, PassOK);
	--senhaOKLED <= PassEQ;
	
	lcdhan: LCDHandler port map (masterClock, storePrint, printState, print_busy, lcd_rw, lcd_rs, lcd_e, lcd_dataout);
	
	PROCESS(masterClock)
		VARIABLE attempts : INTEGER := 0;
	BEGIN
		IF(masterClock'EVENT and masterClock = '1') THEN
			IF (update_LCD = '1') THEN 
				storePrint <= '0';
				update_LCD <= '0';
			ELSE 
				CASE state IS 
					WHEN waiting_input =>
						printState <= "00";
						storePrint <= '1';
						IF (chaveE = '1' and lastE = '0') THEN
							state <= test_input;
							lastE <= '1';
						--ELSIF (chaveE = '1' and PassEQ = '0') THEN 
						ELSIF (chaveE = '1' and (not (entradaSENHA = lastK))) THEN
							state <= test_input;
						END IF;
						IF (chaveE = '0') THEN 
							lastE <= '0';
						END IF;
						
					WHEN test_input =>
						--IF (PassOK = '1') THEN 
						IF (entradaSENHA = storeK) THEN 
							state <= login_success;
							update_LCD <= '1';
						ELSE
							lastK <= entradaSENHA;
							attempts := attempts + 1;
							IF (attempts < 3) THEN 
								state <= waiting_input;
								update_LCD <= '1';
							ELSE 
								state <= out_of_attempts;
								update_LCD <= '1';
							END IF;
						END IF;
						
					WHEN login_success =>
						printState <= "10";
						storePrint <= '1';
						ledEstado <= '1';
						attempts := 0;
						IF (chaveE = '0') THEN 
							storePrint <= '0';
							ledEstado <= '0';
							state <= waiting_input;
							update_LCD <= '1';
						ELSIF (chaveS = '1') THEN 
							storePrint <= '0';
							state <= read_new_key;
							update_LCD <= '1';
						END IF;
						
					WHEN read_new_key =>
						printState <= "01";
						storePrint <= '1';
						IF (chaveE = '0') THEN 
							state <= waiting_input;
							update_LCD <= '1';
						ELSIF (chaveS = '0') THEN
							storeK <= entradaSENHA;
							state <= login_success;
							update_LCD <= '1';
						END IF;
						
					WHEN out_of_attempts =>
						ledErro <= '1';
						IF (resetStrikes = '0') THEN --Pushbutton invertido
							ledErro <= '0';
							attempts := 0;
							state <= waiting_input;
							update_LCD <= '1';
						END IF;
				END CASE;
			END IF;
		END IF;
	END PROCESS;
	
	AUX0 <= ("0000" & ENTRADASENHA(2 TO 5));
	AUX2 <= AUX0 + 6 WHEN (AUX0 > 9) ELSE AUX0;
	AUX1 <= AUX2 + "00110010" WHEN (ENTRADASENHA(0) = '1') ELSE AUX2;
	AUXILIAR <= AUX1 + "00010110" WHEN (ENTRADASENHA(1) = '1') ELSE AUX1;
	RESULT <= AUXILIAR + 6 WHEN AUXILIAR(4 TO 7) > 9 ELSE AUXILIAR;
	
	BCD0 <= RESULT(4 TO 7);
	BCD1 <= RESULT(0 TO 3);
	
	num0: bcd port map (bcd0, numero0);
	num1: bcd port map (bcd1, numero1);
	
--	process(IsLoggedIn, SystemLockdown, EnterTrigger)
--	begin
--		LCD_TRIG <= '1';
--		if (SystemLockdown = '0') then 
--			SYS_STATE <= "11";
--		elsif (IsLoggedIn = '1') then 
--			SYS_STATE <= "10";
--		elsif (EnterTrigger = '1') then 
--			SYS_STATE <= "01";
--		else
--			SYS_STATE <= "00";
--		end if;
--		LCD_TRIG <= '0';
--	end process;
--	masterHandler: LCDHandler port map (masterClock, LCD_TRIG, SYS_STATE, LCD_BUSY, lcd_rw, lcd_rs, lcd_e, lcd_dataout);
--	--LCD_UPDT <= IsLoggedIn;
--	LCD_UPDT <= '1';
--	senhaOKLED <= PassOK;
--	checkPass: compare port map (entradaSENHA, senhaAtual, PassOK);
--	
--	NewKey <= not chaveS;
--	EnterTrigger <= chaveE and SystemLockdown;
--	loggedState: flipflopd port map (SetLogin, OnKeyUpdate, '1', ResetLogin, IsLoggedIn);
--	SetLogin <= IsLoggedIn or PassOK;
--	ResetLogin <= not EnterTrigger;
--	
--	guardaSenha: memoryLine port map (entradaSENHA, NewKey, IsLoggedIn, '0', senhaAtual);
--	tentaE: flipflopd port map (EnterTrigger, OnKeyUpdate, '1', IsLoggedIn, NewETrig);
--	
--	guardaUltimaTent: memoryLine port map (entradaSENHA, OnKeyUpdate, '1', '0', ultimaTent);
--	checkForNewAttempt: compare port map (entradaSENHA, ultimaTent, NewAttempt);
--	
--	process(EnterTrigger)
--	begin 
--		OnKeyUpdate <= EnterTrigger and (NewETrig nand NewAttempt);
--	end process;
--	
--	WrongPass <= not PassOK;
--	--countLockdown: upcounter port map (OnKeyUpdate, not IsLoggedIn, ResetLockdown, attempts);
--	strike1: flipflopd port map (  WrongPass, EnterTrigger, not IsLoggedIn, ResetLockdown, attempts(0));
--	strike2: flipflopd port map (attempts(0), EnterTrigger, not IsLoggedIn, ResetLockdown, attempts(1));
--	strike3: flipflopd port map (attempts(1), EnterTrigger, not IsLoggedIn, ResetLockdown, attempts(2));
--	
--	SystemLockdown <= not (attempts(0) and attempts(1) and attempts(2));
--	ResetLockdown <= IsLoggedIn or not resetStrikes;
--		
--	num0: bcd port map (bcd0, numero0);
--	num1: bcd port map (bcd1, numero1);
--	
--	ledEstado <= IsLoggedIn;
--	ledErro <= not SystemLockdown;
end cofre;