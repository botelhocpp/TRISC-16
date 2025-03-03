LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Receiver IS
GENERIC (
    g_CLKS_PER_BIT : INTEGER := c_CPU_FREQ / c_UART_BAUD_RATE
);
PORT (
    i_Clk       : IN  STD_LOGIC;
    i_Rst       : IN  STD_LOGIC;
    i_RX_Serial : IN  STD_LOGIC;
    o_Rx_Done   : OUT STD_LOGIC;
    o_Rx_Byte   : OUT t_Byte
);
END ENTITY;

ARCHITECTURE RTL OF Receiver IS

    TYPE t_CurrentState IS (
        s_IDLE, 
        s_START, 
        s_DATA,
        s_STOP, 
        s_CLEANUP
    );
    SIGNAL r_SM_Main : t_CurrentState := s_IDLE;

    SIGNAL r_RX_Data_R : STD_LOGIC := '1';
    SIGNAL r_RX_Data   : STD_LOGIC := '1';
    
    SIGNAL r_Clk_Count : INTEGER RANGE 0 TO g_CLKS_PER_BIT - 1 := 0;
    SIGNAL r_Bit_Index : INTEGER RANGE 0 TO 7 := 0;  -- 8 Bits Total
    SIGNAL r_RX_Byte   : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL r_RX_DV     : STD_LOGIC := '0';
    
BEGIN

    -- Purpose: Double-register the incoming data.
    -- This allows it to be used in the UART RX Clock Domain.
    -- (It removes problems caused by metastability)
    p_SAMPLE : PROCESS (i_Rst, i_Clk)
    BEGIN
        IF (i_Rst = '1') THEN
            r_RX_Data_R <= '1';
            r_RX_Data   <= '1'; 
        ELSIF RISING_EDGE(i_Clk) THEN
            r_RX_Data_R <= i_RX_Serial;
            r_RX_Data   <= r_RX_Data_R; 
        END IF; 
    END PROCESS p_SAMPLE;

    -- Purpose: Control RX state machine
    p_Receiver : PROCESS (i_Rst, i_Clk)
    BEGIN
        IF (i_Rst = '1') THEN 
            r_SM_Main   <= s_IDLE;
            r_Clk_Count <= 0;
            r_Bit_Index <= 0;  -- 8 Bits Total
            r_RX_Byte   <= (OTHERS => '0');
            r_RX_DV     <= '0';
        ELSIF RISING_EDGE(i_Clk) THEN
            CASE r_SM_Main IS
                WHEN s_IDLE =>
                    r_RX_DV     <= '0';
                    r_Clk_Count <= 0;
                    r_Bit_Index <= 0;

                    IF r_RX_Data = '0' THEN  -- Start bit detected
                        r_SM_Main <= s_START;
                    ELSE
                        r_SM_Main <= s_IDLE;
                    END IF;

                -- Check middle of start bit to make sure it's still low
                WHEN s_START =>
                    IF r_Clk_Count = (g_CLKS_PER_BIT - 1) / 2 THEN
                        IF r_RX_Data = '0' THEN
                            r_Clk_Count <= 0;  -- Reset counter since we found the middle
                            r_SM_Main   <= s_DATA;
                        ELSE
                            r_SM_Main   <= s_IDLE;
                        END IF;
                    ELSE
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_SM_Main   <= s_START;
                    END IF;
                
                -- Wait g_CLKS_PER_BIT - 1 clock cycles to sample serial data
                WHEN s_DATA =>
                    IF r_Clk_Count < g_CLKS_PER_BIT - 1 THEN
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_SM_Main   <= s_DATA;
                    ELSE
                        r_Clk_Count            <= 0;
                        r_RX_Byte(r_Bit_Index) <= r_RX_Data;
                        
                        -- Check if we have sent out all bits
                        IF r_Bit_Index < 7 THEN
                            r_Bit_Index <= r_Bit_Index + 1;
                            r_SM_Main   <= s_DATA;
                        ELSE
                            r_Bit_Index <= 0;
                            r_SM_Main   <= s_STOP;
                        END IF;
                    END IF;
                
                -- Receive Stop bit. Stop bit = 1
                WHEN s_STOP =>
                    -- Wait g_CLKS_PER_BIT - 1 clock cycles for Stop bit to finish
                    IF r_Clk_Count < g_CLKS_PER_BIT - 1 THEN
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_SM_Main   <= s_STOP;
                    ELSE
                        r_RX_DV     <= '1';
                        r_Clk_Count <= 0;
                        r_SM_Main   <= s_CLEANUP;
                    END IF;
                
                -- Stay here 1 clock
                WHEN s_CLEANUP =>
                    r_SM_Main <= s_IDLE;
                    r_RX_DV   <= '0';
                
                WHEN OTHERS =>
                    r_SM_Main <= s_IDLE;
            END CASE;
        END IF;
    END PROCESS p_Receiver;

    o_Rx_Done <= r_RX_DV;
    o_Rx_Byte <= r_RX_Byte;
    
END ARCHITECTURE RTL;
