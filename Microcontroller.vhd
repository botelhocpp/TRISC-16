LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Microcontroller IS
PORT (
    i_Clk       : IN STD_LOGIC;
    i_Rst       : IN STD_LOGIC;
    i_Switches  : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Leds      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    io_Pin_Port : INOUT t_Reg16
);
END ENTITY;

ARCHITECTURE Structural OF Microcontroller IS
    SIGNAL w_Clk : STD_LOGIC := '0';

    -- Wires
    SIGNAL w_External_Bus           : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Address                : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Write_Enable           : STD_LOGIC := '0';
    SIGNAL w_Output_Enable          : STD_LOGIC := '0';

    SIGNAL w_Address_Bus : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Ram_Write_Enable : STD_LOGIC := '0';
    SIGNAL w_Ram_Output_Enable : STD_LOGIC := '0';
    SIGNAL w_Rom_Output_Enable : STD_LOGIC := '0';
    SIGNAL w_Led_Switch_Write_Enable : STD_LOGIC := '0';
    SIGNAL w_Led_Switch_Output_Enable : STD_LOGIC := '0';
    SIGNAL w_Gpio_Write_Enable : STD_LOGIC := '0';
    SIGNAL w_Gpio_Output_Enable : STD_LOGIC := '0';
    SIGNAL w_Timer_Write_Enable : STD_LOGIC := '0';
    SIGNAL w_Timer_Output_Enable : STD_LOGIC := '0';

BEGIN
    w_Clk <= i_Clk;
    
    -- e_CLOCK_WIZARD : ENTITY WORK.ClockWizard
    -- PORT MAP (
    --     i_Clk       => i_Clk,
    --     reset       => '0',
    --     o_Clk       => w_Clk,
    --     o_Locked    => OPEN
    -- );
    e_PROCESSOR: ENTITY WORK.processor
    PORT MAP ( 
        i_Clk           => w_Clk,
        i_Rst           => i_Rst,
        o_Write_Enable  => w_Write_Enable,
        o_Output_Enable => w_Output_Enable,
        o_Address       => w_Address,
        io_Data         => w_External_Bus
    );
    e_BUS_CONTROLLER: ENTITY WORK.BusController
    PORT MAP (
        i_Address                   => w_Address,
        i_Write_Enable              => w_Write_Enable,
        i_Output_Enable             => w_Output_Enable,
        o_Ram_Write_Enable          => w_Ram_Write_Enable,
        o_Ram_Output_Enable         => w_Ram_Output_Enable,
        o_Rom_Output_Enable         => w_Rom_Output_Enable,
        o_Led_Switch_Write_Enable   => w_Led_Switch_Write_Enable,
        o_Led_Switch_Output_Enable  => w_Led_Switch_Output_Enable,
        o_Gpio_Write_Enable         => w_Gpio_Write_Enable,
        o_Gpio_Output_Enable        => w_Gpio_Output_Enable,
        o_Timer_Write_Enable        => w_Timer_Write_Enable,
        o_Timer_Output_Enable       => w_Timer_Output_Enable,
        o_Address                   => w_Address_Bus
    );
    e_RAM: ENTITY WORK.MainMemory
    PORT MAP ( 
        i_Address       => w_Address_Bus,
        i_Write_Enable  => w_Ram_Write_Enable,
        i_Output_Enable => w_Ram_Output_Enable,
        i_Clk           => w_Clk,
        io_Data         => w_External_Bus
    );
    e_ROM: ENTITY WORK.BootloaderRom
    PORT MAP (
        i_Address       => w_Address_Bus,
        i_Output_Enable => w_Rom_Output_Enable,
        i_Clk           => w_Clk,
        io_Data         => w_External_Bus
    );
    e_LED_SWITCH: ENTITY WORK.LedSwitch
    PORT MAP (
        i_Address       => w_Address_Bus, 
        i_Write_Enable  => w_Led_Switch_Write_Enable, 
        i_Output_Enable => w_Led_Switch_Output_Enable,
        i_Clk           => w_Clk, 
        i_Rst           => i_Rst,
        i_Switches      => i_Switches,
        o_Leds          => o_Leds, 
        io_Data         => w_External_Bus
    );
    e_GPIO: ENTITY WORK.GPIO
    PORT MAP (
        i_Address       => w_Address_Bus,
        i_Write_Enable  => w_Gpio_Write_Enable,
        i_Output_Enable => w_Gpio_Output_Enable,
        i_Clk           => w_Clk, 
        i_Rst           => i_Rst,
        io_Pin_Port     => io_Pin_Port,
        io_Data         => w_External_Bus
    );
    e_TIMER: ENTITY WORK.Timer
    PORT MAP (
        i_Address       => w_Address_Bus, 
        i_Write_Enable  => w_Timer_Write_Enable, 
        i_Output_Enable => w_Timer_Output_Enable,
        i_Clk           => w_Clk, 
        i_Rst           => i_Rst,
        io_Data         => w_External_Bus
    );

END ARCHITECTURE;