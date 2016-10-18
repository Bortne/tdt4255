library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defs.all;
use work.alu_ops.all;

entity MIPSProcessor is
  port (
    input  : in  mips_processor_in_t;
    output : out mips_processor_out_t;
    
    rf_debug_in  : in  regfile_debug_in_t;
    rf_debug_out : out regfile_debug_out_t);
    
end MIPSProcessor;

architecture Pipelined of MIPSProcessor is
  signal rf_in         : regfile_in_t;
  signal rf_out        : regfile_out_t;
  
  --signal pc : imem_addr_t :=(others => '0');
  signal alu_operation : alu_op_t;
  signal shift_amount : std_logic_vector(4 downto 0);
  signal zero : std_logic :='0';
  signal rg_input : write_ports_in_t;
  signal immediate : std_logic;
  
  --Signals for sign extender
  signal to_alu_op_b : std_logic_vector(31 downto 0);
  signal choose_immediate : std_logic_vector(31 downto 0);
  
  -- Jump-signals
  signal j_enable   : std_logic;
  signal j_target   : std_logic_vector(25 downto 0);
  signal jr_enable  : std_logic;
  signal jr_target_shift : std_logic_vector(31 downto 0);
  
  signal imem_addr: std_logic_vector(9 downto 0);
  --signal reg_under_imem : std_logic_vector(31 downto 0);
  --signal add_sei_imem : std_logic_vector(31 downto 0);
  --signal should_branch : std_logic;
  --signal reg_under_imem_add_one : std_logic_vector(31 downto 0);
  --signal alu_result : std_logic_vector(31 downto 0);
  --signal jal_enable : std_logic;


begin
  regfile_inst : RegisterFile
    port map (
      input => rf_in,
      output => rf_out,
      debug_input  => rf_debug_in,
      debug_output => rf_debug_out);
  rf_in.clk <= input.clk;
  rf_in.rst <= input.rst;
  rf_in.write_ports <= rg_input;
  
      
    to_alu_op_b <= choose_immediate when immediate ='1' else rf_out.read_ports(1);
    
    --Data memory outputs
    output.dmem_address <= rg_input(0).value(9 downto 0);
    output.dmem_data <= rf_out.read_ports(1);
  
    jr_target_shift <= std_logic_vector(shift_right(unsigned(rf_out.read_ports(0)), 2));
    
    output.imem_address <= imem_addr;   
 
 


--reg_under_imem_add_one <= std_logic_vector((signed(reg_under_imem) + 1));
--add_sei_imem <= std_logic_vector(signed(reg_under_imem_add_one) + signed(choose_immediate));

--rg_input(0).value <= std_logic_vector(shift_left(signed(reg_under_imem_add_one), 2)) when jal_enable = '1' else alu_result;

    
    
decode: entity work.decode
    port map( 
        instruction        => input.imem_data,
        processor_en       => input.processor_enable,
        alu_operation      => alu_operation,
        register_wen       => rg_input(0).we,
        register_dst        => rg_input(0).dst,
        reg_read_0          => rf_in.read_ports(0),
        reg_read_1          => rf_in.read_ports(1),
        immediate           => immediate,
        dmem_wen            => output.dmem_write_enable,
        shift_amount        => shift_amount,
        j_enable            => j_enable,
        j_target            => j_target,
        jr_enable           => jr_enable
        --alu_is_zero         => zero,
       -- branch              => should_branch,
       -- jal_enable          => jal_enable
    );
    
alu: entity work.alu
   port map(
       alu_operation    => alu_operation,
       alu_op_a         => rf_out.read_ports(0),
       alu_op_b         => to_alu_op_b,
       shift_amount     => shift_amount,
       is_res_zero      => zero,
       result           => rg_input(0).value
       ); 
      
extend: entity work.sign_extender
port map(
    immediate => input.imem_data(15 downto 0),
    immediate_signed => choose_immediate
);      

program_counter : entity work.PC
    port map(
        clk             => input.clk,
        pro_enable      => input.processor_enable,
        rst             => input.rst,
        j               => j_enable,
        j_target        => j_target,
        out_to_imem     => imem_addr,
        jr_enable       => jr_enable,
        jr_target       => jr_target_shift
        
    );
      
end architecture Pipelined;
