LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY UART IS
PORT (
    i_Address       : IN t_Reg16;
    i_Write_Enable  : IN STD_LOGIC;
    i_Output_Enable : IN STD_LOGIC;
    i_Rx_Serial     : IN STD_LOGIC;
    i_Clk           : IN STD_LOGIC;
    i_Rst           : IN STD_LOGIC;
    o_Tx_Serial     : OUT STD_LOGIC;
    o_Irq           : OUT STD_LOGIC;
    io_Data         : INOUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF UART IS 
    CONSTANT c_UART_TXDATA_REG_INDEX : INTEGER := 0;
    CONSTANT c_UART_RXDATA_REG_INDEX : INTEGER := 1;
    CONSTANT c_UART_CONTROL_REG_INDEX : INTEGER := 2;
    
    CONSTANT c_UART_CONTROL_REG_TXEN_BIT : INTEGER := 0;
    CONSTANT c_UART_CONTROL_REG_TXDONE_BIT : INTEGER := 1;
    CONSTANT c_UART_CONTROL_REG_RXDONE_BIT : INTEGER := 2;
    CONSTANT c_UART_CONTROL_REG_TXIRQEN_BIT : INTEGER := 3;
    CONSTANT c_UART_CONTROL_REG_RXIRQEN_BIT : INTEGER := 4;
    
    TYPE t_RegisterArray IS ARRAY (0 TO c_UART_SIZE - 1) OF t_Reg16; 
    SIGNAL r_Registers : t_RegisterArray := (OTHERS => (OTHERS => '0'));

    SIGNAL r_Data_Out : t_Reg16 := (OTHERS => '0');
    
    SIGNAL w_Address : INTEGER RANGE 0 TO c_UART_SIZE - 1 := 0;
    SIGNAL w_Tx_Byte : t_Byte := (OTHERS => '0');
    SIGNAL w_Tx_Transmit : STD_LOGIC := '0';
    SIGNAL w_Tx_Done : STD_LOGIC := '0';
    SIGNAL w_Rx_Done : STD_LOGIC := '0';
    SIGNAL w_Rx_Byte : t_Byte := (OTHERS => '0');
BEGIN 
    e_UART_TX: ENTITY WORK.Transmitter
    PORT MAP (
        i_Tx_Byte       => w_Tx_Byte,
        i_Tx_Transmit   => w_Tx_Transmit,
        i_Clk           => i_Clk,
        i_Rst           => i_Rst,
        o_Tx_Serial     => o_Tx_Serial,
        o_Tx_Done       => w_Tx_Done
    );
    e_UART_RX: ENTITY WORK.Receiver
    PORT MAP (
        i_Rx_Serial     => i_Rx_Serial,
        i_Clk           => i_Clk,
        i_Rst           => i_Rst,
        o_Rx_Done       => w_Rx_Done,
        o_Rx_Byte       => w_Rx_Byte
    );

    w_Tx_Byte <= r_Registers(c_UART_TXDATA_REG_INDEX)(7 DOWNTO 0);
    w_Tx_Transmit <= r_Registers(c_UART_CONTROL_REG_INDEX)(c_UART_CONTROL_REG_TXEN_BIT);
    
    o_Irq <= (r_Registers(c_UART_CONTROL_REG_INDEX)(c_UART_CONTROL_REG_TXDONE_BIT) AND (r_Registers(c_UART_CONTROL_REG_INDEX)(c_UART_CONTROL_REG_TXIRQEN_BIT)))
            OR (r_Registers(c_UART_CONTROL_REG_INDEX)(c_UART_CONTROL_REG_RXDONE_BIT) AND (r_Registers(c_UART_CONTROL_REG_INDEX)(c_UART_CONTROL_REG_RXIRQEN_BIT)));

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
            
            -- Update RXDATA Registers
            IF(w_Rx_Done = '1') THEN
                r_Registers(c_UART_RXDATA_REG_INDEX) <= x"00" & w_Rx_Byte;
            END IF;

            -- Clear transmit bit
            IF(r_Registers(c_UART_CONTROL_REG_INDEX)(c_UART_CONTROL_REG_TXEN_BIT) = '1') THEN
                r_Registers(c_UART_CONTROL_REG_INDEX)(c_UART_CONTROL_REG_TXEN_BIT) <= '0';
            END IF;
            
            -- Update RX Done Flag
            IF(r_Registers(c_UART_CONTROL_REG_INDEX)(c_UART_CONTROL_REG_RXDONE_BIT) = '0' AND w_Rx_Done = '1') THEN
                r_Registers(c_UART_CONTROL_REG_INDEX)(c_UART_CONTROL_REG_RXDONE_BIT) <= '1';
            END IF;
            
            r_Registers(c_UART_CONTROL_REG_INDEX)(c_UART_CONTROL_REG_TXDONE_BIT) <= w_Tx_Done;
        END IF;
    END PROCESS p_REGISTERS_READ_WRITE_CONTROL;
END ARCHITECTURE;