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
        x"4c00", -- mov s0 #0
        x"4dff", -- mov s1 #0xFF
        x"5dff", -- movu s1 #0xFF
        x"a248", -- xor t0 t0 t0
        x"5af4", -- movu t0 #0xF4
        x"2b42", -- ldr t1 [t0 #0x04]
        x"8b64", -- and t1 t1 #0x04
        x"1ff4", -- beq _uart_read_lsb
        x"2841", -- ldr a0 [t0 #0x02]
        x"4b00", -- mov t1 #0
        x"384e", -- str t1 [t0 #0x04]
        x"2b42", -- ldr t1 [t0 #0x04]
        x"8b64", -- and t1 t1 #0x04
        x"1ff4", -- beq _uart_read_msb
        x"2941", -- ldr a1 [t0 #0x02]
        x"4b00", -- mov t1 #0
        x"384e", -- str t1 [t0 #0x04]
        x"c928", -- shl a1 a1 #8
        x"9004", -- or a0 a0 a1
        x"d014", -- cmp a0 s1
        x"180c", -- beq _cleanup
        x"3880", -- str a0 [s0 #0]
        x"6c82", -- add s0 s0 #2
        x"0fed", -- jmp _uart_read_lsb
        x"4800", -- mov a0 #0
        x"4900", -- mov a1 #0
        x"4a00", -- mov t0 #0
        x"4b00", -- mov t1 #0
        x"4c00", -- mov s0 #0
        x"4d00", -- mov s1 #0
        x"4f00", -- mov pc #0x0000
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
