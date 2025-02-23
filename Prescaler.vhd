LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Prescaler IS
PORT (
    i_Clk : IN STD_LOGIC;
    i_Divider : IN t_Reg16;
    i_Rst : IN STD_LOGIC;
    o_Clk : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE RTL OF Prescaler IS 
    SIGNAL w_Clk : STD_LOGIC := '0';
BEGIN 
    o_Clk <= w_Clk WHEN (i_Divider /= x"0000") ELSE i_Clk;
    
    PROCESS(i_Rst, i_Clk)
        VARIABLE v_Counter : t_UReg16 := x"0000";
    BEGIN
        IF(i_Rst = '1') THEN
            v_Counter := x"0000";
            w_Clk <= '0';
        ELSIF(RISING_EDGE(i_Clk)) THEN 
            v_Counter := v_Counter + 1;

            IF(v_Counter >= t_UReg16(i_Divider)) THEN
                v_Counter := x"0000";
                w_Clk <= NOT w_Clk;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;