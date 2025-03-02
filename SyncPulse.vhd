LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY SyncPulse IS
PORT (
    i_Main_Clk : IN STD_LOGIC;
    i_Sub_Clk : IN STD_LOGIC;
    i_Rst : IN STD_LOGIC;
    o_Sync_Pulse : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE RTL OF SyncPulse IS
    SIGNAL r_Sync_Clk : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
BEGIN
    p_SYNC_CLOCK_DOMINION:
    PROCESS(i_Rst, i_Main_Clk)
    BEGIN
        IF (i_Rst = '1') THEN
            r_Sync_Clk <= (OTHERS => '0');
        ELSIF (RISING_EDGE(i_Main_Clk)) THEN
            r_Sync_Clk <= r_Sync_Clk(0) & i_Sub_Clk;
        END IF;
    END PROCESS p_SYNC_CLOCK_DOMINION;

    o_Sync_Pulse <= '1' WHEN (r_Sync_Clk(0) = '1' AND r_Sync_Clk(1) = '0') ELSE '0';
END ARCHITECTURE;
