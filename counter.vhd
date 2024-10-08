----------------------------------------------------------------------------------
-- Engineer: Pedro Botelho
-- 
-- Module Name: counter
-- Project Name: TRISC-16
-- Target Devices: Zybo Zynq-7000
-- Language Version: VHDL-2008
-- Description: The 16-bit down counter of the processor.
-- 
-- Dependencies: none
-- 
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.TRISC_PARAMETERS.ALL;

ENTITY counter IS
    GENERIC( N : INTEGER := kWORD_SIZE );
    PORT (
        din : IN word_t;
        addr : IN word_t;
        en : IN STD_LOGIC;
        we : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        dout : OUT word_t
    );
END counter;

ARCHITECTURE hardware OF counter IS
    CONSTANT RELOAD_off : INTEGER := 0;
    CONSTANT CONTROL_off : INTEGER := 1;
    CONSTANT COUNT_off : INTEGER := 2;
    
    TYPE counter_array_t IS ARRAY (0 TO 2) OF word_t;
    
    SIGNAL counter_registers : counter_array_t := (OTHERS => (OTHERS => '0'));
    
    SIGNAL register_address : INTEGER;
    
    ALIAS RELOAD_reg : word_t IS counter_registers(RELOAD_off); 
    ALIAS CONTROL_reg : word_t IS counter_registers(CONTROL_off);
    ALIAS COUNT_reg : word_t IS counter_registers(COUNT_off);
    
    ALIAS START_bit : STD_LOGIC IS CONTROL_reg(0);
    ALIAS COUNTFLAG_bit : STD_LOGIC IS CONTROL_reg(1);
BEGIN    
    register_address <= TO_INTEGER(UNSIGNED(addr(N - 1 DOWNTO 1)));
    
    -- Register interface (CPU <-> Counter)
    PROCESS(clk, we, en, rst)
    BEGIN
        IF(rst = '1') THEN
            counter_registers <= (OTHERS => (OTHERS => '0'));
            dout <= (OTHERS => 'Z');
        
        ELSIF(RISING_EDGE(clk)) THEN
            -- Internal workings
            IF(START_bit = '1') THEN
                COUNT_reg <= RELOAD_reg;
                START_bit <= '0';
                COUNTFLAG_bit <= '0';  
            ELSIF(COUNT_reg = kZERO) THEN
                COUNTFLAG_bit <= '1';
            ELSE
                COUNT_reg <= STD_LOGIC_VECTOR(UNSIGNED(COUNT_reg) - 1);
            END IF;
            
            -- User Interface
            IF(en = '1') THEN
                -- Write
                IF(we = '1' AND register_address /= COUNT_off) THEN
                    counter_registers(register_address) <= din;
                    dout <= (OTHERS => 'Z');
                
                -- Read
                ELSIF(we = '0') THEN
                    dout <= counter_registers(register_address);
                END IF;
            ELSE
                dout <= (OTHERS => 'Z');
            END IF;
        END IF;
    END PROCESS;
    
END hardware;
