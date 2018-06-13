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
			
			numeroA:		out std_logic_vector(0 to 6);
			lcd_rw, lcd_rs, lcd_e  : OUT   STD_LOGIC;  --read/write, setup/data, and enable for lcd
			lcd_dataout   : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
			
			senhaOKLED: out std_logic);
end projeto;

architecture cofre of projeto is
	TYPE CONTROL IS (waiting_input, test_input, login_success, read_new_key, out_of_attempts);
	SIGNAL STATE: CONTROL;

	component bcd
		port (code: in  std_logic_vector(0 to 3);
				leds: out std_logic_vector(0 to 6));
	end component;
	
	component compare
		port (inp1, inp2: in std_logic_vector(0 to 5);
				res: out std_logic);
	end component;
	
	component LCDHandler
		port (
			clock: in std_logic;
			system_state: in std_logic_vector(0 to 1);
			--busy       : OUT   STD_LOGIC := '1';  --lcd controller busy/idle feedback
			rw, rs, e  : OUT   STD_LOGIC;  --read/write, setup/data, and enable for lcd
			lcd_dataout   : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0));
	end component;

	signal PassEQ:	std_logic := '1';
	signal PassOK:	std_logic := '0';
	signal lastE:	std_logic := '1';
	signal lastK:	std_logic_vector(0 to 5) := "000000";
	signal storeK:	std_logic_vector(0 to 5) := "000000";

	signal bcd0, bcd1:	std_logic_vector(0 to 3);
	signal AUX0, AUX1, AUX2, aux3, AUXILIAR, RESULT: std_logic_vector(0 to 7);

	signal storeA: std_logic_vector(0 to 1) := "00";
	
	signal Sys_ST:	std_logic_vector(0 to 1) := "00";
begin
	compareLast:	compare port map(entradaSENHA, lastK, PassEQ);
	compareKey:		compare port map(entradaSENHA, storeK, PassOK);
	
	senhaOKLED <= PassOK;
	PROCESS(masterClock)
		VARIABLE attempts : INTEGER := 0;
	BEGIN
		IF(masterClock'EVENT and masterClock = '1') THEN
			CASE state IS 
				WHEN waiting_input =>
					Sys_ST <= "00";
					ledEstado <= '0';
					IF (chaveE = '1' and lastE = '0') THEN 
						state <= test_input;
						lastE <= '1';
					ELSIF (chaveE = '1' and PassEQ = '0') THEN 
						state <= test_input;
					END IF;
					IF (chaveE = '0') THEN 
						lastE <= '0';
					END IF;
					
				WHEN test_input =>
					IF (PassOK = '1') THEN 
						state <= login_success;
					ELSE
						lastK <= entradaSENHA;
						attempts := attempts + 1;
						IF (attempts < 3) THEN 
							state <= waiting_input;
						ELSE 
							state <= out_of_attempts;
						END IF;
					END IF;
					
				WHEN login_success =>
					Sys_ST <= "10";
					ledEstado <= '1';
					attempts := 0;
					IF (chaveE = '0') THEN 
						ledEstado <= '0';
						state <= waiting_input;
					ELSIF (chaveS = '1') THEN 
						state <= read_new_key;
					END IF;
					
				WHEN read_new_key =>
					Sys_ST <= "01";
					IF (chaveE = '0') THEN 
						state <= waiting_input;
					ELSIF (chaveS = '0') THEN
						storeK <= entradaSENHA;
						state <= login_success;
					END IF;
					
				WHEN out_of_attempts =>
					Sys_ST <= "11";
					ledErro <= '1';
					IF (resetStrikes = '0') THEN --Pushbutton invertido
						ledErro <= '0';
						attempts := 0;
						state <= waiting_input;
					END IF;
			END CASE;
		END IF;
		
		case (attempts) is
			when 0 => storeA <= "00";
			when 1 => storeA <= "01";
			when 2 => storeA <= "10";
			when others => storeA <= "11";
		end case;
		
		if (resetStrikes = '0') then
			state <= waiting_input;
			attempts := 0;
			ledErro <= '0';
			ledEstado <= '0';
		end if;
	END PROCESS;
	
	AUX0 <= ("0000" & ENTRADASENHA(2 TO 5));
	AUX2 <= AUX0 + 6 WHEN (AUX0 > 9) ELSE AUX0;
	AUX1 <= AUX2 + "00110010" WHEN (ENTRADASENHA(0) = '1') ELSE AUX2;
	aux3 <= aux1 + 6 WHEN (AUX1(4 to 7) > 9) ELSE AUX1;
	AUXILIAR <= AUX3 + "00010110" WHEN (ENTRADASENHA(1) = '1') ELSE AUX3;
	RESULT <= AUXILIAR + 6 WHEN AUXILIAR(4 TO 7) > 9 ELSE AUXILIAR;
	
	BCD0 <= RESULT(4 TO 7);
	BCD1 <= RESULT(0 TO 3);
	
	num0: bcd port map (bcd0, numero0);
	num1: bcd port map (bcd1, numero1);
	
	numA: bcd port map ("00" & storeA, numeroA);
	
	lcdhan: LCDHandler port map(masterClock, Sys_ST, lcd_rw, lcd_rs, lcd_e, lcd_dataout);
end cofre;