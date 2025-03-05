LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY PWM IS
PORT (
    i_Address       : IN t_Reg16;
    i_Write_Enable  : IN STD_LOGIC;
    i_Output_Enable : IN STD_LOGIC;
    i_Clk           : IN STD_LOGIC;
    i_Rst           : IN STD_LOGIC;
    o_Pwm_Channel   : OUT STD_LOGIC;
    io_Data         : INOUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF PWM IS 
    CONSTANT c_PWM_RELOAD_REG_INDEX : INTEGER := 0;
    CONSTANT c_PWM_DUTY_REG_INDEX : INTEGER := 1;
    CONSTANT c_PWM_CONTROL_REG_INDEX : INTEGER := 2;
    CONSTANT c_PWM_PRESCALER_REG_INDEX : INTEGER := 3;
    CONSTANT c_PWM_COUNT_REG_INDEX : INTEGER := 4;
    
    CONSTANT c_PWM_CONTROL_REG_EN_BIT : INTEGER := 0;
    CONSTANT c_PWM_CONTROL_REG_VALUE_BIT : INTEGER := 1;
    
    TYPE t_RegisterArray IS ARRAY (0 TO c_PWM_SIZE - 1) OF t_Reg16; 
    SIGNAL r_Registers : t_RegisterArray := (OTHERS => (OTHERS => '0'));

    SIGNAL r_Data_Out : t_Reg16 := (OTHERS => '0');
    SIGNAL r_Pwm_Channel : STD_LOGIC := '0';
    
    SIGNAL w_Address : INTEGER RANGE 0 TO c_PWM_SIZE - 1 := 0;

    SIGNAL w_Counter_Input : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Counter_Output : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Counter_Prescaler : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Counter_Load : STD_LOGIC := '0';
    SIGNAL w_Counter_Done : STD_LOGIC := '0';
    SIGNAL w_Counter_Clk : STD_LOGIC := '0';
    SIGNAL w_Counter_Enable : STD_LOGIC := '0';
BEGIN 
    e_PRESCALER: ENTITY WORK.Prescaler
    PORT MAP (
        i_Clk       => i_Clk,
        i_Divider   => w_Counter_Prescaler,
        i_Rst       => i_Rst,
        o_Clk       => w_Counter_Clk
    );
    e_COUNTER: ENTITY WORK.Counter
    PORT MAP (
        i_Value => w_Counter_Input,
        i_Load  => w_Counter_Load,
        i_Count => w_Counter_Enable,
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        o_Done  => w_Counter_Done,
        o_Value => w_Counter_Output
    );
    e_SYNC_PULSE: ENTITY WORK.SyncPulse
    PORT MAP (
        i_Main_Clk => i_Clk,
        i_Sub_Clk => w_Counter_Clk,
        i_Rst => i_Rst,
        o_Sync_Pulse => w_Counter_Enable
    );

    w_Counter_Input <= r_Registers(c_PWM_RELOAD_REG_INDEX);
    w_Counter_Load <= r_Registers(c_PWM_CONTROL_REG_INDEX)(c_PWM_CONTROL_REG_EN_BIT) AND w_Counter_Done;
    w_Counter_Prescaler <= r_Registers(c_PWM_PRESCALER_REG_INDEX);
    
    o_Pwm_Channel <= r_Pwm_Channel;

    io_Data <= r_Data_Out WHEN (i_Output_Enable = '1') ELSE (OTHERS => 'Z');
    
    w_Address <= TO_INTEGER(t_UReg16(i_Address));

    p_REGISTERS_READ_WRITE_CONTROL:
    PROCESS(i_Rst, i_Clk)
    BEGIN
        IF(i_Rst = '1') THEN
            r_Registers <= (OTHERS => (OTHERS => '0'));
            r_Data_Out <= (OTHERS => '0');
            r_Pwm_Channel <= '0';
        ELSIF(RISING_EDGE(i_Clk)) THEN
            IF(i_Write_Enable = '1') THEN
                r_Registers(w_Address) <= io_Data;
            ELSIF(i_Output_Enable = '1') THEN
                r_Data_Out <= r_Registers(w_Address);
            END IF;
            
            r_Registers(c_PWM_COUNT_REG_INDEX) <= w_Counter_Output;
            r_Registers(c_PWM_CONTROL_REG_INDEX)(c_PWM_CONTROL_REG_VALUE_BIT) <= r_Pwm_Channel;

            IF(r_Registers(c_PWM_COUNT_REG_INDEX) < r_Registers(c_PWM_DUTY_REG_INDEX)) THEN
                r_Pwm_Channel <= '1';
            ELSIF(r_Registers(c_PWM_COUNT_REG_INDEX) >= r_Registers(c_PWM_DUTY_REG_INDEX)) THEN
                r_Pwm_Channel <= '0';
            END IF;
        END IF;
    END PROCESS p_REGISTERS_READ_WRITE_CONTROL;
END ARCHITECTURE;