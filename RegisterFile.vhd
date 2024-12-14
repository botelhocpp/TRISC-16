LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY RegisterFile IS
PORT ( 
    i_Data_Rd       : IN t_Reg16;
    i_Select_Rm     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    i_Select_Rn     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    i_Select_Rd     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    i_Write_Enable  : IN STD_LOGIC;
    i_Clk           : IN STD_LOGIC;
    i_Rst           : IN STD_LOGIC;
    o_Data_Rm       : OUT t_Reg16;
    o_Data_Rn       : OUT t_Reg16 
);
END ENTITY;

ARCHITECTURE RTL OF RegisterFile IS
    CONSTANT c_REGISTERS_NUMBER : INTEGER := 8;

    TYPE t_RegisterArray IS ARRAY (0 TO c_REGISTERS_NUMBER - 1) OF t_Reg16;
    
    SIGNAL r_Registers : t_RegisterArray  := (OTHERS => (OTHERS => '0'));
    SIGNAL w_Load_Registers : STD_LOGIC_VECTOR(c_REGISTERS_NUMBER - 1 DOWNTO 0) := (OTHERS => '0');
BEGIN
    gen_GENERATE_REGISTERS:
    FOR i IN w_Load_Registers'RANGE GENERATE
        w_Load_Registers(i) <= '1' WHEN (TO_INTEGER(UNSIGNED(i_Select_Rd)) = i AND i_Write_Enable = '1') ELSE '0';
        
        gen_GENERATE_SP_REGISTER:
        IF (i = c_REGISTER_SP_INDEX) GENERATE
            e_SP_REGISTER: ENTITY WORK.GenericRegister
            GENERIC MAP ( g_INIT_VALUE => c_REGISTER_SP_INIT_VALUE )
            PORT MAP (
                i_D     => i_Data_Rd,
                i_Load  => w_Load_Registers(i),
                i_Clk   => i_Clk,
                i_Rst   => i_Rst,
                o_Q     => r_Registers(i)
            );
        END GENERATE gen_GENERATE_SP_REGISTER;
        
        gen_GENERATE_PC_REGISTER:
        IF (i = c_REGISTER_PC_INDEX) GENERATE
            e_PC_REGISTER: ENTITY WORK.GenericRegister
            GENERIC MAP ( g_INIT_VALUE => c_REGISTER_PC_INIT_VALUE )
            PORT MAP (
                i_D     => i_Data_Rd,
                i_Load  => w_Load_Registers(i),
                i_Clk   => i_Clk,
                i_Rst   => i_Rst,
                o_Q     => r_Registers(i)
            );
        END GENERATE gen_GENERATE_PC_REGISTER;
        
        gen_GENERATE_GP_REGISTERS:
        IF (i /= c_REGISTER_PC_INDEX AND i /= c_REGISTER_SP_INDEX) GENERATE
            e_GP_REGISTER: ENTITY WORK.GenericRegister
            PORT MAP (
                i_D     => i_Data_Rd,
                i_Load  => w_Load_Registers(i),
                i_Clk   => i_Clk,
                i_Rst   => i_Rst,
                o_Q     => r_Registers(i)
            );
        END GENERATE gen_GENERATE_GP_REGISTERS;

    END GENERATE gen_GENERATE_REGISTERS;

    o_Data_Rm <= r_Registers(TO_INTEGER(UNSIGNED(i_Select_Rm)));  
    o_Data_Rn <= r_Registers(TO_INTEGER(UNSIGNED(i_Select_Rn)));    
END ARCHITECTURE;
