LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY BootloaderTestbench IS
END ENTITY;

ARCHITECTURE Structural OF BootloaderTestbench IS
    CONSTANT c_CLOCK_PERIOD : TIME := 40ns;
    CONSTANT c_CLKS_PER_BIT : INTEGER := c_CPU_FREQ/c_UART_BAUD_RATE;
    CONSTANT c_BIT_PERIOD : TIME := 8680ns;
    CONSTANT c_TEST_SIZE : INTEGER := 20;

    PROCEDURE proc_UART_WRITE_BYTE (
        SIGNAL i_Data   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        SIGNAL o_Serial : OUT STD_LOGIC
    ) IS
    BEGIN
        -- Send Start Bit
        o_Serial <= '0';
        WAIT FOR c_BIT_PERIOD;
    
        -- Send Data Byte
        FOR ii IN 0 TO 7 loop
            o_Serial <= i_Data(ii);
            WAIT FOR c_BIT_PERIOD;
        END LOOP;  -- ii

        -- Send Stop Bit
        o_Serial <= '1';
        WAIT FOR c_BIT_PERIOD;
    END proc_UART_WRITE_BYTE;

    TYPE t_UartTestContents IS ARRAY (0 TO c_TEST_SIZE - 1) OF t_Reg16;

    SIGNAL r_TestContents : t_UartTestContents := (
        x"4c00",
        x"5cf2",
        x"4d00",
        x"5df0",
        x"4acf",
        x"5a07",
        x"388a",
        x"4a24",
        x"5af4",
        x"3888",
        x"2aa0",
        x"aa4f",
        x"38a8",
        x"4a01",
        x"3889",
        x"2a81",
        x"8a42",
        x"1ff4",
        x"0ff7",
        x"ffff",
        OTHERS => (OTHERS => '0')
    );
    SIGNAL r_Test_Counter : INTEGER RANGE 0 TO c_TEST_SIZE := 0;
    SIGNAL r_Test_Byte : t_Byte := (OTHERS => '0');

    -- Input/Output Signals
    SIGNAL i_Clk        : STD_LOGIC := '0';
    SIGNAL i_Rst        : STD_LOGIC := '0';
    SIGNAL i_Switches   : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL o_Leds       : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL io_Pin_Port  : t_Reg16 := (OTHERS => '0');
    SIGNAL o_Pwm_Channel : STD_LOGIC := '0';
    SIGNAL i_Rx_Serial : STD_LOGIC := '1';
    SIGNAL o_Tx_Serial : STD_LOGIC := '0';
BEGIN
    e_Microcontroller: ENTITY WORK.Microcontroller
    PORT MAP (
        i_Rx_Serial     => i_Rx_Serial,
        i_Clk           => i_Clk,
        i_Rst           => i_Rst,
        i_Switches      => i_Switches,
        o_Leds          => o_Leds,
        o_Pwm_Channel   => o_Pwm_Channel,
        o_Tx_Serial     => o_Tx_Serial,
        io_Pin_Port     => io_Pin_Port
    );
    
    i_Clk <= NOT i_Clk AFTER c_CLOCK_PERIOD/2;
    i_Rst <= '1', '0' AFTER c_CLOCK_PERIOD/4;

    p_SEND_UART_DATA:
    PROCESS
    BEGIN
        r_Test_Byte <= r_TestContents(r_Test_Counter)(7 DOWNTO 0);
        WAIT FOR 40*c_CLOCK_PERIOD;
        WAIT UNTIL RISING_EDGE(i_Clk);
        proc_UART_WRITE_BYTE(r_Test_Byte, i_Rx_Serial);
        
        r_Test_Byte <= r_TestContents(r_Test_Counter)(15 DOWNTO 8);
        WAIT FOR 20*c_CLOCK_PERIOD;
        WAIT UNTIL RISING_EDGE(i_Clk);
        proc_UART_WRITE_BYTE(r_Test_Byte, i_Rx_Serial);

        r_Test_Counter <= r_Test_Counter + 1;
        WAIT UNTIL RISING_EDGE(i_Clk);
        IF(r_Test_Counter = c_TEST_SIZE) THEN
            WAIT;
        END IF;
    END PROCESS p_SEND_UART_DATA;
END ARCHITECTURE;