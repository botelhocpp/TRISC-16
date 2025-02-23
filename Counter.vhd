LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Counter IS
PORT (
    i_Value : IN t_Reg16;
    i_Load : IN STD_LOGIC;
    i_Clk : IN STD_LOGIC;
    i_Count : IN STD_LOGIC;
    i_Rst : IN STD_LOGIC;
    o_Done : OUT STD_LOGIC;
    o_Value : OUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF Counter IS
    SIGNAL r_Count : t_UReg16 := (OTHERS => '0'); 
    SIGNAL r_Done : STD_LOGIC := '1';

    SIGNAL r_Count_Clk_sync : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL w_Count_Enable : STD_LOGIC := '0';
BEGIN
    o_Value <= t_Reg16(r_Count);
    o_Done <= r_Done;

    p_SYNC_CLOCK_DOMINION:
    PROCESS(i_Rst, i_Clk)
    BEGIN
        IF i_Rst = '1' THEN
            r_Count_Clk_sync <= (OTHERS => '0');
        ELSIF rising_edge(i_Clk) THEN
            r_Count_Clk_sync(0) <= i_Count;
            r_Count_Clk_sync(1) <= r_Count_Clk_sync(0);
        END IF;
    END PROCESS p_SYNC_CLOCK_DOMINION;

    -- Detecção de borda de subida do i_Count_Clk sincronizado
    w_Count_Enable <= '1' WHEN (r_Count_Clk_sync(0) = '1' AND r_Count_Clk_sync(1) = '0') ELSE '0';
    
    p_COUNTER_INTERFACE:
    PROCESS(i_Rst, i_Clk)
    BEGIN
        IF(i_Rst = '1') THEN
            r_Count <= (OTHERS => '0');
            r_Done <= '1';
        ELSIF(RISING_EDGE(i_Clk)) THEN
            IF(i_Load = '1') THEN
                r_Count <= t_UReg16(i_Value);
                r_Done <= '0';
            ELSIF(r_Done = '0' AND w_Count_Enable = '1') THEN
                IF(r_Count /= x"0000") THEN
                    r_Count <= r_Count - 1;
                ELSE
                    r_Done <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS p_COUNTER_INTERFACE;
END ARCHITECTURE;
