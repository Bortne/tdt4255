library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defs.all;
use work.alu_ops.all;

entity Decode is
  port (
    instruction     : in  std_logic_vector(31 downto 0);
    reg_read_0      : out std_logic_vector(4 downto 0);
    reg_read_1      : out std_logic_vector(4 downto 0);
    
    register_dst    : out std_logic_vector(4 downto 0);
    register_wen    : out boolean;
    dmem_wen        : out std_logic;
    load_enable     : out std_logic;
    
    alu_operation   : out alu_op_t;
    immediate       : out std_logic;
    shift_amount    : out std_logic_vector(4 downto 0);
    
    j_enable        : out std_logic;
    j_target        : out std_logic_vector(25 downto 0);
    jr_enable       : out std_logic;
    beq_enable      : out std_logic;
    bne_enable      : out std_logic;
    jal_enable      : out std_logic;
    jal_target      : out std_logic_vector(25 downto 0)
   );
   
end Decode;

architecture Behavioral of Decode is
    
begin
    process(instruction)
    begin
    
        --default value
        register_wen <= false;
        immediate <= '0';
        dmem_wen <= '0';
        jr_enable <= '0';
        beq_enable <= '0';
        bne_enable <= '0';
        j_enable    <= '0';
        alu_operation <= ALU_OP_ADD;
        reg_read_0 <= instruction(25 downto 21);
        reg_read_1 <= instruction(20 downto 16);
        register_dst <= instruction(15 downto 11);
        shift_amount <= instruction(10 downto 6);
        j_target <= instruction(25 downto 0);
        jal_enable <= '0';
        load_enable <= '0';
        jal_enable <= '0';
        jal_target <= instruction(25 downto 0);

                 
        case instruction(31 downto 26) is 
            when "000000" =>
            if instruction(15 downto 11) = "00000" then
                           register_wen <= false;
                        else register_wen <=true;
            end if;
                case instruction(5 downto 0) is
                    when "100001" => 
                                                                    --addu   
                    when "101010" =>
                        alu_operation <= ALU_OP_LT;                 --slt
                    when "000000" =>
                        alu_operation <= ALU_OP_SHIFT;              --sll
                        shift_amount <= instruction(10 downto 6);   
                    when "001000" =>                                --jr
                        jr_enable <= '1';
                    when others =>
                        register_wen <= false;
                    end case;
            when "001001" =>                                        --addiu
                register_dst <= instruction(20 downto 16);
                reg_read_1 <= instruction(25 downto 21);
                immediate <= '1';
                alu_operation <= ALU_OP_ADD;
                if instruction(20 downto 16) = "00000" then
                    register_wen <=false;
                else register_wen <= true;
                end if;
                
            when "001111" =>                                        --lui
                register_dst <= instruction(20 downto 16);
                immediate <= '1';
                shift_amount <= "10000";
                alu_operation <= ALU_OP_SHIFT;
                if instruction(20 downto 16) = "00000" then
                    register_wen <=false;
                    else register_wen <= true;
                end if;
                
            when "101011" =>                                        --sw
                dmem_wen <= '1';
                immediate <= '1';
                register_wen <= false;
                
            when "000010" =>                                        --j
                j_enable <= '1';
                j_target <= instruction(25 downto 0);

                
           when "000100" =>                                        --beq
                alu_operation <= ALU_OP_SUB;
                beq_enable <= '1';
                register_wen <= false;
                    
            when "000101" =>                                        --bne
                alu_operation <= ALU_OP_SUB;
                bne_enable <= '1';
                register_wen <= false;
                    
            when "000011" =>                                        --jal
                register_dst <= "11111";
                jal_enable <= '1';
                register_wen <=true;
                jal_target <= instruction(25 downto 0);
                
            when "100011" =>                                        --lw
                alu_operation <= ALU_OP_ADD;
                immediate <= '1';
                load_enable <= '1';
                register_dst <= instruction(20 downto 16);
                if instruction(20 downto 16) = "00000" then
                    register_wen <= false;
                    else register_wen <= true;
                end if;
                           
            when others =>
                register_wen <= false;
                
        end case;
    end process;
    
end architecture Behavioral;