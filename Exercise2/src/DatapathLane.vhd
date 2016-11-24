library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defs.all;
use work.alu_ops.all;
use work.bundles.all;

entity DatapathLane is
  port (
    input : in datapath_lane_in_t;
    output : out datapath_lane_out_t
);
end entity DatapathLane;

architecture Behavioural of DatapathLane is
  signal alu_op_a      : datapath_t;
  signal alu_op_b      : datapath_t;
  signal shift_amount  : std_logic_vector(4 downto 0);
  signal alu_operation : alu_op_t;
  signal result        : datapath_t;
  signal is_res_zero   : std_logic;

  signal decoder_in  : decoder_in_t;
  signal decoder_out : decoder_out_t;
  
  signal immediate_value : datapath_t;
  signal misaligned : std_logic;
  
  signal program_counter_IFID : std_logic_vector(9 downto 0);
  signal program_counter_added : std_logic_vector(9 downto 0);
  signal program_counter_with_extend : std_logic_vector(9 downto 0);
  
  signal jr_enable : std_logic;
  signal reg_value : datapath_t;
  signal result_stored : datapath_t;
  signal load_enable : std_logic :='0';
  signal jal_value : std_logic_vector(31 downto 0);
  signal jal_converted : std_logic_vector(11 downto 0);
  
  signal register_wen_IDEX : boolean;
  signal register_dst_IDEX : std_logic_vector(4 downto 0);
  
  signal reg_dst_EX : std_logic_vector(31 downto 0);
  signal reg_value_EX : std_logic_vector(31 downto 0);
  signal load_enable_EX : std_logic;  
  
  signal register_wen_EXMEM       : boolean;
  signal register_dst_EXMEM       : std_logic_vector(4 downto 0);
  signal load_enable_EXMEM        : std_logic;
  signal dmem_wen_EXMEM           : std_logic;
  signal alu_result_EXMEM         : std_logic_vector(31 downto 0);
  signal store_value_EXMEM        : std_logic_vector(31 downto 0);
  signal reg_dmem_value_EXMEM     : std_logic_vector(31 downto 0);
  
begin
--Sends the instruction to decode
  decoder_in.instruction <= input.instruction;
--Signals going to the registerfile
  output.reg1_addr <= decoder_out.reg1_addr;
  output.reg2_addr <= decoder_out.reg2_addr;
  output.dmem_wen <= decoder_out.dmem_wen;--dmem_wen_EXMEM;
  output.j_enable <= decoder_out.j_enable;
  output.instruction <= input.instruction(25 downto 0);
  
IFID: process(input.clk)
  begin
    if rising_edge(input.clk) then
        program_counter_IFID    <= input.program_counter;
    end if;
  end process;

IDEX: process(input.clk)
  begin
    if rising_edge(input.clk) then
    end if;
  end process;

EXMEM: process(input.clk)
    begin 
        if rising_edge(input.clk) then
        --register_wen_EXMEM <= decoder_out.reg_we;
        --register_dst_EXMEM <= decoder_out.reg_dest;
        --load_enable_EXMEM <= decoder_out.load_enable;
        --dmem_wen_EXMEM <= decoder_out.dmem_wen;
        --alu_result_EXMEM <= result;
        --store_value_EXMEM <=
        --reg_dmem_value_EXMEM <= result_stored;
        end if;
    end process;

MEMWB: process(input.clk) --Good, ferdig med steget
    begin 
        if rising_edge(input.clk) then
            output.reg_we <= decoder_out.reg_we;
            output.reg_dst <= decoder_out.reg_dest;
            reg_value <= result_stored;
            load_enable_EX <= decoder_out.load_enable;
        end if;
    end process;
  
  program_counter_added <= std_logic_vector(unsigned(program_counter_IFID) + 1);
  output.branch_target <= std_logic_vector(unsigned(program_counter_added) + unsigned(input.instruction(9 downto 0)));
  --output.branch_target <= std_logic_vector(shift_right(unsigned(program_counter_with_extend), 1));
  
--Gives input to the ALU
  alu_op_a <= input.reg1_value;
  alu_op_b <=  immediate_value when decoder_out.immediate_en = '1' else input.reg2_value;
  alu_operation <= ALU_OP_SHIFT when (input.instruction(5 downto 0) = "000000" and input.instruction(31 downto 26) = "000000") or input.instruction(31 downto 26) = "001111" 
                    else ALU_OP_LT when input.instruction(5 downto 0) = "101010" and input.instruction(31 downto 26) = "000000" 
                    else ALU_OP_SUB when input.instruction(31 downto 26)="000100" or input.instruction(31 downto 26)="000101" --beq and bne
                    else ALU_OP_ADD;
  shift_amount <= "10000" when input.instruction(31 downto 26)="001111" else input.instruction(10 downto 6);
  
--Recieve the result from ALU
  jal_converted <= program_counter_added & "00";
  jal_value <= std_logic_vector(resize(unsigned(jal_converted),32));
  result_stored <= jal_value(31 downto 0) when decoder_out.jal_enable='1' else result;
  --reg_value <= input.data when load_enable_EX='1' else result_stored;
  output.reg_value <= input.data when load_enable_EX='1' else reg_value;
  
  
  output.alu_result <= result;
  output.jr_target <= std_logic_vector(shift_right(unsigned(input.reg1_value), 2));
  jr_enable <= '1' when (input.instruction(5 downto 0) = "001000" and input.instruction(31 downto 26) = "000000") else '0';
  output.jr_enable <= jr_enable;
  
  output.alu_zero <= is_res_zero;
  output.beq_enable <= decoder_out.beq_enable;
  output.bne_enable <= decoder_out.bne_enable;
  output.jal_enable <= decoder_out.jal_enable;

--immediate_value <= x"0000" & input.instruction(15 downto 0);
--Initialize modules
Alu_1: entity work.Alu
    port map (
      alu_op_a      => alu_op_a,
      alu_op_b      => alu_op_b,
      shift_amount  => shift_amount,
      alu_operation => alu_operation,
      result        => result,
      is_res_zero   => is_res_zero);
Decoder_1: entity work.Decoder
    port map (
      input  => decoder_in,
      output => decoder_out);
      
Sign_extend_1: entity work.Sign_Extender
    port map(
    immediate => input.instruction(15 downto 0),
    immediate_signed => immediate_value
    );
    
end architecture Behavioural;





