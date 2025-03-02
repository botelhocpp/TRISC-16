LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY InputOutputModule IS
PORT (
    i_Address       : IN t_Reg16;
    i_Write_Enable  : IN STD_LOGIC;
    i_Output_Enable : IN STD_LOGIC;
    i_Clk           : IN STD_LOGIC;
    i_Rst           : IN STD_LOGIC;
    i_Buttons       : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Leds          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    io_Data         : INOUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF InputOutputModule IS 
    CONSTANT c_BUTTONS_ADDRESS : INTEGER := 0;
    CONSTANT c_LEDS_ADDRESS : INTEGER := 1;
    CONSTANT c_COUNTER_RELOAD_ADDRESS : INTEGER := 9;
    CONSTANT c_COUNTER_CONTROL_ADDRESS : INTEGER := 10;
    CONSTANT c_COUNTER_COUNT_ADDRESS : INTEGER := 11;
    
    TYPE t_IORegisterArray IS ARRAY (0 TO 15) OF t_Reg16; 
    SIGNAL r_IO_Registers : t_IORegisterArray := (OTHERS => (OTHERS => '0'));

    SIGNAL r_Leds : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL r_Data_Out : t_Reg16 := (OTHERS => '0');
    
    SIGNAL w_Address : INTEGER RANGE 0 TO 15 := 0;

    SIGNAL w_Counter_Input : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Counter_Output : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Counter_Prescaler : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Counter_Load : STD_LOGIC := '0';
    SIGNAL w_Counter_Done : STD_LOGIC := '0';
    SIGNAL w_Counter_Clk : STD_LOGIC := '0';
BEGIN 
    e_PRESCALER: ENTITY WORK.Prescaler
    PORT MAP(
        i_Clk       => i_Clk,
        i_Divider   => w_Counter_Prescaler,
        i_Rst       => i_Rst,
        o_Clk       => w_Counter_Clk
    );
    e_COUNTER: ENTITY WORK.Counter
    PORT MAP(
        i_Value => w_Counter_Input,
        i_Load  => w_Counter_Load,
        i_Clk   => w_Counter_Clk,
        i_Rst   => i_Rst,
        o_Done  => w_Counter_Done,
        o_Value => w_Counter_Output
    );

    w_Counter_Input <= r_IO_Registers(c_COUNTER_RELOAD_ADDRESS);
    w_Counter_Load <= r_IO_Registers(c_COUNTER_CONTROL_ADDRESS)(0);
    w_Counter_Prescaler <= "00" & r_IO_Registers(c_COUNTER_CONTROL_ADDRESS)(15 DOWNTO 2);

    o_Leds <= r_Leds;
    
    io_Data <= r_Data_Out WHEN (i_Output_Enable = '1') ELSE (OTHERS => 'Z');
    
    w_Address <= TO_INTEGER(t_UReg16(i_Address));

    p_REGISTERS_READ_WRITE_CONTROL:
    PROCESS(i_Rst, i_Clk)
    BEGIN
        IF(i_Rst = '1') THEN
            r_IO_Registers <= (
                OTHERS => (OTHERS => '0')
            );
            r_Data_Out <= (OTHERS => '0');
        ELSIF(RISING_EDGE(i_Clk)) THEN
            r_IO_Registers(c_BUTTONS_ADDRESS)(3 DOWNTO 0) <= i_Buttons;
            r_IO_Registers(c_COUNTER_COUNT_ADDRESS) <= w_Counter_Output;
            r_IO_Registers(c_COUNTER_CONTROL_ADDRESS)(1) <= w_Counter_Done;

            IF(r_IO_Registers(c_COUNTER_CONTROL_ADDRESS)(0) = '1') THEN
                r_IO_Registers(c_COUNTER_CONTROL_ADDRESS)(0) <= '0';
            END IF;
            
            IF(w_Address < 16) THEN
                IF(i_Write_Enable = '1') THEN
                    IF(w_Address = c_COUNTER_CONTROL_ADDRESS) THEN
                        FOR i IN r_IO_Registers(c_COUNTER_CONTROL_ADDRESS)'RANGE LOOP
                            IF(i /= 1) THEN
                                r_IO_Registers(w_Address)(i) <= io_Data(i);
                            END IF;
                        END LOOP;
                    ELSIF(
                        w_Address /= c_BUTTONS_ADDRESS AND
                        w_Address /= c_COUNTER_COUNT_ADDRESS
                    ) THEN
                        r_IO_Registers(w_Address) <= io_Data;
                    END IF;
                ELSIF(i_Output_Enable = '1') THEN
                    r_Data_Out <= r_IO_Registers(w_Address);
                END IF;
            END IF;
        END IF;
    END PROCESS p_REGISTERS_READ_WRITE_CONTROL;

    p_DEVICES_CONTROL:
    PROCESS(i_Clk)
    BEGIN
        IF(RISING_EDGE(i_Clk)) THEN
            r_Leds <= r_IO_Registers(c_LEDS_ADDRESS)(3 DOWNTO 0);
        END IF;
    END PROCESS p_DEVICES_CONTROL;
END ARCHITECTURE;