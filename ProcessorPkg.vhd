LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY STD;
USE STD.TEXTIO.ALL;

PACKAGE ProcessorPkg IS
    CONSTANT c_MEMORY_SIZE : INTEGER := 8192;
    CONSTANT c_WORD_SIZE : INTEGER := 16;
    
    CONSTANT c_ZERO_FLAG_INDEX : INTEGER := 0;
    CONSTANT c_CARRY_FLAG_INDEX : INTEGER := 1;
    
    CONSTANT c_REGISTER_SP_INDEX : INTEGER := 6;
    CONSTANT c_REGISTER_PC_INDEX : INTEGER := 7;

    SUBTYPE t_Nibble IS STD_LOGIC_VECTOR(3 DOWNTO 0);
    SUBTYPE t_Byte IS STD_LOGIC_VECTOR(7 DOWNTO 0);
    SUBTYPE t_Reg16 IS STD_LOGIC_VECTOR(c_WORD_SIZE - 1 DOWNTO 0);
    SUBTYPE t_UReg16 IS UNSIGNED(c_WORD_SIZE - 1 DOWNTO 0);
    SUBTYPE t_SReg16 IS SIGNED(c_WORD_SIZE - 1 DOWNTO 0);
    
    CONSTANT c_REGISTER_SP_INIT_VALUE : t_Reg16 := t_Reg16(TO_UNSIGNED(c_MEMORY_SIZE - 2, c_WORD_SIZE));
    CONSTANT c_REGISTER_PC_INIT_VALUE : t_Reg16 := x"0020";
    
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
        op_BLE,
        op_BGT,
        op_LDR,
        op_STR,
        op_MOV,
        op_ADD,
        op_SUB,
        op_MUL,
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
                        v_Operation := op_BLE;
                    WHEN "11" =>
                        v_Operation := op_BGT;
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
                v_Operation := op_ADD;
            WHEN "0110" =>
                v_Operation := op_SUB;
            WHEN "0111" =>
                v_Operation := op_MUL;
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
            WHEN op_BEQ | op_BNE | op_BLE | op_BGT =>
                v_Operation_Type := type_BRANCH;
            WHEN op_LDR =>
                v_Operation_Type := type_LOAD;
            WHEN op_STR =>
                v_Operation_Type := type_STORE;
            WHEN op_MOV =>
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
