LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Microcontroller IS
PORT (
    i_Soft_Rst        : IN STD_LOGIC;
    i_Clk           : IN STD_LOGIC;
    i_Rst           : IN STD_LOGIC;
    i_Switches      : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Leds          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    io_Pin_Port     : INOUT t_Reg16
);
END ENTITY;

ARCHITECTURE Structural OF Microcontroller IS
    -- Wires
    SIGNAL w_Clk                : STD_LOGIC := '0';
    SIGNAL w_External_Bus       : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Address            : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Write_Enable       : STD_LOGIC := '0';
    SIGNAL w_Output_Enable      : STD_LOGIC := '0';
    SIGNAL w_Address_Bus        : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Interrupt_Request  : STD_LOGIC := '0';
    SIGNAL w_Led_Switch_Irq     : STD_LOGIC := '0';
    SIGNAL w_Gpio_Irq           : STD_LOGIC := '0';
    SIGNAL w_Timer_Irq          : STD_LOGIC := '0';
    SIGNAL w_Uart_Irq           : STD_LOGIC := '0';

    -- Peripherals Enable Signals
    SIGNAL w_Ram_Write_Enable : STD_LOGIC := '0';
    SIGNAL w_Ram_Output_Enable : STD_LOGIC := '0';
    SIGNAL w_Rom_Output_Enable : STD_LOGIC := '0';
    SIGNAL w_Led_Switch_Write_Enable : STD_LOGIC := '0';
    SIGNAL w_Led_Switch_Output_Enable : STD_LOGIC := '0';
    SIGNAL w_Gpio_Write_Enable : STD_LOGIC := '0';
    SIGNAL w_Gpio_Output_Enable : STD_LOGIC := '0';
    SIGNAL w_Timer_Write_Enable : STD_LOGIC := '0';
    SIGNAL w_Timer_Output_Enable : STD_LOGIC := '0';
    SIGNAL w_Pwm_Write_Enable : STD_LOGIC := '0';
    SIGNAL w_Pwm_Output_Enable : STD_LOGIC := '0';
    SIGNAL w_Uart_Write_Enable : STD_LOGIC := '0';
    SIGNAL w_Uart_Output_Enable : STD_LOGIC := '0';

    -- Pin Port Signals
    SIGNAL w_Rx_Serial : STD_LOGIC := '0';
    SIGNAL w_Pwm_Channel : STD_LOGIC := '0';
    SIGNAL w_Tx_Serial : STD_LOGIC := '0';
BEGIN
    -- w_Clk <= i_Clk;
    e_CLOCK_WIZARD : ENTITY WORK.ClockWizard
    PORT MAP (
        i_Clk       => i_Clk,
        reset       => '0',
        o_Clk       => w_Clk,
        o_Locked    => OPEN
    );
    e_PROCESSOR: ENTITY WORK.Processor
    PORT MAP ( 
        i_Irq           => w_Interrupt_Request,
        i_Clk           => w_Clk,
        i_Rst           => i_Rst,
        i_Soft_Rst        => i_Soft_Rst,
        o_Write_Enable  => w_Write_Enable,
        o_Output_Enable => w_Output_Enable,
        o_Address       => w_Address,
        io_Data         => w_External_Bus
    );
    e_BUS_CONTROLLER: ENTITY WORK.BusController
    PORT MAP (
        i_Led_Switch_Irq                => w_Led_Switch_Irq,
        i_Gpio_Irq                      => w_Gpio_Irq,
        i_Timer_Irq                     => w_Timer_Irq,
        i_Uart_Irq                      => w_Uart_Irq,
        i_Address                       => w_Address,
        i_Write_Enable                  => w_Write_Enable,
        i_Output_Enable                 => w_Output_Enable,
        o_Ram_Write_Enable              => w_Ram_Write_Enable,
        o_Ram_Output_Enable             => w_Ram_Output_Enable,
        o_Rom_Output_Enable             => w_Rom_Output_Enable,
        o_Led_Switch_Write_Enable       => w_Led_Switch_Write_Enable,
        o_Led_Switch_Output_Enable      => w_Led_Switch_Output_Enable,
        o_Gpio_Write_Enable             => w_Gpio_Write_Enable,
        o_Gpio_Output_Enable            => w_Gpio_Output_Enable,
        o_Timer_Write_Enable            => w_Timer_Write_Enable,
        o_Timer_Output_Enable           => w_Timer_Output_Enable,
        o_Pwm_Write_Enable              => w_Pwm_Write_Enable, 
        o_Pwm_Output_Enable             => w_Pwm_Output_Enable, 
        o_Uart_Write_Enable             => w_Uart_Write_Enable, 
        o_Uart_Output_Enable            => w_Uart_Output_Enable, 
        o_Interrupt_Request             => w_Interrupt_Request, 
        o_Address                       => w_Address_Bus,
        io_Data                         => w_External_Bus
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
        o_Irq           => w_Led_Switch_Irq,
        io_Data         => w_External_Bus
    );
    e_GPIO: ENTITY WORK.GPIO
    PORT MAP (
        i_Address       => w_Address_Bus,
        i_Write_Enable  => w_Gpio_Write_Enable,
        i_Output_Enable => w_Gpio_Output_Enable,
        i_Tx_Serial     => w_Tx_Serial,
        i_Pwm_Channel   => w_Pwm_Channel,
        i_Clk           => w_Clk,
        i_Rst           => i_Rst,
        o_Rx_Serial     => w_Rx_Serial,
        io_Pin_Port     => io_Pin_Port,
        o_Irq           => w_Gpio_Irq,
        io_Data         => w_External_Bus
    );
    e_TIMER: ENTITY WORK.Timer
    PORT MAP (
        i_Address       => w_Address_Bus, 
        i_Write_Enable  => w_Timer_Write_Enable, 
        i_Output_Enable => w_Timer_Output_Enable,
        i_Clk           => w_Clk, 
        i_Rst           => i_Rst,
        o_Irq           => w_Timer_Irq,
        io_Data         => w_External_Bus
    );
    e_PWM: ENTITY WORK.PWM
    PORT MAP (
        i_Address       => w_Address_Bus, 
        i_Write_Enable  => w_Pwm_Write_Enable,
        i_Output_Enable => w_Pwm_Output_Enable,
        i_Clk           => w_Clk,
        i_Rst           => i_Rst,
        o_Pwm_Channel   => w_Pwm_Channel, 
        io_Data         => w_External_Bus
    );
    e_UART: ENTITY WORK.UART
    PORT MAP (
        i_Address       => w_Address_Bus, 
        i_Write_Enable  => w_Uart_Write_Enable,
        i_Output_Enable => w_Uart_Output_Enable,
        i_Rx_Serial     => w_Rx_Serial,
        i_Clk           => w_Clk,
        i_Rst           => i_Rst,
        o_Tx_Serial     => w_Tx_Serial, 
        o_Irq           => w_Uart_Irq,
        io_Data         => w_External_Bus
    );

END ARCHITECTURE;