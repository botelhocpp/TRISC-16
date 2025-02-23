LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY MainMemory IS
PORT (
    i_Address       : IN t_Reg16;
    i_Write_Enable  : IN STD_LOGIC;
    i_Output_Enable : IN STD_LOGIC;
    i_Clk           : IN STD_LOGIC;
    io_Data         : INOUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF MainMemory IS 
    TYPE t_MemoryArray IS ARRAY (0 TO c_RAM_SIZE - 1) OF t_Reg16;
    
    SIGNAL r_Contents : t_MemoryArray := (
        x"4c00",
        x"5cf2",
        x"4d00",
        x"5df0",
        x"4acf",
        x"5a07",
        x"388a",
        x"4a24",
        x"5af4",
        x"3888",
        x"2aa0",
        x"aa4f",
        x"38a8",
        x"4a01",
        x"3889",
        x"2a81",
        x"8a42",
        x"1ff4",
        x"0ff7",
        -- x"58f0",
        -- x"2901",
        -- x"3804",
        -- x"0ffc",          
        OTHERS => (OTHERS => '0')
    );
    SIGNAL r_Data_Out : t_Reg16 := (OTHERS => '0');

    SIGNAL w_Address : INTEGER RANGE 0 TO 2**c_WORD_SIZE - 1 := 0;
BEGIN    
    io_Data <= r_Data_Out WHEN (i_Output_Enable = '1') ELSE (OTHERS => 'Z');

    w_Address <= TO_INTEGER(t_UReg16(i_Address));
    
    p_MEMORY_READ_WRITE_CONTROL:
    PROCESS(i_Clk)
    BEGIN
        IF(RISING_EDGE(i_Clk)) THEN
            IF(i_Write_Enable = '1') THEN
                r_Contents(w_Address) <= io_Data;
            ELSIF(i_Output_Enable = '1') THEN
                r_Data_Out <= r_Contents(w_Address);
            END IF;
        END IF;
    END PROCESS p_MEMORY_READ_WRITE_CONTROL;
END ARCHITECTURE;
