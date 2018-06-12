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

	component compare
		port (inp1, inp2: in std_logic_vector(0 to 5);
				res: out std_logic);
	end component;

signal PassEQ:	std_logic := '1';
signal PassOK:	std_logic := '0';
signal lastE:	std_logic := '1';
signal lastK:	std_logic_vector(0 to 5) := "000000";
signal storeK:	std_logic_vector(0 to 5) := "000000";
begin
	compareLast:	compare port map(entradaSENHA, lastK, PassEQ);
	compareKey:		compare port map(entradaSENHA, storeK, PassOK);
	senhaOKLED <= PassEQ;
	PROCESS(masterClock)
		VARIABLE attempts : INTEGER := 0;
	BEGIN
		IF(masterClock'EVENT and masterClock = '1') THEN
			CASE state IS 
				WHEN waiting_input =>
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
					ledEstado <= '1';
					attempts := 0;
					IF (chaveE = '0') THEN 
						ledEstado <= '0';
						state <= waiting_input;
					ELSIF (chaveS = '1') THEN 
						state <= read_new_key;
					END IF;
					
				WHEN read_new_key =>
					IF (chaveE = '0') THEN 
						state <= waiting_input;
					ELSIF (chaveS = '0') THEN
						storeK <= entradaSENHA;
						state <= login_success;
					END IF;
					
				WHEN out_of_attempts =>
					ledErro <= '1';
					IF (resetStrikes = '0') THEN --Pushbutton invertido
						ledErro <= '0';
						attempts := 0;
						state <= waiting_input;
					END IF;
			END CASE;
		END IF;
	END PROCESS;
end cofre;
