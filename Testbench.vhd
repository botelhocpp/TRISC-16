LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Testbench IS
END ENTITY;

ARCHITECTURE Structural OF Testbench IS
    CONSTANT c_CLOCK_50MHZ_PERIOD : TIME := 8ns;

    -- Input/Output Signals
    SIGNAL i_Clk        : STD_LOGIC := '0';
    SIGNAL i_Rst        : STD_LOGIC := '0';
    SIGNAL i_Soft_Rst    : STD_LOGIC := '0';
    SIGNAL i_Switches   : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL o_Leds       : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL io_Pin_Port  : t_Reg16 := (OTHERS => 'Z');
BEGIN
    e_Microcontroller: ENTITY WORK.Microcontroller
    PORT MAP (
        i_Soft_Rst      => i_Soft_Rst,
        i_Clk           => i_Clk,
        i_Rst           => i_Rst,
        i_Switches      => i_Switches,
        o_Leds          => o_Leds,
        io_Pin_Port     => io_Pin_Port
    );
    
    i_Clk <= NOT i_Clk AFTER c_CLOCK_50MHZ_PERIOD/2;
    i_Rst <= '1', '0' AFTER c_CLOCK_50MHZ_PERIOD/4;
    i_Soft_Rst <= '0', '1' AFTER 10ms, '0' AFTER 11ms;
    i_Switches <= "0001", "1111" AFTER 10us, "1010" AFTER 20us;
END ARCHITECTURE;