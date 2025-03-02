LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY TimerTestbench IS
END ENTITY;

ARCHITECTURE Structural OF TimerTestbench IS
    CONSTANT c_CLOCK_50MHZ_PERIOD : TIME := 20ns;

    -- Input/Output Signals
    SIGNAL i_Clk        : STD_LOGIC := '0';
    SIGNAL i_Rst        : STD_LOGIC := '0';
    SIGNAL i_Buttons    : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL o_Leds       : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');

    -- Wires
    SIGNAL w_External_Bus           : t_Reg16 := (OTHERS => 'Z');
    SIGNAL w_Address                : t_Reg16 := (OTHERS => '0');
    SIGNAL w_IO_Write_Enable        : STD_LOGIC := '0';
    SIGNAL w_IO_Output_Enable       : STD_LOGIC := '0';  
BEGIN
    e_IO_MODULE: ENTITY WORK.InputOutputModule
    PORT MAP (
        i_Address       => w_Address, 
        i_Write_Enable  => w_IO_Write_Enable, 
        i_Output_Enable => w_IO_Output_Enable,
        i_Clk           => i_Clk, 
        i_Rst           => i_Rst,
        i_Buttons       => i_Buttons,
        o_Leds          => o_Leds, 
        io_Data         => w_External_Bus
    );
    
    i_Clk <= NOT i_Clk AFTER c_CLOCK_50MHZ_PERIOD/2;
    i_Rst <= '1', '0' AFTER c_CLOCK_50MHZ_PERIOD/4;
    i_Buttons <= "0001", "1111" AFTER 40*c_CLOCK_50MHZ_PERIOD;

    PROCESS
    BEGIN
        WAIT FOR 10*c_CLOCK_50MHZ_PERIOD;
        w_Address <= x"0009"; -- RELOAD

        WAIT FOR 2*c_CLOCK_50MHZ_PERIOD;
        w_External_Bus <= x"0010"; -- Count 16 times 
        w_IO_Write_Enable <= '1';
        
        WAIT FOR c_CLOCK_50MHZ_PERIOD;
        w_External_Bus <= x"0001";
        w_Address <= x"000A"; -- CONTROL
        
        WAIT FOR c_CLOCK_50MHZ_PERIOD;
        w_External_Bus <= (OTHERS => 'Z');
        w_IO_Output_Enable <= '1';
        WAIT;
    END PROCESS;
END ARCHITECTURE;