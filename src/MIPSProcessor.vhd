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
  signal shift_amount : std_logic_vector(4 downto 0);
  signal zero : std_logic :='0';
  signal register_input : write_ports_in_t;
  
  --Signals for sign extender
  signal to_alu_op_b : std_logic_vector(31 downto 0);
  signal choose_immediate : std_logic_vector(31 downto 0);
  
  -- Jump-signals
  signal j_enable   : std_logic;
  signal j_target   : std_logic_vector(25 downto 0);
  signal jr_enable  : std_logic;
  signal jr_target_shift : std_logic_vector(31 downto 0);
  signal jal_target : std_logic_vector(25 downto 0);
  
  signal imem_addr: std_logic_vector(9 downto 0);
  signal reg_under_imem : std_logic_vector(31 downto 0);
  signal add_sei_imem : std_logic_vector(31 downto 0);
  signal reg_under_imem_add_one : std_logic_vector(31 downto 0);
  signal alu_result : std_logic_vector(9 downto 0);
  signal jal_enable : std_logic;
  
  signal temp_result : std_logic_vector(31 downto 0);
  
  signal load_enable : std_logic;
  signal register_wen    : boolean;
  
  
  signal value_reg_dmem :std_logic_vector(31 downto 0);
  
  signal resize_imem_addr  : std_logic_vector(31 downto 0);
  
  signal alu_operation : alu_op_t;
      signal register_dst   : std_logic_vector(4 downto 0);
      signal immediate : std_logic;
      signal reg_dmem_value   : std_logic_vector(31 downto 0);
      signal load_enable_wait_one : std_logic;
  signal store_enable : std_logic;
  signal beqORbne : boolean;
  signal beq_enable : std_logic;
  signal bne_enable : std_logic;    
      
  --Signals for IDEX    
    signal alu_operation_IDEX       : alu_op_t;
    signal register_wen_IDEX        : boolean;
    signal register_dst_IDEX        : std_logic_vector(4 downto 0);
    signal load_enable_IDEX         : std_logic;
    signal immediate_IDEX           : std_logic;
    signal jal_enable_IDEX          : std_logic;
    signal reg_read_0_IDEX          : std_logic_vector(31 downto 0);
    signal reg_read_1_IDEX          : std_logic_vector(31 downto 0);
    signal sign_immediate_IDEX      : std_logic_vector(31 downto 0);                     
    signal shift_amount_IDEX        : std_logic_vector(4 downto 0);
    signal branch_target_IDEX       : std_logic_vector(31 downto 0);
    signal store_enable_IDEX        : std_logic;  
    signal store_value_IDEX         : std_logic_vector(31 downto 0); 
    signal branch_enable_IDEX       : std_logic; 
    signal jal_target_IDEX          : std_logic_vector(25 downto 0);
    signal reg_imem_IDEX            : std_logic_vector(31 downto 0);
    signal beq_enable_IDEX          : std_logic;
    signal bne_enable_IDEX          : std_logic;
    
    --Signals EXMEM
    signal register_wen_EXMEM       : boolean;
    signal register_dst_EXMEM       : std_logic_vector(4 downto 0);
    signal load_enable_EXMEM        : std_logic;
    signal store_enable_EXMEM       : std_logic;
    signal alu_result_EXMEM         : std_logic_vector(31 downto 0);
    signal store_value_EXMEM        : std_logic_vector(31 downto 0);
    signal reg_dmem_value_EXMEM     : std_logic_vector(31 downto 0);
    
    --Signals for MEMWB
    signal load_enable_MEMWB        : std_logic;
    signal register_wen_MEMWB       : boolean;
    signal register_dst_MEMWB       : std_logic_vector(4 downto 0);
    signal reg_dmem_value_MEMWB     : std_logic_vector(31 downto 0);
--Done with pipelining
    signal processor_enable_wait    : std_logic;
    signal processor_enable_waited  : std_logic;
    

    
begin
  regfile_inst : RegisterFile
    port map (
      input => rf_in,
      output => rf_out,
      debug_input  => rf_debug_in,
      debug_output => rf_debug_out);
  rf_in.clk <= input.clk;
  rf_in.rst <= input.rst;
  rf_in.write_ports <= register_input;
  
   
waitFORprocessor : process(input.clk)
      begin
          if rising_edge(input.clk) then
            processor_enable_wait <= input.processor_enable;
          end if;
      end process;
      
      processor_enable_waited <= processor_enable_wait and input.processor_enable;
        
  
IFID : process(input.clk)
      begin
      if rising_edge(input.clk) and processor_enable_waited ='1' then
           reg_under_imem <= resize_imem_addr;
      end if;
      end process;  
      
  IDEX : process(input.clk)
      begin
       if input.rst='1' then
           alu_operation_IDEX <= ALU_OP_ADD;
           register_wen_IDEX <= false;
           register_dst_IDEX <= (others => '0');
           load_enable_IDEX <= '0';
           immediate_IDEX <= '0';
           jal_enable_IDEX <= '0';
           reg_read_0_IDEX <= (others => '0');
           reg_read_1_IDEX <= (others => '0');
           sign_immediate_IDEX <= (others => '0');
           shift_amount_IDEX <= (others => '0');
           branch_target_IDEX <= (others => '0');
           register_wen_IDEX  <= false;
           load_enable_IDEX   <= '0';
           store_enable_IDEX <= '0'; 
           store_value_IDEX  <= (others => '0'); 
           beq_enable_IDEX <= '0';
           bne_enable_IDEX <= '0';
           jal_target_IDEX     <= (others => '0');
           reg_imem_IDEX       <= (others => '0'); 
      
          elsif rising_edge(input.clk) and processor_enable_waited ='1'then
             alu_operation_IDEX <= alu_operation;
             register_wen_IDEX <= register_input(0).we;
             register_dst_IDEX <= register_dst;
             load_enable_IDEX <= load_enable;
             immediate_IDEX <= immediate;
             jal_enable_IDEX <= jal_enable;
             reg_read_0_IDEX <= rf_out.read_ports(0);
             reg_read_1_IDEX <= rf_out.read_ports(1);
             sign_immediate_IDEX <= choose_immediate;
             shift_amount_IDEX <= shift_amount;
             branch_target_IDEX <= add_sei_imem;
             register_wen_IDEX  <= register_wen;
             load_enable_IDEX   <= load_enable;
             store_enable_IDEX <= store_enable; 
             store_value_IDEX  <= rf_out.read_ports(1); 
             beq_enable_IDEX <= beq_enable;
             bne_enable_IDEX <= bne_enable;
             jal_target_IDEX     <= jal_target;
             reg_imem_IDEX       <= reg_under_imem_add_one;
                    
          end if;
      end process;
      
 EXMEM : process(input.clk)
      begin
      if input.rst='1' then
          register_dst_EXMEM <= (others => '0');
          register_wen_EXMEM <= false;
          load_enable_EXMEM  <= '0';
          store_enable_EXMEM <= '0';
          store_value_EXMEM <= (others => '0');
          alu_result_EXMEM <= (others => '0');
          reg_dmem_value_EXMEM <= (others => '0');
          
      elsif rising_edge(input.clk) and processor_enable_waited ='1' then
        register_dst_EXMEM <= register_dst_IDEX;
        register_wen_EXMEM <= register_wen_IDEX;
        load_enable_EXMEM  <= load_enable_IDEX;
        store_enable_EXMEM <= store_enable_IDEX;
        store_value_EXMEM <= store_value_IDEX;
        alu_result_EXMEM <= temp_result;
        reg_dmem_value_EXMEM <= value_reg_dmem;
      end if;
      end process;
      
  MEMWB : process(input.clk)
      begin
      if input.rst='1' then
        register_wen_MEMWB <= false;
        reg_dmem_value_MEMWB <= (others => '0');
        register_dst_MEMWB <= (others => '0');
        load_enable_MEMWB <= '0';
    
      
      elsif rising_edge(input.clk) and processor_enable_waited ='1' then
          register_wen_MEMWB <= register_wen_EXMEM;
          reg_dmem_value_MEMWB <= reg_dmem_value_EXMEM;
          register_dst_MEMWB <= register_dst_EXMEM;
          load_enable_MEMWB <= load_enable_EXMEM;
      end if;
  end process;     
    
    --Register input
    register_input(0).we <= register_wen_MEMWB;
    register_input(0).dst <= register_dst_MEMWB;
    register_input(0).value <= input.dmem_data when load_enable_MEMWB='1' else reg_dmem_value_MEMWB;
    
    --Data memory outputs
    output.dmem_address <= alu_result_EXMEM(9 downto 0);
    output.dmem_data <= store_value_EXMEM;
    output.dmem_write_enable <= store_enable_EXMEM;
      
    to_alu_op_b <= sign_immediate_IDEX when immediate_IDEX ='1' else reg_read_1_IDEX;
    
    --Check if the outputs are equal to each other or not
    --beqORbne <= rf_out.read_ports(0) = rf_out.read_ports(1);
      
    jr_target_shift <= std_logic_vector(shift_right(unsigned(rf_out.read_ports(0)), 2));
    
    output.imem_address <= imem_addr;   
    value_reg_dmem <= std_logic_vector(shift_left(unsigned(reg_imem_IDEX), 2)) when jal_enable_IDEX = '1' else temp_result;
 

    resize_imem_addr <= std_logic_vector(resize(unsigned(imem_addr),32));
    
    reg_under_imem_add_one <= std_logic_vector((unsigned(reg_under_imem) + 1));
    add_sei_imem <= std_logic_vector(unsigned(reg_under_imem_add_one) + unsigned(choose_immediate));
    
    
    
decode: entity work.decode
    port map( 
        instruction         => input.imem_data,
        alu_operation       => alu_operation,
        register_wen        => register_wen,
        register_dst        => register_dst,
        reg_read_0          => rf_in.read_ports(0),
        reg_read_1          => rf_in.read_ports(1),
        immediate           => immediate,
        dmem_wen            => store_enable,
        shift_amount        => shift_amount,
        j_enable            => j_enable,
        j_target            => j_target,
        jr_enable           => jr_enable,
        beq_enable          => beq_enable,
        bne_enable          => bne_enable,
        jal_enable          => jal_enable,
        load_enable         => load_enable,
        jal_target          => jal_target
    );
    
alu: entity work.alu
   port map(
       alu_operation    => alu_operation_IDEX,
       alu_op_a         => reg_read_0_IDEX,
       alu_op_b         => to_alu_op_b,
       shift_amount     => shift_amount_IDEX,
       is_res_zero      => zero,
       result           => temp_result
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
        jr_target       => jr_target_shift,
        branch_target   => branch_target_IDEX,
        beq_enable      => beq_enable_IDEX,
        bne_enable      => bne_enable_IDEX,
        jal_target      => jal_target_IDEX,
        jal_enable      => jal_enable_IDEX,
        alu_is_zero        => zero
    );
      
end architecture Pipelined;
