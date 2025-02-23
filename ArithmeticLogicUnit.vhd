LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY ArithmeticLogicUnit IS
PORT(
    i_Op_A          : IN t_Reg16;
    i_Op_B          : IN t_Reg16;
    i_Sel           : IN t_Operation;
    o_Flag_Zero     : OUT STD_LOGIC;
    o_Flag_Carry    : OUT STD_LOGIC;
    o_Result        : OUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF ArithmeticLogicUnit IS
    SUBTYPE t_UReg17 IS UNSIGNED(c_WORD_SIZE DOWNTO 0);

    CONSTANT c_ZERO : t_UReg17 := (OTHERS => '0');
    
    SIGNAL w_Result : t_UReg17 := (OTHERS => '0');
    SIGNAL w_Op_A : t_UReg17 := (OTHERS => '0');
    SIGNAL w_Op_B : t_UReg17 := (OTHERS => '0');
BEGIN
    w_Op_A <= RESIZE(t_UReg16(i_Op_A), c_WORD_SIZE + 1);
    w_Op_B <= RESIZE(t_UReg16(i_Op_B), c_WORD_SIZE + 1);

    WITH i_Sel SELECT
        w_Result <= (w_Op_A - w_Op_B)                           WHEN op_SUB | op_CMP | op_PUSH,
                    (SHIFT_LEFT(w_Op_A, TO_INTEGER(w_Op_B)))    WHEN op_SHL,
                    (SHIFT_RIGHT(w_Op_A, TO_INTEGER(w_Op_B)))   WHEN op_SHR,
                    (w_Op_A AND w_Op_B)                         WHEN op_AND,
                    (w_Op_A OR w_Op_B)                          WHEN op_OR,
                    (w_Op_A XOR w_Op_B)                         WHEN op_XOR,
                    (NOT w_Op_A)                                WHEN op_NOT,
                    (0 - w_Op_A)                                WHEN op_NEG,
                    (w_Op_B)                                    WHEN op_MOV,
                    (SHIFT_LEFT(w_Op_B, 8) OR w_Op_A)           WHEN op_MOVU,
                    (w_Op_A + w_Op_B)                           WHEN OTHERS;

    o_Result <= t_Reg16(w_Result(c_WORD_SIZE - 1 DOWNTO 0));

	o_Flag_Zero <= '1' WHEN (w_Result = c_ZERO) ELSE '0';
	
    p_GENERATE_CARRY_FLAG:
    PROCESS(w_Op_A, w_Op_B, w_Result, i_Sel)
    BEGIN
        IF(i_Sel = op_SUB OR i_Sel = op_CMP) THEN
            IF(w_Op_A < w_Op_B) THEN
                o_Flag_Carry <= '1';
            ELSE
                o_Flag_Carry <= '0';
            END IF;
        ELSE
            o_Flag_Carry <= w_Result(c_WORD_SIZE);
        END IF;
    END PROCESS p_GENERATE_CARRY_FLAG;
END ARCHITECTURE;
