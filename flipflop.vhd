library ieee;
use ieee.std_logic_1164.all;

entity flipflopd is 
	port (d, clock: in std_logic;
			q       : out std_logic);
end flipflopd;

architecture memory of flipflopd is 
begin 
	process
	begin
		wait until clock'event and clock = '1';
		q <= d;
	end process;
end memory;