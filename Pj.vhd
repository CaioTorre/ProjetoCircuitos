ENTITY exp6 IS 
PORT (x12, x11, x22, x21: IN BIT; 
saida: OUT BIT); 
END exp6; 
 
ARCHITECTURE funcao OF exp6 IS 
BEGIN 
saida <= NOT((x12 AND x11 AND x22 AND x21) 
OR 
(x12 AND NOT X11 AND x22 AND NOT X21) 
OR 
(NOT x12 AND X11 AND NOT x22 AND X21) 
OR 
NOT (x12 OR x11 OR x22 OR x21)); 
END funcao; 