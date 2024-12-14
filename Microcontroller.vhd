LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Microcontroller IS
PORT (
    i_Clk       : IN STD_LOGIC;
    i_Rst       : IN STD_LOGIC;
    i_Buttons   : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Leds      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
);
END ENTITY;

ARCHITECTURE Structural OF Microcontroller IS
    SIGNAL w_Clk : STD_LOGIC := '0';

    -- Wires
    SIGNAL w_External_Bus           : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Address                : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Write_Enable           : STD_LOGIC := '0';
    SIGNAL w_Output_Enable          : STD_LOGIC := '0';
    SIGNAL w_Memory_Write_Enable    : STD_LOGIC := '0';
    SIGNAL w_IO_Write_Enable        : STD_LOGIC := '0';
    SIGNAL w_Memory_Output_Enable   : STD_LOGIC := '0';
    SIGNAL w_IO_Output_Enable       : STD_LOGIC := '0';
BEGIN
    e_CLOCK_WIZARD : ENTITY WORK.ClockWizard
    PORT MAP (
        i_Clk       => i_Clk,
        reset       => i_Rst,
        o_Clk       => w_Clk,
        o_Locked    => OPEN
    );
    e_PROCESSOR: ENTITY WORK.processor
    PORT MAP ( 
        i_Clk           => w_Clk,
        i_Rst           => i_Rst,
        o_Write_Enable  => w_Write_Enable,
        o_Output_Enable => w_Output_Enable,
        o_Address       => w_Address,
        io_Data         => w_External_Bus
    );
    e_MAIN_MEMORY: ENTITY WORK.MainMemory
    PORT MAP ( 
        i_Address       => w_Address,
        i_Write_Enable  => w_Memory_Write_Enable,
        i_Output_Enable => w_Memory_Output_Enable,
        i_Clk           => w_Clk,
        io_Data         => w_External_Bus
    );
    e_IO_MODULE: ENTITY WORK.InputOutputModule
    PORT MAP (
        i_Address       => w_Address, 
        i_Write_Enable  => w_IO_Write_Enable, 
        i_Output_Enable => w_IO_Output_Enable,
        i_Clk           => w_Clk, 
        i_Rst           => i_Rst,
        i_Buttons       => i_Buttons,
        o_Leds          => o_Leds, 
        io_Data         => w_External_Bus
    );

    w_Memory_Write_Enable <= '1' WHEN (
        w_Write_Enable = '1' AND
        w_Address >= x"0010"
    ) ELSE '0';
    
    w_IO_Write_Enable <= '1' WHEN (
        w_Write_Enable = '1' AND
        w_Address < x"0010"
    ) ELSE '0';

    w_Memory_Output_Enable <= '1' WHEN (
        w_Output_Enable = '1' AND
        w_Address >= x"0010"
    ) ELSE '0';
    
    w_IO_Output_Enable <= '1' WHEN (
        w_Output_Enable = '1' AND
        w_Address < x"0010"
    ) ELSE '0';
END ARCHITECTURE;