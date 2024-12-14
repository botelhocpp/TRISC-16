LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY ControlUnit IS
PORT (    
    i_Instruction           : IN t_Reg16;
    i_Flags                 : IN t_Reg16;
    i_Clk                   : IN STD_LOGIC;
    i_Rst                   : IN STD_LOGIC;
    o_Select_Rm             : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    o_Select_Rn             : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    o_Select_Rd             : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    o_Register_Write_Enable : OUT STD_LOGIC;
    o_Memory_Write_Enable   : OUT STD_LOGIC;
    o_Memory_Output_Enable  : OUT STD_LOGIC;
    o_Load_Flags            : OUT STD_LOGIC;
    o_Input_Select          : OUT STD_LOGIC;
    o_Address_Select        : OUT STD_LOGIC;
    o_Operand_Select        : OUT STD_LOGIC;   
    o_Operation             : OUT t_Operation;
    o_Immediate             : OUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF ControlUnit IS
    TYPE t_InstructionCycle IS (
        s_FETCH_INSTRUCTION,
        s_STORE_INSTRUCTION,
        s_EXECUTE_INSTRUCTION,
        s_WRITE_BACK
    );
    SIGNAL r_Current_State : t_InstructionCycle := s_FETCH_INSTRUCTION;

    -- Aliases
    ALIAS a_ZERO_FLAG IS i_Flags(c_ZERO_FLAG_INDEX);
    ALIAS a_CARRY_FLAG IS i_Flags(c_CARRY_FLAG_INDEX);

    -- Wires
    SIGNAL w_Operation : t_Operation := op_INVALID;
    SIGNAL w_Select_Rm : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL w_Select_Rn : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL w_Select_Rd : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL w_Register_Write_Enable : STD_LOGIC := '0';
    SIGNAL w_Memory_Write_Enable : STD_LOGIC := '0';
    SIGNAL w_Memory_Output_Enable : STD_LOGIC := '0';
    SIGNAL w_Load_Flags : STD_LOGIC := '0';
    SIGNAL w_Input_Select : STD_LOGIC := '0';
    SIGNAL w_Address_Select : STD_LOGIC := '0';
    SIGNAL w_Operand_Select : STD_LOGIC := '0';   
    SIGNAL w_Load_IR : STD_LOGIC := '0';   
    SIGNAL w_Immediate : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Instruction : t_Reg16 := (OTHERS => '0');
BEGIN
    e_IR_REGISTER: ENTITY WORK.GenericRegister
    PORT MAP (
        i_D => i_Instruction,
        i_Load => w_Load_IR,
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        o_Q => w_Instruction
    );

    -- Map Control Signals
    o_Select_Rm <= w_Select_Rm;
    o_Select_Rn <= w_Select_Rn;
    o_Select_Rd <= w_Select_Rd;
    o_Register_Write_Enable <= w_Register_Write_Enable;
    o_Memory_Write_Enable <= w_Memory_Write_Enable;
    o_Memory_Output_Enable <= w_Memory_Output_Enable;
    o_Load_Flags <= w_Load_Flags;
    o_Input_Select <= w_Input_Select;
    o_Address_Select <= w_Address_Select;
    o_Operand_Select <= w_Operand_Select;
    o_Operation <= w_Operation;
    o_Immediate <= w_Immediate;

    p_INSTRUCTION_CYCLE_NEXT_STATE:
    PROCESS(i_Rst, i_Clk)
    BEGIN
        IF(i_Rst = '1') THEN
            r_Current_State <= s_FETCH_INSTRUCTION;
        ELSIF(RISING_EDGE(i_Clk)) THEN
            CASE r_Current_State IS
                WHEN s_FETCH_INSTRUCTION =>
                    r_Current_State <= s_STORE_INSTRUCTION;

                WHEN s_STORE_INSTRUCTION =>
                    r_Current_State <= s_EXECUTE_INSTRUCTION;
                    
                WHEN s_EXECUTE_INSTRUCTION =>
                    IF(w_Operation = op_LDR OR w_Operation = op_POP) THEN
                        r_Current_State <= s_WRITE_BACK;
                    ELSE
                        r_Current_State <= s_FETCH_INSTRUCTION;
                    END IF;
                
                WHEN s_WRITE_BACK =>
                    r_Current_State <= s_FETCH_INSTRUCTION;
                
            END CASE;
        END IF;
    END PROCESS p_INSTRUCTION_CYCLE_NEXT_STATE;

    p_INSTRUCTION_CYCLE_GENERATE_SIGNALS:
    PROCESS(i_Flags, r_Current_State, w_Instruction, w_Operation)
        VARIABLE v_Operation_Type : t_OperationType := type_INVALID;
    BEGIN
        -- Default values (inclined to ALU operations)
        w_Operation <= f_DecodeInstruction(w_Instruction);
        w_Select_Rd <= w_Instruction(10 DOWNTO 8);
        w_Select_Rm <= w_Instruction(7 DOWNTO 5);
        w_Select_Rn <= w_Instruction(4 DOWNTO 2);
        w_Register_Write_Enable <= '0';
        w_Memory_Write_Enable <= '0';
        w_Memory_Output_Enable <= '0';
        w_Load_Flags <= '0';
        w_Input_Select <= '0';
        w_Address_Select <= '0';
        w_Operand_Select <= w_Instruction(11);  
        w_Load_IR <= '0';
        
        v_Operation_Type := f_GetOperationType(w_Operation);

        -- Set immediate
        CASE v_Operation_Type IS
            WHEN type_JUMP      => w_Immediate <= t_Reg16(RESIZE(UNSIGNED(w_Instruction(10 DOWNTO 0)), w_Immediate'LENGTH));
            WHEN type_BRANCH    => w_Immediate <= t_Reg16(RESIZE(SIGNED(w_Instruction(10 DOWNTO 2)), w_Immediate'LENGTH));
            WHEN type_LOAD      => w_Immediate <= t_Reg16(RESIZE(SIGNED(w_Instruction(4 DOWNTO 0)), w_Immediate'LENGTH));
            WHEN type_STORE     => w_Immediate <= t_Reg16(RESIZE(SIGNED(w_Instruction(10 DOWNTO 8) & w_Instruction(1 DOWNTO 0)), w_Immediate'LENGTH));
            WHEN type_MOVE      => w_Immediate <= t_Reg16(RESIZE(UNSIGNED(w_Instruction(7 DOWNTO 0)), w_Immediate'LENGTH));
            WHEN type_ALU       => w_Immediate <= t_Reg16(RESIZE(UNSIGNED(w_Instruction(4 DOWNTO 0)), w_Immediate'LENGTH));
            WHEN type_COMPARE   => w_Immediate <= t_Reg16(RESIZE(SIGNED(w_Instruction(10 DOWNTO 8) & w_Instruction(4 DOWNTO 0)), w_Immediate'LENGTH));
            WHEN type_STACK     => w_Immediate <= x"0002";
            WHEN OTHERS         => w_Immediate <= (OTHERS => '0');
        END CASE;

        -- Set state specific signals
        CASE r_Current_State IS
            WHEN s_FETCH_INSTRUCTION =>
                w_Operation <= op_ADD;
                w_Select_Rd <= STD_LOGIC_VECTOR(TO_UNSIGNED(c_REGISTER_PC_INDEX, w_Select_Rd'LENGTH));
                w_Select_Rm <= STD_LOGIC_VECTOR(TO_UNSIGNED(c_REGISTER_PC_INDEX, w_Select_Rm'LENGTH));
                w_Immediate <= x"0002";
                w_Register_Write_Enable <= '1';
                w_Memory_Output_Enable <= '1';
                w_Address_Select <= '1';
                w_Operand_Select <= '1';

            WHEN s_STORE_INSTRUCTION =>
                w_Select_Rm <= STD_LOGIC_VECTOR(TO_UNSIGNED(c_REGISTER_PC_INDEX, w_Select_Rm'LENGTH));
                w_Load_IR <= '1';
                w_Address_Select <= '1';
            
            WHEN s_EXECUTE_INSTRUCTION =>      
                -- Register Write Enable
                IF(v_Operation_Type = type_BRANCH) THEN
                    IF(
                        (w_Operation = op_BEQ AND a_ZERO_FLAG = '1') OR
                        (w_Operation = op_BNE AND a_ZERO_FLAG = '0') OR
                        (w_Operation = op_BLE AND a_CARRY_FLAG = '1' AND a_ZERO_FLAG = '1') OR
                        (w_Operation = op_BGT AND a_CARRY_FLAG = '0' AND a_ZERO_FLAG = '0')
                    ) THEN
                        w_Register_Write_Enable <= '1';
                    END IF;

                ELSIF(v_Operation_Type /= type_STORE AND v_Operation_Type /= type_COMPARE AND v_Operation_Type /= type_HALT) THEN
                    w_Register_Write_Enable <= '1';
                END IF;
                      
                -- Main Memory Write Enable   
                IF(w_Operation = op_STR OR w_Operation = op_PUSH) THEN   
                    w_Memory_Write_Enable <= '1';
                ELSIF(w_Operation = op_LDR OR w_Operation = op_POP) THEN   
                    w_Memory_Output_Enable <= '1';
                END IF;
                
                -- Load Flags
                CASE v_Operation_Type IS
                    WHEN type_MOVE | type_ALU | type_COMPARE => w_Load_Flags <= '1';
                    WHEN OTHERS =>
                END CASE;
                
                -- Source Register Select
                IF(v_Operation_Type = type_BRANCH) THEN
                    w_Select_Rm <= STD_LOGIC_VECTOR(TO_UNSIGNED(c_REGISTER_PC_INDEX, w_Select_Rm'LENGTH));
                END IF;

                -- Destiny Register Select
                IF(v_Operation_Type = type_JUMP OR v_Operation_Type = type_BRANCH) THEN
                    w_Select_Rd <= STD_LOGIC_VECTOR(TO_UNSIGNED(c_REGISTER_PC_INDEX, w_Select_Rd'LENGTH)); 
                ELSIF(v_Operation_Type = type_STACK) THEN
                    w_Select_Rd <= STD_LOGIC_VECTOR(TO_UNSIGNED(c_REGISTER_SP_INDEX, w_Select_Rd'LENGTH)); 
                END IF;
                      
                -- Main Memory Address Select   
                IF(w_Operation = op_PUSH) THEN   
                    w_Address_Select <= '1';
                END IF;

            WHEN s_WRITE_BACK =>
                w_Input_Select <= '1';
                w_Register_Write_Enable <= '1';  
                w_Memory_Output_Enable <= '1';
        END CASE;
    END PROCESS p_INSTRUCTION_CYCLE_GENERATE_SIGNALS;
END ARCHITECTURE;
