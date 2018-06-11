library ieee;
use ieee.std_logic_1164.all;

entity LCDHandler is 
	port (
		clock: in std_logic;
		--updateScreen: in std_logic;
		--loginSuccess: in std_logic;
		system_state: in std_logic_vector(0 to 1);
		busy       : OUT   STD_LOGIC := '1';  --lcd controller busy/idle feedback
		rw, rs, e  : OUT   STD_LOGIC;  --read/write, setup/data, and enable for lcd
		lcd_dataout   : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0));
end LCDHandler;

architecture handle of LCDHandler is
--signal lcd_busy: std_logic;
--signal lcd_data: std_logic_vector(0 to 7);
--signal lcd_en: std_logic;
--signal lcd_rw: std_logic;
--signal lcd_rs: std_logic;
	signal con_en: std_logic;
	signal con_bus: std_logic_vector(9 downto 0);
	signal con_rs, con_rw: std_logic;
	signal con_data: std_logic_vector(7 downto 0);
	signal con_busy: std_logic;
	--signal printing: std_logic;
	signal updateScreen: std_logic;
	component lcd_controller is
		PORT(
		 clk        : IN    STD_LOGIC;  --system clock
		 reset_n    : IN    STD_LOGIC;  --active low reinitializes lcd
		 lcd_enable : IN    STD_LOGIC;  --latches data into lcd controller
		 lcd_bus    : IN    STD_LOGIC_VECTOR(9 DOWNTO 0);  --data and control signals
		 busy       : OUT   STD_LOGIC := '1';  --lcd controller busy/idle feedback
		 rw, rs, e  : OUT   STD_LOGIC;  --read/write, setup/data, and enable for lcd
		 lcd_data   : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0));
	end component;
begin
	--con_bus <= con_rs & con_rw & con_data;
	lcdMaster: lcd_controller port map (clock, '1', con_en, con_bus, con_busy, rw, rs, e, lcd_dataout);
	process(system_state(0))
	begin
		--cpos := 0;
		updateScreen <= '1';
	end process;
	process(system_state(1))
	begin
		--cpos := 0;
		updateScreen <= '1';
	end process;
	--process(updateScreen)
	--begin
		--if (updateScreen'event and updateScreen = '0') then
			--cpos := 0;
			--con_en <= '0';
		--end if;
	--end process;
	process(clock)
		variable cpos: integer range 0 to 16 := 0;
	begin
		if (clock'event and clock = '1' and updateScreen = '1') then --and updateScreen'event
			if (con_busy = '0' and con_en = '0') then 
				con_en <= '1';
				if (cpos < 16) then 
					cpos := cpos + 1;
				else
					cpos := 0;
				end if;
				if (system_state = "00") then --AWAITING INPUT
					case cpos is
						when 1 =>  con_bus <= "1001001001"; --I
						when 2 =>  con_bus <= "1001101110"; --n
						when 3 =>  con_bus <= "1001110011"; --s
						when 4 =>  con_bus <= "1001101001"; --i
						when 5 =>  con_bus <= "1001110010"; --r
						when 6 =>  con_bus <= "1001100001"; --a
						when 7 =>  con_bus <= "1000100000"; -- 
						when 8 =>  con_bus <= "1001100001"; --a
						when 9 =>  con_bus <= "1000100000"; -- 
						when 10 => con_bus <= "1001110011"; --s
						when 11 => con_bus <= "1001100101"; --e
						when 12 => con_bus <= "1001101110"; --n
						when 13 => con_bus <= "1001101000"; --h
						when 14 => con_bus <= "1001100001"; --a
						--when 15 => 
							--updateScreen <= '0'; 
							--cpos := 0;
						--when 15 => cpos := 0;
						when others => 
							--con_en <= '0';
							updateScreen <= '0'; 
							--cpos := 0;
					end case;
				end if;
				if (system_state = "01") then --INCORRECT PASS
					case cpos is
						when 1 =>  con_bus <= "1001010011";	--S
						when 2 =>  con_bus <= "1001100101"; --e
						when 3 =>  con_bus <= "1001101110"; --n
						when 4 =>  con_bus <= "1001101000"; --h
						when 5 =>  con_bus <= "1001100001"; --a
						when 6 =>  con_bus <= "1000100000"; -- 
						when 7 =>  con_bus <= "1001101001"; --i
						when 8 =>  con_bus <= "1001101110"; --n
						when 9 =>  con_bus <= "1001110110"; --v
						when 10 => con_bus <= "1001100001"; --a
						when 11 => con_bus <= "1001101100"; --l
						when 12 => con_bus <= "1001101001"; --i
						when 13 => con_bus <= "1001100100"; --d
						when 14 => con_bus <= "1001100001"; --a
						--when 15 => 
							--updateScreen <= '0'; 
							--cpos := 0;
						--when 15 => cpos := 0;
						when others => 
							--con_en <= '0';
							updateScreen <= '0'; 
							--cpos := 0;
					end case;
				end if;
				if (system_state = "10") then --LOGIN OK
					case cpos is
						when 1 =>  con_bus <= "1001000010"; --B
						when 2 =>  con_bus <= "1001100101"; --e
						when 3 =>  con_bus <= "1001101101"; --m
						when 4 =>  con_bus <= "1000100000"; -- 
						when 5 =>  con_bus <= "1001110110"; --v
						when 6 =>  con_bus <= "1001101001"; --i
						when 7 =>  con_bus <= "1001101110"; --n
						when 8 =>  con_bus <= "1001100100"; --d
						when 9 =>  con_bus <= "1001101111"; --o
						when 10 => con_bus <= "1000101000"; --( 
						when 11 => con_bus <= "1001100001"; --a
						when 12 => con_bus <= "1000101001"; --)
						when 13 => con_bus <= "1000100001"; --!
						--when 14 => 
							--updateScreen <= '0'; 
							--cpos := 0;
						--when 14 => cpos := 0;
						when others => 
							--con_en <= '0';
							updateScreen <= '0'; 
							--cpos := 0;
					end case;
				end if;
				if (system_state = "11") then --LOCKDOWN
					case cpos is 
						when 1 =>  con_bus <= "1001010100"; --T
						when 2 =>  con_bus <= "1001110010"; --r
						when 3 =>  con_bus <= "1001100001"; --a
						when 4 =>  con_bus <= "1001110110"; --v
						when 5 =>  con_bus <= "1001100001"; --a
						when 6 =>  con_bus <= "1001100100"; --d
						when 7 =>  con_bus <= "1001101111"; --o
						when 8 =>  con_bus <= "1000100001"; --!
						--when 9 =>  
							--updateScreen <= '0'; 
							--cpos := 0;
						--when 9 => cpos := 0;
						when others => 
							--con_en <= '0';-- cpos := 0;
							updateScreen <= '0'; 
							--cpos := 0;
					end case;
				end if;
			else 
				con_en <= '0';
			end if;
		--else 
			--cpos := 0;
			--con_en <= '0';
		end if;
	end process;
end handle;