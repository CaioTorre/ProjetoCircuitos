library ieee;
use ieee.std_logic_1164.all;

entity compare is 
	port (inp1, inp2: in std_logic_vector(0 to 5);
		res: out std_logic);
end compare;

architecture whatdo of compare is 
begin
	res <= ((inp1(0) xnor inp2(0)) and
			(inp1(1) xnor inp2(1)) and
			(inp1(2) xnor inp2(2)) and
			(inp1(3) xnor inp2(3)) and
			(inp1(4) xnor inp2(4)) and
			(inp1(5) xnor inp2(5)));
end whatdo;