library ieee;
use ieee.std_logic_1164.all;

entity stabilizer is
	port (input:	in  std_logic;
			clock:	in  std_logic;
			output:	out std_logic);
end stabilizer;

architecture stab of stabilizer is 
	constant trigger : integer := 200; -- pCorr > 0.99
begin
	process(clock)
		variable count : integer range 0 to trigger := 0;
	begin
		if (clock'event and clock = '1') then
			if (input = '1') then
				if (count < trigger) then
					count := count + 1;
				end if;
			else
				count := 0;
			end if;
		end if;
		
		if (count < trigger) then
			output <= '0';
		else
			output <= '1';
		end if;
	end process;
end stab;

--architecture stab of stabilizer is
--	constant trigger : integer := 50;
--	signal trail : std_logic := '0';
--	signal corrected_input: std_logic;
--begin
--	corrected_input <= input xor mode;
--	process(clock)
--		variable count : integer range 0 to trigger := 0;
--	begin
--		if (clock'event and clock = '1') then
--			if (corrected_input = '1') then
--				if (count < trigger) then
--					count := count + 1;
--				end if;
--			else
--				count := 0;
--			end if;
--		end if;
--		
--		if(count < trigger) then
--			output <= '0';
--		else
--			output <= '1';
--		end if;
--	end process;
--end stab;