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
        -- while:
        32 => "0100100000000000", -- 04: MOV R0, #0
        33 => "0010100100000000", -- 06: LDR R1, [R0]
        34 => "0011100000000101", -- 06: STR R1, [R0, #1]
        35 => "0000100000100000", -- 28: JMP #32
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
            IF(w_Address < c_MEMORY_SIZE) THEN
                IF(i_Write_Enable = '1') THEN
                    r_Contents(w_Address) <= io_Data;
                ELSIF(i_Output_Enable = '1') THEN
                    r_Data_Out <= r_Contents(w_Address);
                END IF;
            END IF;
        END IF;
    END PROCESS p_MEMORY_READ_WRITE_CONTROL;
END ARCHITECTURE;
