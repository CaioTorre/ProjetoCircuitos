library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bcd is
	port (code: in  std_logic_vector(0 to 3);
	      --x: out std_logic_vector(0 to 3);
			leds: out std_logic_vector(0 to 6));
end bcd;

architecture decoder of bcd is 
 --signal ajuste: std_logic
begin
	--x <= code;
	--ajuste  <= '1' when (x < 9) else '0';	
   --code <= x when (ajuste = '0') else x + 6;
	with code select
		leds <= 	"0000001" when "0000",
					"1001111" when "0001",
					"0010010" when "0010",
					"0000110" when "0011",
					"1001100" when "0100",
					"0100100" when "0101",
					"0100000" when "0110",
					"0001111" when "0111",
					"0000000" when "1000",
					"0000100" when "1001",
					
					"1111111" when "1010", --Display off
					"1111110" when "1011", --Display "-"
					
					"1111110" when others;
end decoder;
			