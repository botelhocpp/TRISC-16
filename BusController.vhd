LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY BusController IS
PORT (
    i_Address                   : IN t_Reg16;
    i_Write_Enable              : IN STD_LOGIC;
    i_Output_Enable             : IN STD_LOGIC;
    o_Ram_Write_Enable          : OUT STD_LOGIC;
    o_Ram_Output_Enable         : OUT STD_LOGIC;
    o_Rom_Output_Enable         : OUT STD_LOGIC;
    o_Led_Switch_Write_Enable   : OUT STD_LOGIC;
    o_Led_Switch_Output_Enable  : OUT STD_LOGIC;
    o_Gpio_Write_Enable         : OUT STD_LOGIC;
    o_Gpio_Output_Enable        : OUT STD_LOGIC;
    o_Timer_Write_Enable        : OUT STD_LOGIC;
    o_Timer_Output_Enable       : OUT STD_LOGIC;
    o_Pwm_Write_Enable          : OUT STD_LOGIC;
    o_Pwm_Output_Enable         : OUT STD_LOGIC;
    o_Uart_Write_Enable         : OUT STD_LOGIC;
    o_Uart_Output_Enable        : OUT STD_LOGIC;
    o_Address                   : OUT t_Reg16;
    io_Data                     : INOUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF BusController IS 
    SIGNAL w_Enable_Place_Holder : STD_LOGIC := '0';
BEGIN
    io_Data <= (OTHERS => '0') WHEN (i_Output_Enable = '1' AND w_Enable_Place_Holder = '1') ELSE (OTHERS => 'Z');

    p_RESOLVE_MODULE_ACCESS:
    PROCESS(i_Address, i_Write_Enable, i_Output_Enable)
        VARIABLE v_Address : t_UReg16 := (OTHERS => '0');
        VARIABLE v_Address_Bus : t_UReg16 := (OTHERS => '0');
    BEGIN
        v_Address := t_UReg16(i_Address);
        v_Address_Bus := (OTHERS => '0');

        w_Enable_Place_Holder <= '0';
        o_Ram_Write_Enable <= '0';
        o_Ram_Output_Enable <= '0';
        o_Rom_Output_Enable <= '0';
        o_Led_Switch_Write_Enable <= '0';
        o_Led_Switch_Output_Enable <= '0';
        o_Gpio_Write_Enable <= '0';
        o_Gpio_Output_Enable <= '0';
        o_Timer_Write_Enable <= '0';
        o_Timer_Output_Enable <= '0';
        o_Pwm_Write_Enable <= '0';
        o_Pwm_Output_Enable <= '0';
        o_Uart_Write_Enable <= '0';
        o_Uart_Output_Enable <= '0';

        IF(v_Address >= c_RAM_BASE_ADDR AND v_Address < c_RAM_LIMIT_ADDR) THEN
            v_Address_Bus := v_Address - c_RAM_BASE_ADDR;
            o_Ram_Write_Enable <= i_Write_Enable;
            o_Ram_Output_Enable <= i_Output_Enable;

        ELSIF(v_Address >= c_ROM_BASE_ADDR AND v_Address < c_ROM_LIMIT_ADDR) THEN
            v_Address_Bus := v_Address - c_ROM_BASE_ADDR;
            o_Rom_Output_Enable <= i_Output_Enable;

        ELSIF(v_Address >= c_LED_SWITCH_BASE_ADDR AND v_Address < c_LED_SWITCH_LIMIT_ADDR) THEN
            v_Address_Bus := v_Address - c_LED_SWITCH_BASE_ADDR;
            o_Led_Switch_Write_Enable <= i_Write_Enable;
            o_Led_Switch_Output_Enable <= i_Output_Enable;

        ELSIF(v_Address >= c_GPIO_BASE_ADDR AND v_Address < c_GPIO_LIMIT_ADDR) THEN
            v_Address_Bus := v_Address - c_GPIO_BASE_ADDR;
            o_Gpio_Write_Enable <= i_Write_Enable;
            o_Gpio_Output_Enable <= i_Output_Enable;
            
        ELSIF(v_Address >= c_TIMER_BASE_ADDR AND v_Address < c_TIMER_LIMIT_ADDR) THEN
            v_Address_Bus := v_Address - c_TIMER_BASE_ADDR;
            o_Timer_Write_Enable <= i_Write_Enable;
            o_Timer_Output_Enable <= i_Output_Enable;
            
        ELSIF(v_Address >= c_PWM_BASE_ADDR AND v_Address < c_PWM_LIMIT_ADDR) THEN
            v_Address_Bus := v_Address - c_PWM_BASE_ADDR;
            o_Pwm_Write_Enable <= i_Write_Enable;
            o_Pwm_Output_Enable <= i_Output_Enable;
            
        ELSIF(v_Address >= c_UART_BASE_ADDR AND v_Address < c_UART_LIMIT_ADDR) THEN
            v_Address_Bus := v_Address - c_UART_BASE_ADDR;
            o_Uart_Write_Enable <= i_Write_Enable;
            o_Uart_Output_Enable <= i_Output_Enable;
        
        ELSE
            w_Enable_Place_Holder <= '1';

        END IF;

        o_Address <= t_Reg16('0' & v_Address_Bus(15 DOWNTO 1));
    END PROCESS p_RESOLVE_MODULE_ACCESS;
END ARCHITECTURE;