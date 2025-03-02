LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY BootloaderRom IS
PORT (
    i_Address       : IN t_Reg16;
    i_Output_Enable : IN STD_LOGIC;
    i_Clk           : IN STD_LOGIC;
    io_Data         : INOUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF BootloaderRom IS 
    TYPE t_MemoryArray IS ARRAY (0 TO c_ROM_SIZE - 1) OF t_Reg16;
    
    SIGNAL r_Contents : t_MemoryArray := (
        x"4c00",
        x"4dff",
        x"5dff",
        x"a248",
        x"5af4",
        x"2b42",
        x"8b64",
        x"1ff4",
        x"2841",
        x"4b00",
        x"384e",
        x"2b42",
        x"8b64",
        x"1ff4",
        x"2941",
        x"4b00",
        x"384e",
        x"c928",
        x"9004",
        x"d014",
        x"180c",
        x"3880",
        x"6c82",
        x"0fed",
        x"4f00",
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
            IF(i_Output_Enable = '1') THEN
                r_Data_Out <= r_Contents(w_Address);
            END IF;
        END IF;
    END PROCESS p_MEMORY_READ_WRITE_CONTROL;
END ARCHITECTURE;
