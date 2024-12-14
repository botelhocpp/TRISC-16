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
    SIGNAL i_Buttons    : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL o_Leds       : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
BEGIN
    e_Microcontroller: ENTITY WORK.Microcontroller
    PORT MAP (
        i_Clk       => i_Clk,
        i_Rst       => i_Rst,
        i_Buttons   => i_Buttons,
        o_Leds      => o_Leds
    );
    
    i_Clk <= NOT i_Clk AFTER c_CLOCK_50MHZ_PERIOD/2;
    i_Rst <= '1', '0' AFTER c_CLOCK_50MHZ_PERIOD/4;
    i_Buttons <= "0001", "1111" AFTER 40*c_CLOCK_50MHZ_PERIOD;
END ARCHITECTURE;