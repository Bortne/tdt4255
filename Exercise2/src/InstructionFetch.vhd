library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defs.all;
use work.bundles.all;

entity InstructionFetch is

  port (
    input  : in  instruction_fetch_in_t;
    output : out instruction_fetch_out_t);

end entity InstructionFetch;

architecture Behavioural of InstructionFetch is

  signal pc : imem_addr_t;
  signal temp_pc : imem_addr_t;
  signal target: imem_addr_t;

begin  -- architecture Behavioural

  process (input.clk) is --input.alu_zero1, input.alu_zero2, input.bne_enable1, input.bne_enable2, input.beq_enable1, input.beq_enable2
    begin
    if rising_edge(input.clk) then
      if input.rst = '1' then
        pc <= (others => '0');
      else
        if input.processor_enable = '1' then
          pc <= std_logic_vector(unsigned(temp_pc) + 1);
        end if;
      end if;
    end if;
  end process;

  temp_pc <= input.branch_target1(9 downto 1) when (input.beq_enable1='1' and input.alu_zero1 = '1') or (input.bne_enable1='1' and input.alu_zero1 = '0') else
             input.instruction1(8 downto 0) when input.j_enable1='1' or input.jal_enable1='1'else
             target when input.jr_enable1 = '1' else
             
             input.branch_target2(9 downto 1) when (input.beq_enable2='1' and input.alu_zero2 = '1') or (input.bne_enable2='1' and input.alu_zero2 = '0') else
             input.instruction2(8 downto 0) when input.j_enable2='1' or input.jal_enable2='1' else
             input.jr_target2(8 downto 0) when input.jr_enable2 = '1' else             
             pc;
             
  output.address <= temp_pc;
  
  target <= std_logic_vector(unsigned(input.jr_target1(8 downto 0))- 1) when input.misaligned1='1' else input.jr_target1(8 downto 0);
  output.misaligned <= true when (input.branch_target1(0)='1' and (input.beq_enable1='1' and input.alu_zero1 = '1')) or (input.branch_target2(0)='1' and (input.beq_enable2='1' and input.alu_zero2 = '1')) else
                       true when (input.branch_target1(0)='1' and (input.bne_enable1='1' and input.alu_zero1 = '0')) or (input.branch_target2(0)='1' and (input.bne_enable2='1' and input.alu_zero2 = '0')) else
                       false;
end architecture Behavioural;
