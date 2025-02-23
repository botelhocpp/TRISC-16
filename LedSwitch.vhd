LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY LedSwitch IS
PORT (
    i_Address       : IN t_Reg16;
    i_Write_Enable  : IN STD_LOGIC;
    i_Output_Enable : IN STD_LOGIC;
    i_Clk           : IN STD_LOGIC;
    i_Rst           : IN STD_LOGIC;
    i_Switches      : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Leds          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    io_Data         : INOUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF LedSwitch IS 
    CONSTANT c_LED_SWITCH_DATAOUT_REG_INDEX : INTEGER := 0;
    CONSTANT c_LED_SWITCH_DATAIN_REG_INDEX : INTEGER := 1;
    
    TYPE t_RegisterArray IS ARRAY (0 TO 1) OF t_Reg16; 
    SIGNAL r_Registers : t_RegisterArray := (OTHERS => (OTHERS => '0'));

    SIGNAL r_Leds : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL r_Data_Out : t_Reg16 := (OTHERS => '0');
    
    SIGNAL w_Address : INTEGER RANGE 0 TO 15 := 0;
BEGIN
    o_Leds <= r_Leds;
    
    io_Data <= r_Data_Out WHEN (i_Output_Enable = '1') ELSE (OTHERS => 'Z');
    
    w_Address <= TO_INTEGER(t_UReg16(i_Address));

    p_REGISTERS_READ_WRITE_CONTROL:
    PROCESS(i_Rst, i_Clk)
    BEGIN
        IF(i_Rst = '1') THEN
            r_Registers <= (OTHERS => (OTHERS => '0'));
            r_Data_Out <= (OTHERS => '0');
        ELSIF(RISING_EDGE(i_Clk)) THEN
            IF(i_Write_Enable = '1') THEN
                r_Registers(w_Address) <= io_Data;
            ELSIF(i_Output_Enable = '1') THEN
                r_Data_Out <= r_Registers(w_Address);
            END IF;
            
            r_Registers(c_LED_SWITCH_DATAIN_REG_INDEX)(3 DOWNTO 0) <= i_Switches;
        END IF;
    END PROCESS p_REGISTERS_READ_WRITE_CONTROL;

    p_DEVICES_CONTROL:
    PROCESS(i_Clk)
    BEGIN
        IF(RISING_EDGE(i_Clk)) THEN
            r_Leds <= r_Registers(c_LED_SWITCH_DATAOUT_REG_INDEX)(3 DOWNTO 0);
        END IF;
    END PROCESS p_DEVICES_CONTROL;
END ARCHITECTURE;