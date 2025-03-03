LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY STD;
USE STD.TEXTIO.ALL;

PACKAGE ProcessorPkg IS
    -- Common Constants
    CONSTANT c_WORD_SIZE : INTEGER := 16;
    CONSTANT c_CPU_FREQ : INTEGER := 25000000;
    CONSTANT c_UART_BAUD_RATE : INTEGER := 115200;
    CONSTANT c_TX_PIN : INTEGER := 13;
    CONSTANT c_RX_PIN : INTEGER := 14;
    CONSTANT c_PWM_PIN : INTEGER := 15;
    
    -- Common Types
    SUBTYPE t_Nibble IS STD_LOGIC_VECTOR(3 DOWNTO 0);
    SUBTYPE t_Byte IS STD_LOGIC_VECTOR(7 DOWNTO 0);
    SUBTYPE t_Reg16 IS STD_LOGIC_VECTOR(c_WORD_SIZE - 1 DOWNTO 0);
    SUBTYPE t_UReg16 IS UNSIGNED(c_WORD_SIZE - 1 DOWNTO 0);
    SUBTYPE t_SReg16 IS SIGNED(c_WORD_SIZE - 1 DOWNTO 0);

    -- RAM Memory Sizes and Addresses (in words)
    CONSTANT c_RAM_SIZE : INTEGER := 2**8; -- 2**14
    CONSTANT c_RAM_BASE_ADDR : t_UReg16 := x"0000";
    CONSTANT c_RAM_LIMIT_ADDR : t_UReg16 := c_RAM_BASE_ADDR + 2 * c_RAM_SIZE;

    -- ROM Memory Sizes and Addresses (in words)
    CONSTANT c_ROM_SIZE : INTEGER := 2**7; 
    CONSTANT c_ROM_BASE_ADDR : t_UReg16 := x"E000";
    CONSTANT c_ROM_LIMIT_ADDR : t_UReg16 := c_ROM_BASE_ADDR + 2 * c_ROM_SIZE;

    -- IO Memory Sizes and Addresses (in words)
    CONSTANT c_IO_BASE_ADDR : t_UReg16 := x"F000";

    -- Peripherals Addresses (Led & Switch)
    CONSTANT c_LED_SWITCH_SIZE : INTEGER := 2;
    CONSTANT c_LED_SWITCH_BASE_ADDR : t_UReg16 := c_IO_BASE_ADDR + x"0000";
    CONSTANT c_LED_SWITCH_LIMIT_ADDR : t_UReg16 := c_LED_SWITCH_BASE_ADDR + 2 * c_LED_SWITCH_SIZE;

    -- Peripherals Addresses (GPIO)
    CONSTANT c_GPIO_SIZE : INTEGER := 4;
    CONSTANT c_GPIO_BASE_ADDR : t_UReg16 := c_IO_BASE_ADDR + x"0100";
    CONSTANT c_GPIO_LIMIT_ADDR : t_UReg16 := c_GPIO_BASE_ADDR + 2 * c_GPIO_SIZE;

    -- Peripherals Addresses (Timer)
    CONSTANT c_TIMER_SIZE : INTEGER := 4;
    CONSTANT c_TIMER_BASE_ADDR : t_UReg16 := c_IO_BASE_ADDR + x"0200";
    CONSTANT c_TIMER_LIMIT_ADDR : t_UReg16 := c_TIMER_BASE_ADDR + 2 * c_TIMER_SIZE;

    -- Peripherals Addresses (PWM)
    CONSTANT c_PWM_SIZE : INTEGER := 5;
    CONSTANT c_PWM_BASE_ADDR : t_UReg16 := c_IO_BASE_ADDR + x"0300";
    CONSTANT c_PWM_LIMIT_ADDR : t_UReg16 := c_PWM_BASE_ADDR + 2 * c_PWM_SIZE;
    
    -- Peripherals Addresses (UART)
    CONSTANT c_UART_SIZE : INTEGER := 3;
    CONSTANT c_UART_BASE_ADDR : t_UReg16 := c_IO_BASE_ADDR + x"0400";
    CONSTANT c_UART_LIMIT_ADDR : t_UReg16 := c_UART_BASE_ADDR + 2 * c_UART_SIZE;
    
    -- Registers Default Values
    CONSTANT c_REGISTER_SP_INDEX : INTEGER := 6;
    CONSTANT c_REGISTER_PC_INDEX : INTEGER := 7;
    CONSTANT c_REGISTER_SP_INIT_VALUE : t_Reg16 := t_Reg16(c_RAM_LIMIT_ADDR - 2);
    CONSTANT c_REGISTER_PC_INIT_VALUE : t_Reg16 := t_Reg16(c_ROM_BASE_ADDR);
    
    -- ALU Flag Indexes
    CONSTANT c_ZERO_FLAG_INDEX : INTEGER := 0;
    CONSTANT c_CARRY_FLAG_INDEX : INTEGER := 1;
    
    TYPE t_OperationType IS (
        type_JUMP,
        type_BRANCH,
        type_LOAD,
        type_STORE,
        type_MOVE,
        type_ALU,
        type_COMPARE,
        type_STACK,
        type_HALT,
        type_INVALID
    );

    TYPE t_Operation IS (
        op_JMP,
        op_BEQ,
        op_BNE,
        op_BLT,
        op_BGE,
        op_LDR,
        op_STR,
        op_MOV,
        op_MOVU,
        op_ADD,
        op_SUB,
        op_AND,
        op_OR,
        op_XOR,
        op_SHR,
        op_SHL,
        op_CMP,
        op_NOT,
        op_NEG,
        op_PUSH,
        op_POP,
        op_HALT,
        op_INVALID
    );
    
    PURE FUNCTION f_DecodeInstruction(i_Instruction : t_Reg16) RETURN t_Operation;
    PURE FUNCTION f_GetOperationType(i_Operation : t_Operation) RETURN t_OperationType;
END ProcessorPkg;

PACKAGE BODY ProcessorPkg IS
    PURE FUNCTION f_DecodeInstruction(i_Instruction : t_Reg16) RETURN t_Operation IS
        ALIAS a_OPCODE IS i_Instruction(15 DOWNTO 12);
        ALIAS a_OPCODE_SELECT IS i_Instruction(1 DOWNTO 0);

        VARIABLE v_Operation : t_Operation := op_INVALID;
    BEGIN
        CASE a_OPCODE IS
            WHEN "0000" =>
                v_Operation := op_JMP;
            WHEN "0001" =>
                CASE a_OPCODE_SELECT IS
                    WHEN "00" =>
                        v_Operation := op_BEQ;
                    WHEN "01" =>
                        v_Operation := op_BNE;
                    WHEN "10" =>
                        v_Operation := op_BLT;
                    WHEN "11" =>
                        v_Operation := op_BGE;
                    WHEN OTHERS =>
                        v_Operation := op_INVALID;
                END CASE;
            WHEN "0010" =>
                v_Operation := op_LDR;
            WHEN "0011" =>
                v_Operation := op_STR;
            WHEN "0100" =>
                v_Operation := op_MOV;
            WHEN "0101" =>
                v_Operation := op_MOVU;
            WHEN "0110" =>
                v_Operation := op_ADD;
            WHEN "0111" =>
                v_Operation := op_SUB;
            WHEN "1000" =>
                v_Operation := op_AND;
            WHEN "1001" =>
                v_Operation := op_OR;
            WHEN "1010" =>
                v_Operation := op_XOR;
            WHEN "1011" =>
                v_Operation := op_SHR;
            WHEN "1100" =>
                v_Operation := op_SHL;
            WHEN "1101" =>
                v_Operation := op_CMP;
            WHEN "1110" =>
                CASE a_OPCODE_SELECT IS
                    WHEN "00" =>
                        v_Operation := op_NOT;
                    WHEN "01" =>
                        v_Operation := op_NEG;
                    WHEN OTHERS =>
                        v_Operation := op_INVALID;
                END CASE;
            WHEN "1111" =>                
                CASE a_OPCODE_SELECT IS
                    WHEN "00" =>
                        v_Operation := op_PUSH;
                    WHEN "01" =>
                        v_Operation := op_POP;
                    WHEN "11" =>
                        v_Operation := op_HALT;
                    WHEN OTHERS =>
                        v_Operation := op_INVALID;
                END CASE;
            WHEN OTHERS =>
                v_Operation := op_INVALID;
        END CASE;
        RETURN v_Operation;
    END f_DecodeInstruction;   
    
    PURE FUNCTION f_GetOperationType(i_Operation : t_Operation) RETURN t_OperationType IS
        VARIABLE v_Operation_Type : t_OperationType := type_INVALID;  
    BEGIN
        CASE i_Operation IS
            WHEN op_JMP =>
                v_Operation_Type := type_JUMP;
            WHEN op_BEQ | op_BNE | op_BLT | op_BGE =>
                v_Operation_Type := type_BRANCH;
            WHEN op_LDR =>
                v_Operation_Type := type_LOAD;
            WHEN op_STR =>
                v_Operation_Type := type_STORE;
            WHEN op_MOV | op_MOVU =>
                v_Operation_Type := type_MOVE;
            WHEN op_CMP =>
                v_Operation_Type := type_COMPARE;
            WHEN op_PUSH | op_POP =>
                v_Operation_Type := type_STACK;
            WHEN op_HALT =>
                v_Operation_Type := type_HALT;
            WHEN OTHERS =>
                v_Operation_Type := type_ALU;
        END CASE;
        RETURN v_Operation_Type;
    END f_GetOperationType;
END ProcessorPkg;
