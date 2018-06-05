library ieee;
use ieee.std_logic_1164.all;

entity memoryLine is 
	port (Data: in std_logic_vector(0 to 5);
			Clock, Enable, Reset: in std_logic;
			Qout: out std_logic_vector(0 to 5));
end memoryLine;

architecture memory of compare is 
	component flipflopd
		port (d, clock, en, r: in std_logic;
				q 		  : out std_logic);
	end component;
begin
	line0: flipflopd port map (Data(0), Clock, Enable, Reset, Qout(0));
	line1: flipflopd port map (Data(1), Clock, Enable, Reset, Qout(1));
	line2: flipflopd port map (Data(2), Clock, Enable, Reset, Qout(2));
	line3: flipflopd port map (Data(3), Clock, Enable, Reset, Qout(3));
	line4: flipflopd port map (Data(4), Clock, Enable, Reset, Qout(4));
	line5: flipflopd port map (Data(5), Clock, Enable, Reset, Qout(5));
end memory;