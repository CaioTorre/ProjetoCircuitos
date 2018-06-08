library ieee;
use ieee.std_logic_1164.all;

entity flipflopd is 
	port (d, clock, en, r: in std_logic;
			q: out std_logic);
end flipflopd;

architecture memory of flipflopd is 
begin 
	process(clock, r)
	begin
		--if (clock'event and rising_edge(clock) and en = '1') then
		if (clock'event and clock = '1' and en = '1') then
			q <= d;
		end if;
		if (r = '1') then 
			q <= '0';
		end if;
	end process;
end memory;