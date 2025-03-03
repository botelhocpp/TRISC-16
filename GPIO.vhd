LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY GPIO IS
PORT (
    i_Address       : IN t_Reg16;
    i_Write_Enable  : IN STD_LOGIC;
    i_Output_Enable : IN STD_LOGIC;
    i_Tx_Serial     : IN STD_LOGIC;
    i_Pwm_Channel   : IN STD_LOGIC;
    i_Clk           : IN STD_LOGIC;
    i_Rst           : IN STD_LOGIC;
    o_Rx_Serial     : OUT STD_LOGIC;
    io_Pin_Port     : INOUT t_Reg16;
    io_Data         : INOUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF GPIO IS
    CONSTANT c_GPIO_PINMUX_REG_INDEX : INTEGER := 0;
    CONSTANT c_GPIO_DATADIR_REG_INDEX : INTEGER := 1;
    CONSTANT c_GPIO_DATAOUT_REG_INDEX : INTEGER := 2;
    CONSTANT c_GPIO_DATAIN_REG_INDEX : INTEGER := 3;
    CONSTANT c_GPIO_PINMUX_REG_TXSEL_BIT : INTEGER := c_TX_PIN;
    CONSTANT c_GPIO_PINMUX_REG_RXSEL_BIT : INTEGER := c_RX_PIN;
    CONSTANT c_GPIO_PINMUX_REG_PWMSEL_BIT : INTEGER := c_PWM_PIN;
    
    TYPE t_RegisterArray IS ARRAY (0 TO c_GPIO_SIZE - 1) OF t_Reg16;
    
    SIGNAL r_Registers : t_RegisterArray;

    SIGNAL r_Rx_Serial : STD_LOGIC := '0';
    SIGNAL r_Data_Out : t_Reg16 := (OTHERS => '0');
    
    SIGNAL w_Address : INTEGER RANGE 0 TO c_GPIO_SIZE - 1 := 0;
    
    ALIAS a_PINMUX_reg : t_Reg16 IS r_Registers(c_GPIO_PINMUX_REG_INDEX);
    ALIAS a_DATADIR_reg : t_Reg16 IS r_Registers(c_GPIO_DATADIR_REG_INDEX);
    ALIAS a_DATAOUT_reg : t_Reg16 IS r_Registers(c_GPIO_DATAOUT_REG_INDEX); 
    ALIAS a_DATAIN_reg : t_Reg16 IS r_Registers(c_GPIO_DATAIN_REG_INDEX);
BEGIN    
    w_Address <= TO_INTEGER(t_UReg16(i_Address));
    
    io_Data <= r_Data_Out WHEN (i_Output_Enable = '1') ELSE (OTHERS => 'Z');
    
    -- User interface (CPU <-> Controller)
    PROCESS(i_Clk, i_Rst)
    BEGIN
        -- Reset State
        IF(i_Rst = '1') THEN
            r_Registers <= (OTHERS => (OTHERS => '0'));
            r_Data_Out <= (OTHERS => 'Z');
        
        ELSIF(RISING_EDGE(i_Clk)) THEN
            IF(i_Write_Enable = '1') THEN
                r_Registers(w_Address) <= io_Data;
            ELSIF(i_Output_Enable = '1') THEN
                r_Data_Out <= r_Registers(w_Address);
            END IF;
               
            loop_INPUT_PIN_INTERFACE:
            FOR i IN 0 TO io_Pin_Port'LENGTH - 1 LOOP
                IF(io_Pin_Port(i) = '1') THEN
                    a_DATAIN_reg(i) <= '1';
                ELSE
                    a_DATAIN_reg(i) <= '0';
                END IF;
            END LOOP loop_INPUT_PIN_INTERFACE;
        END IF;
    END PROCESS; 

    -- Pin interface (Controller <-> Pin)
    PROCESS(i_Rst, i_Clk)
    BEGIN
        IF(i_Rst = '1') THEN
            r_Rx_Serial <= '1';
            o_Rx_Serial <= '1';
            io_Pin_Port <= (OTHERS => 'Z');
        ELSIF(RISING_EDGE(i_Clk)) THEN
            loop_OUTPUT_PIN_INTERFACE:
            FOR i IN 0 TO io_Pin_Port'LENGTH - 1 LOOP
                IF(a_PINMUX_reg(c_GPIO_PINMUX_REG_TXSEL_BIT) = '1' AND i = c_TX_PIN) THEN
                    io_Pin_Port(i) <= i_Tx_Serial;
                ELSIF(a_PINMUX_reg(c_GPIO_PINMUX_REG_RXSEL_BIT) = '0' AND i = c_RX_PIN) THEN
                    io_Pin_Port(i) <= a_DATAOUT_reg(i);
                ELSIF(a_PINMUX_reg(c_GPIO_PINMUX_REG_PWMSEL_BIT) = '1' AND i = c_PWM_PIN) THEN
                    io_Pin_Port(i) <= i_Pwm_Channel;
                ELSIF(a_DATADIR_reg(i) = '1') THEN
                    io_Pin_Port(i) <= a_DATAOUT_reg(i);
                ELSE
                    io_Pin_Port(i) <= 'Z';
                END IF;       
            END LOOP loop_OUTPUT_PIN_INTERFACE;
            
            -- Assign RX signal (P14)
            IF(a_PINMUX_reg(c_GPIO_PINMUX_REG_RXSEL_BIT) = '1') THEN
                r_Rx_Serial <= io_Pin_Port(c_RX_PIN);
                o_Rx_Serial <= r_Rx_Serial;
            ELSE
                r_Rx_Serial <= '1';
                o_Rx_Serial <= '1';
            END IF;
        END IF;
    END PROCESS;
    
END ARCHITECTURE;