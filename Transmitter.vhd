LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Transmitter IS
GENERIC (
    g_CLKS_PER_BIT : INTEGER := c_CPU_FREQ / c_UART_BAUD_RATE
);
PORT (
    i_Tx_Byte   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    i_Tx_Transmit : IN  STD_LOGIC;
    i_Clk       : IN  STD_LOGIC;
    i_Rst       : IN  STD_LOGIC;
    o_Tx_Serial : OUT STD_LOGIC;
    o_Tx_Done   : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE RTL OF Transmitter IS

    TYPE t_UartState IS (
        s_IDLE, 
        s_START, 
        s_DATA,
        s_STOP, 
        s_CLEANUP
    );
    SIGNAL r_Current_State : t_UartState := s_IDLE;
    SIGNAL r_Clk_Count : INTEGER RANGE 0 TO 2 * g_CLKS_PER_BIT - 1 := 0;
    SIGNAL r_Bit_Index : INTEGER RANGE 0 TO 7 := 0;
    SIGNAL r_TX_Data   : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    
BEGIN  
    p_UART_TX : PROCESS (i_Rst, i_Clk)
    BEGIN
        IF (i_Rst = '1') THEN
            r_Current_State <= s_IDLE;
            r_Clk_Count <= 0;
            r_Bit_Index <= 0;  -- 8 Bits Total
            r_TX_Data   <= (OTHERS => '0');
            o_Tx_Serial <= '1';
        ELSIF RISING_EDGE(i_Clk) THEN
            
            CASE r_Current_State IS
                WHEN s_IDLE =>
                    o_Tx_Serial <= '1';  -- Drive Line High for Idle
                    r_Clk_Count <= 0;
                    r_Bit_Index <= 0;

                    IF i_Tx_Transmit = '1' THEN
                        r_TX_Data <= i_Tx_Byte;
                        r_Current_State <= s_START;
                    ELSE
                        r_Current_State <= s_IDLE;
                    END IF;

                -- Send out Start Bit. Start bit = 0
                WHEN s_START =>
                    o_Tx_Serial <= '0';

                    -- Wait g_CLKS_PER_BIT-1 clock cycles for start bit to finish
                    IF r_Clk_Count < g_CLKS_PER_BIT - 1 THEN
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_Current_State   <= s_START;
                    ELSE
                        r_Clk_Count <= 0;
                        r_Current_State   <= s_DATA;
                    END IF;

                -- Wait g_CLKS_PER_BIT-1 clock cycles for data bits to finish
                WHEN s_DATA =>
                    o_Tx_Serial <= r_TX_Data(r_Bit_Index);
                    
                    IF r_Clk_Count < g_CLKS_PER_BIT - 1 THEN
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_Current_State   <= s_DATA;
                    ELSE
                        r_Clk_Count <= 0;
                        
                        -- Check if we have sent out all bits
                        IF r_Bit_Index < 7 THEN
                            r_Bit_Index <= r_Bit_Index + 1;
                            r_Current_State   <= s_DATA;
                        ELSE
                            r_Bit_Index <= 0;
                            r_Current_State   <= s_STOP;
                        END IF;
                    END IF;

                -- Send out Stop bit. Stop bit = 1 
                WHEN s_STOP =>
                    o_Tx_Serial <= '1';

                    -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
                    IF r_Clk_Count < 2 * g_CLKS_PER_BIT - 1 THEN
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_Current_State   <= s_STOP;
                    ELSE
                        r_Clk_Count <= 0;
                        r_Current_State   <= s_CLEANUP;
                    END IF;
                
                WHEN s_CLEANUP =>
                    r_Current_State <= s_IDLE;

                WHEN OTHERS =>
                    r_Current_State <= s_IDLE;
            END CASE;
        END IF;
    END PROCESS p_UART_TX;

    o_Tx_Done <= '1' WHEN (r_Current_State = s_IDLE) ELSE '0';
    
END ARCHITECTURE RTL;
