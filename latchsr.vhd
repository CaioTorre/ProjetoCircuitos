library ieee;
use ieee.std_logic_1164.all;

entity latchsr is 
	port (s, r: in std_logic;
			q       : out std_logic);
end latchsr;

architecture memory of latchsr is 
begin 
	process(s, r)
	begin 
		if (s = '1') then q <= '1';
		end if;
		if (r = '1') then q <= '0';
		end if;
	end process;
end memory;