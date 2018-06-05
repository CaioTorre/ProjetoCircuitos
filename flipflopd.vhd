library ieee;
use ieee.std_logic_1164.all;

entity flipflopd is 
	port (d, clock, en, r: in std_logic;
			q       : out std_logic);
end flipflopd;

architecture memory of flipflopd is 
begin 
	process(clock, en)
	begin
		wait until clock'event and clock = '1' and en = '1';
		q <= d;
	end process;
	process(r)
	begin 
		if (r = '1') then q <= '0'
		end if;
	end process;
end memory;