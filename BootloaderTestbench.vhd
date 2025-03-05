LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY BootloaderTestbench IS
END ENTITY;

ARCHITECTURE Structural OF BootloaderTestbench IS
    CONSTANT c_CLOCK_PERIOD : TIME := 8ns;
    CONSTANT c_CLKS_PER_BIT : INTEGER := c_CPU_FREQ/c_UART_BAUD_RATE;
    CONSTANT c_BIT_PERIOD : TIME := 8680ns;
    CONSTANT c_TEST_SIZE : INTEGER := 53;

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
        x"0801", -- jmp _start
        x"0816", -- jmp _irq_handler
        x"e003", -- crid
        x"4c00", -- mov s0 #0
        x"5cf2", -- movu s0 #0xF2
        x"4d00", -- mov s1 #0
        x"5df1", -- movu s1 #0xF1
        x"4aff", -- mov t0 #0xFF
        x"5aff", -- movu t0 #0xFF
        x"38a9", -- str t0 [s1 #0x02]
        x"4a00", -- mov t0 #0
        x"5a40", -- movu t0 #0x40
        x"38a8", -- str t0 [s1 #0x00]
        x"4ae8", -- mov t0 #0xE8
        x"5a03", -- movu t0 #0x03
        x"388a", -- str t0 [s0 #0x04]
        x"4a09", -- mov t0 #0x09
        x"5a00", -- movu t0 #0x00
        x"3888", -- str t0 [s0 #0x00]
        x"4a01", -- mov t0 #0x01
        x"9a44", -- or t0 t0 #0x04
        x"3889", -- str t0 [s0 #0x02]
        x"e002", -- crie
        x"0fff", -- jmp while
        x"e003", -- crid
        x"f8c0", -- push r0
        x"f8c4", -- push r1
        x"f8c8", -- push r2
        x"f8cc", -- push r3
        x"f8d0", -- push r4
        x"f8d4", -- push r5
        x"2881", -- ldr a0 [s0 #0x02]
        x"8902", -- and a1 a0 #0x02
        x"1828", -- beq isr_end
        x"2ba2", -- ldr t1 [s1 #0x04]
        x"4aff", -- mov t0 #0xFF
        x"5aff", -- movu t0 #0xFF
        x"a368", -- xor t1 t1 t0
        x"38ae", -- str t1 [s1 #0x04]
        x"4a02", -- mov t0 #0x02
        x"e240", -- not t0 t0
        x"8008", -- and a0 a0 t0
        x"9801", -- or a0 a0 #0x01
        x"3881", -- str a0 [s0 #0x02]
        x"fdc1", -- pop r5
        x"fcc1", -- pop r4
        x"fbc1", -- pop r3
        x"fac1", -- pop r2
        x"f9c1", -- pop r1
        x"f8c1", -- pop r0
        x"e002", -- crie
        x"ffc2", -- iret
        x"ffff",
        OTHERS => (OTHERS => '0')
    );
    SIGNAL r_Test_Counter : INTEGER RANGE 0 TO c_TEST_SIZE := 0;
    SIGNAL r_Test_Byte : t_Byte := (OTHERS => '0');

    -- Input/Output Signals
    SIGNAL i_Clk        : STD_LOGIC := '0';
    SIGNAL i_Rst        : STD_LOGIC := '0';
    SIGNAL i_Soft_Rst    : STD_LOGIC := '0';
    SIGNAL i_Switches   : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL o_Leds       : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL io_Pin_Port  : t_Reg16 := (
        c_RX_PIN => '1',
        OTHERS => '0'
    );
BEGIN
    e_Microcontroller: ENTITY WORK.Microcontroller
    PORT MAP (
        i_Soft_Rst      => i_Soft_Rst,
        i_Clk           => i_Clk,
        i_Rst           => i_Rst,
        i_Switches      => i_Switches,
        o_Leds          => o_Leds,
        io_Pin_Port     => io_Pin_Port
    );
    
    i_Clk <= NOT i_Clk AFTER c_CLOCK_PERIOD/2;
    i_Rst <= '1', '0' AFTER c_CLOCK_PERIOD/4;
    i_Soft_Rst <= '0', '1' AFTER 10ms, '0' AFTER 11ms;
    i_Switches <= "0101" AFTER 7ms, "0110" AFTER 13ms;

    p_SEND_UART_DATA:
    PROCESS
    BEGIN
        r_Test_Byte <= r_TestContents(r_Test_Counter)(7 DOWNTO 0);
        WAIT FOR 50*c_CLOCK_PERIOD;
        WAIT UNTIL RISING_EDGE(i_Clk);
        proc_UART_WRITE_BYTE(r_Test_Byte, io_Pin_Port(c_RX_PIN));
        
        r_Test_Byte <= r_TestContents(r_Test_Counter)(15 DOWNTO 8);
        WAIT FOR 20*c_CLOCK_PERIOD;
        WAIT UNTIL RISING_EDGE(i_Clk);
        proc_UART_WRITE_BYTE(r_Test_Byte, io_Pin_Port(c_RX_PIN));

        r_Test_Counter <= r_Test_Counter + 1;
        WAIT UNTIL RISING_EDGE(i_Clk);
        IF(r_Test_Counter = c_TEST_SIZE) THEN
            WAIT;
        END IF;
    END PROCESS p_SEND_UART_DATA;
END ARCHITECTURE;