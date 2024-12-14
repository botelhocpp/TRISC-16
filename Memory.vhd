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
    TYPE t_MemoryArray IS ARRAY (0 TO c_MEMORY_SIZE - 1) OF t_Reg16;
    
    SIGNAL r_Contents : t_MemoryArray := (
        OTHERS => (OTHERS => '0')
    );
    
    SIGNAL w_Address : INTEGER RANGE 0 TO 2**c_WORD_SIZE - 1 := 0;
BEGIN 
    w_Address <= TO_INTEGER(t_UReg16(i_Address));
    
    p_MEMORY_READ_WRITE_CONTROL:
    PROCESS(i_Clk)
    BEGIN
        IF(RISING_EDGE(i_Clk)) THEN
            IF(w_Address < c_MEMORY_SIZE) THEN
                IF(i_Write_Enable = '1') THEN
                    r_Contents(w_Address) <= io_Data;
                ELSIF(i_Output_Enable = '1') THEN
                    io_Data <= r_Contents(w_Address);
                ELSE
                    io_Data <= (OTHERS => 'Z');
                END IF;
            END IF;
        END IF;
    END PROCESS p_MEMORY_READ_WRITE_CONTROL;
END ARCHITECTURE;
