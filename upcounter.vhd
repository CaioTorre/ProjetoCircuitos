library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity upcounter is 
	port (
		clock: in std_logic;
		enable: in std_logic;
		reset: in std_logic;
		output: out std_logic_vector(0 to 1));
end upcounter;

architecture counting of upcounter is 
signal count: std_logic_vector(0 to 1);
begin

	process(reset,clock)
	begin
		if reset = '1' then
			count <= "00";
		elsif clock'event and clock = '1' and enable = '1' then 
			count <= count + '1';
		end if;
		
	end process;
	
	output <= count;
end counting;