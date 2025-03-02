LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Testbench IS
END ENTITY;

ARCHITECTURE Structural OF Testbench IS
    CONSTANT c_CLOCK_50MHZ_PERIOD : TIME := 20ns;

    -- Input/Output Signals
    SIGNAL i_Clk        : STD_LOGIC := '0';
    SIGNAL i_Rst        : STD_LOGIC := '0';
    SIGNAL i_Switches   : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL o_Leds       : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL io_Pin_Port  : t_Reg16 := (OTHERS => '0');
    SIGNAL o_Pwm_Channel : STD_LOGIC := '0';
    SIGNAL i_Rx_Serial : STD_LOGIC := '1';
    SIGNAL o_Tx_Serial : STD_LOGIC := '0';
BEGIN
    e_Microcontroller: ENTITY WORK.Microcontroller
    PORT MAP (
        i_Rx_Serial     => i_Rx_Serial,
        i_Clk           => i_Clk,
        i_Rst           => i_Rst,
        i_Switches      => i_Switches,
        o_Leds          => o_Leds,
        o_Pwm_Channel   => o_Pwm_Channel,
        o_Tx_Serial     => o_Tx_Serial,
        io_Pin_Port     => io_Pin_Port
    );
    
    i_Clk <= NOT i_Clk AFTER c_CLOCK_50MHZ_PERIOD/2;
    i_Rst <= '1', '0' AFTER c_CLOCK_50MHZ_PERIOD/4;
    i_Switches <= "0001", "1111" AFTER 40*c_CLOCK_50MHZ_PERIOD;
END ARCHITECTURE;