-- LIBRARY IEEE;
-- USE IEEE.STD_LOGIC_1164.ALL;
-- USE IEEE.NUMERIC_STD.ALL;

-- LIBRARY WORK;
-- USE WORK.ProcessorPkg.ALL;

-- ENTITY GPIO IS
-- PORT (
--     i_Address       : IN t_Reg16;
--     i_Write_Enable  : IN STD_LOGIC;
--     i_Output_Enable : IN STD_LOGIC;
--     i_Tx_Serial     : IN STD_LOGIC;
--     i_Pwm_Channel   : IN STD_LOGIC;
--     i_Clk           : IN STD_LOGIC;
--     i_Rst           : IN STD_LOGIC;
--     o_Rx_Serial     : OUT STD_LOGIC;
--     io_Gpio_Port    : INOUT t_Reg16;
--     io_Pin_Port     : INOUT t_Reg16;
--     io_Data         : INOUT t_Reg16
-- );
-- END ENTITY;

-- ARCHITECTURE RTL OF GPIO IS
--     CONSTANT c_PORT_MUX_REG_INDEX : INTEGER := 0;
    
--     TYPE t_RegisterArray IS ARRAY (0 TO c_PORT_SIZE - 1) OF t_Reg16;
    
--     SIGNAL r_Registers : t_RegisterArray;

--     SIGNAL r_Data_Out : t_Reg16 := (OTHERS => '0');
--     SIGNAL r_Pin_Port_Out : t_Reg16 := (OTHERS => 'Z');
    
--     SIGNAL w_Address : INTEGER RANGE 0 TO c_GPIO_SIZE - 1 := 0;
    
--     ALIAS a_DATADIR_reg : t_Reg16 IS r_Registers(c_GPIO_DATADIR_REG_INDEX);
--     ALIAS a_DATAOUT_reg : t_Reg16 IS r_Registers(c_GPIO_DATAOUT_REG_INDEX); 
--     ALIAS a_DATAIN_reg : t_Reg16 IS r_Registers(c_GPIO_DATAIN_REG_INDEX);
-- BEGIN    
--     w_Address <= TO_INTEGER(t_UReg16(i_Address));
    
--     io_Data <= r_Data_Out WHEN (i_Output_Enable = '1') ELSE (OTHERS => 'Z');
    
--     -- User interface (CPU <-> Controller)
--     PROCESS(i_Clk, i_Rst)
--     BEGIN
--         -- Reset State
--         IF(i_Rst = '1') THEN
--             r_Registers <= (
--                 c_GPIO_DATADIR_REG_INDEX => (OTHERS => '0'),
--                 c_GPIO_DATAOUT_REG_INDEX => (OTHERS => '0'),
--                 c_GPIO_DATAIN_REG_INDEX => (OTHERS => 'Z')
--             );
--             r_Data_Out <= (OTHERS => 'Z');
        
--         ELSIF(RISING_EDGE(i_Clk)) THEN
--             IF(i_Write_Enable = '1') THEN
--                 r_Registers(w_Address) <= io_Data;
--             ELSIF(i_Output_Enable = '1') THEN
--                 r_Data_Out <= r_Registers(w_Address);
--             END IF;
               
--             loop_INPUT_PIN_INTERFACE:
--             FOR i IN 0 TO io_Pin_Port'LENGTH - 1 LOOP
--                 IF(io_Pin_Port(i) = '1') THEN
--                     a_DATAIN_reg(i) <= '1';
--                 ELSE
--                     a_DATAIN_reg(i) <= '0';
--                 END IF;
--             END LOOP loop_INPUT_PIN_INTERFACE;
--         END IF;
--     END PROCESS;
        
--     io_Pin_Port 
    
-- END ARCHITECTURE;