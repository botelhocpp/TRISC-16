LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Processor IS
PORT ( 
    i_Irq           : IN STD_LOGIC;
    i_Soft_Rst          : IN STD_LOGIC;
    i_Clk           : IN STD_LOGIC;
    i_Rst           : IN STD_LOGIC;
    o_Write_Enable  : OUT STD_LOGIC;
    o_Output_Enable : OUT STD_LOGIC;
    o_Address       : OUT t_Reg16;
    io_Data         : INOUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF Processor IS
    SIGNAL w_Operation              : t_Operation := op_INVALID;

    SIGNAL w_Flag_Zero              : STD_LOGIC := '0';
    SIGNAL w_Flag_Carry             : STD_LOGIC := '0';
    SIGNAL w_Register_Write_Enable  : STD_LOGIC := '0';
    SIGNAL w_Memory_Write_Enable    : STD_LOGIC := '0';
    SIGNAL w_Memory_Output_Enable   : STD_LOGIC := '0';
    SIGNAL w_Load_Flags             : STD_LOGIC := '0';
    SIGNAL w_Save_Flags             : STD_LOGIC := '0';
    SIGNAL w_Retrieve_Flags         : STD_LOGIC := '0';
    SIGNAL w_Input_Select           : STD_LOGIC := '0';
    SIGNAL w_Address_Select         : STD_LOGIC := '0';
    SIGNAL w_Operand_Select         : STD_LOGIC := '0';

    SIGNAL w_Flags_Output           : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Saved_Flags_Output     : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Immediate              : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Flags_Input              : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Internal_Bus           : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Data_Rm                : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Data_Rn                : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Alu_B                  : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Alu_Result             : t_Reg16 := (OTHERS => '0');
    
    SIGNAL w_Select_Rm              : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL w_Select_Rn              : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL w_Select_Rd              : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
BEGIN
    e_REGISTER_FILE: ENTITY WORK.RegisterFile
    PORT MAP(
        i_Data_Rd       => w_Internal_Bus,
        i_Select_Rm     => w_Select_Rm,
        i_Select_Rn     => w_Select_Rn,
        i_Select_Rd     => w_Select_Rd,
        i_Write_Enable  => w_Register_Write_Enable,
        i_Clk           => i_Clk,
        i_Rst           => i_Rst,
        o_Data_Rm       => w_Data_Rm,
        o_Data_Rn       => w_Data_Rn
    );
    e_CONTROL_UNIT: ENTITY WORK.ControlUnit
    PORT MAP(
        i_Instruction           => w_Internal_Bus,
        i_Flags                 => w_Flags_Output,
        i_Soft_Rst                => i_Soft_Rst,
        i_Irq                   => i_Irq,
        i_Clk                   => i_Clk,
        i_Rst                   => i_Rst,
        o_Select_Rm             => w_Select_Rm,
        o_Select_Rn             => w_Select_Rn,
        o_Select_Rd             => w_Select_Rd,
        o_Register_Write_Enable => w_Register_Write_Enable,
        o_Memory_Write_Enable   => w_Memory_Write_Enable,
        o_Memory_Output_Enable  => w_Memory_Output_Enable,
        o_Load_Flags            => w_Load_Flags,
        o_Save_Flags            => w_Save_Flags,
        o_Retrieve_Flags        => w_Retrieve_Flags,
        o_Input_Select          => w_Input_Select,
        o_Address_Select        => w_Address_Select,
        o_Operand_Select        => w_Operand_Select,
        o_Operation             => w_Operation,
        o_Immediate             => w_Immediate
    );
    e_ALU: ENTITY WORK.ArithmeticLogicUnit
    PORT MAP(
        i_Op_A          => w_Data_Rm,
        i_Op_B          => w_Alu_B,
        i_Sel           => w_Operation,
        o_Flag_Zero     => w_Flag_Zero,
        o_Flag_Carry    => w_Flag_Carry,
        o_Result        => w_Alu_Result
    );
    e_FLAGS_REGISTER: ENTITY WORK.GenericRegister
    PORT MAP (
        i_D     => w_Flags_Input,
        i_Load  => w_Load_Flags,
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        o_Q     => w_Flags_Output
    );
    e_SAVED_FLAGS_REGISTER: ENTITY WORK.GenericRegister
    PORT MAP (
        i_D     => w_Flags_Output,
        i_Load  => w_Save_Flags,
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        o_Q     => w_Saved_Flags_Output
    );

    -- Build Flags Input
    w_Flags_Input <= (
        c_ZERO_FLAG_INDEX   => w_Flag_Zero, 
        c_CARRY_FLAG_INDEX  => w_Flag_Carry,
        OTHERS              => '0'
    ) WHEN (w_Retrieve_Flags = '0') ELSE w_Saved_Flags_Output;

    -- Redirect to Output
    o_Write_Enable <= w_Memory_Write_Enable;
    o_Output_Enable <= w_Memory_Output_Enable; 

    -- Multiplexers
    w_Alu_B <= w_Immediate WHEN (w_Operand_Select = '1') ELSE w_Data_Rn;
    o_Address <= w_Data_Rm WHEN (w_Address_Select = '1') ELSE w_Alu_Result;
    w_Internal_Bus <= io_Data WHEN (w_Input_Select = '1') ELSE w_Alu_Result;
    
    -- Write to Memory Tristate Buffer
    io_Data <= w_Data_Rn WHEN (w_Memory_Write_Enable = '1') ELSE (OTHERS => 'Z');
END ARCHITECTURE;
