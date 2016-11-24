library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


use work.defs.all;
use work.alu_ops.all;
use work.bundles.all;

entity MIPSProcessor is
  port (
    input  : in  mips_processor_in_t;
    output : out mips_processor_out_t;

    rf_debug_in  : in  regfile_debug_in_t;
    rf_debug_out : out regfile_debug_out_t);
end MIPSProcessor;

architecture DualIssue of MIPSProcessor is
--Signals for fetch unit
  signal if_in  : instruction_fetch_in_t;
  signal if_out : instruction_fetch_out_t;

-- Register file signals
  signal rf_in  : regfile_in_t;
  signal rf_out : regfile_out_t;
-- Datapath signal for path1 and path2
  signal dpath1_in, dpath2_in  : datapath_lane_in_t;
  signal dpath1_out, dpath2_out : datapath_lane_out_t;
--Activation signal for activation of the two lanes
  signal lane1_active, lane2_active : boolean;
  signal instruction_fetch1, instruction_fetch2 : std_logic_vector(25 downto 0);
  --signal active_lane : std_logic_vector;
  signal misaligned : boolean;

begin
--A check to start the processor
  process (input.clk) is
  begin
    if rising_edge(input.clk) then
      lane1_active <= input.processor_enable = '1';
      lane2_active <= input.processor_enable = '1';
      misaligned <= if_out.misaligned;
    end if;
  end process;
--Turn on fetch unit when processor is on
  if_in.processor_enable <= input.processor_enable;
  dpath1_in.clk <= input.clk;
  dpath2_in.clk <= input.clk;
--Program counter address goes to IMEM
  output.imem_address <= if_out.address;

--Giving ds and dt to registerfile
  rf_in.read_ports(0)       <= dpath1_out.reg1_addr;
  rf_in.read_ports(1)       <= dpath1_out.reg2_addr;
  rf_in.read_ports(2)       <= dpath2_out.reg1_addr;
  rf_in.read_ports(3)       <= dpath2_out.reg2_addr;
  
--Signals for input to datalanes
  dpath1_in.instruction     <= (others => '0') when misaligned else input.imem_data(63 downto 32); -- 
  dpath2_in.instruction     <= input.imem_data(31 downto 0);
  dpath1_in.reg1_value      <= rf_out.read_ports(0);
  dpath1_in.reg2_value      <= rf_out.read_ports(1);
  dpath2_in.reg1_value      <= rf_out.read_ports(2);
  dpath2_in.reg2_value      <= rf_out.read_ports(3);
  
--Write signal to registerfile that comes from two different datalanes
  rf_in.write_ports(0).dst      <= dpath1_out.reg_dst;
  rf_in.write_ports(0).value    <= dpath1_out.reg_value;
  rf_in.write_ports(0).we       <= dpath1_out.reg_we and lane1_active;
  rf_in.write_ports(1).dst      <= dpath2_out.reg_dst;
  rf_in.write_ports(1).value    <= dpath2_out.reg_value;
  rf_in.write_ports(1).we       <= dpath2_out.reg_we and lane2_active;

-- Feed clock, reset and processor_enable to all components which need it.
  rf_in.clk <= input.clk;
  rf_in.rst <= input.rst;

  if_in.clk <= input.clk;
  if_in.rst <= input.rst;
  
--Input to data memory
    output.dmem_write_enable <= dpath1_out.dmem_wen when input.imem_data(63 downto 58)="101011" else
                                dpath2_out.dmem_wen when input.imem_data(31 downto 26)="101011" else
                                '0';
    output.dmem_data <= rf_out.read_ports(1) when input.imem_data(63 downto 58)="100011" else--dpath1_out.dmem_wen='1' else--OR input.imem_data(63 downto 58)="100011" else
                        rf_out.read_ports(3) when input.imem_data(31 downto 26)="100011" else--dpath2_out.dmem_wen='1'  else --OR input.imem_data(31 downto 26)="100011" else
                        (others =>'0');
    output.dmem_address <= dpath1_out.alu_result(9 downto 0) when input.imem_data(63 downto 58)="101011" OR input.imem_data(63 downto 58)="100011" else
                           dpath2_out.alu_result(9 downto 0) when input.imem_data(31 downto 26)="101011"  OR input.imem_data(31 downto 26)="100011" else
                           (others => '0');
                           
   --Used for jump instructions
   if_in.instruction1 <= std_logic_vector(shift_right(unsigned(dpath1_out.instruction), 1));
   if_in.instruction2 <= std_logic_vector(shift_right(unsigned(dpath2_out.instruction), 1));
   if_in.j_enable1 <= dpath1_out.j_enable;
   if_in.j_enable2 <= dpath2_out.j_enable;
   --if_in.instruction1 <= instruction_fetch1;--std_logic_vector(unsigned(instruction_fetch1) -1) when instruction_fetch1(0) = '1' else instruction_fetch1;
   --if_in.instruction2 <= instruction_fetch2; --std_logic_vector(unsigned(instruction_fetch2) +1) when instruction_fetch2(0) = '0' else instruction_fetch2;
    
   --Used for jump_register instruction
   if_in.jr_target1 <= std_logic_vector(shift_right(unsigned(dpath1_out.jr_target), 1));
   if_in.jr_target2 <= std_logic_vector(shift_right(unsigned(dpath2_out.jr_target), 1));
   if_in.jr_enable1 <= dpath1_out.jr_enable;
   if_in.jr_enable2 <= dpath2_out.jr_enable;
   
   if_in.misaligned1 <= dpath1_out.misaligned;
   if_in.misaligned2 <= dpath2_out.misaligned;
   
   --Branching
   if_in.branch_target1 <= dpath1_out.branch_target;
   if_in.branch_target2 <= dpath2_out.branch_target;
   
   dpath1_in.program_counter <= if_out.address & "0";--std_logic_vector(shift_left(unsigned(if_out.address), 1));
   dpath2_in.program_counter <= std_logic_vector(unsigned(dpath1_in.program_counter) +1);
   
   --Branch signals
   if_in.beq_enable1 <= dpath1_out.beq_enable;
   if_in.bne_enable1 <= dpath1_out.bne_enable;
   if_in.beq_enable2 <= dpath2_out.beq_enable;
   if_in.bne_enable2 <= dpath2_out.bne_enable;
   if_in.alu_zero1   <= dpath1_out.alu_zero;
   if_in.alu_zero2   <= dpath2_out.alu_zero;
   
   if_in.jal_enable1 <= dpath1_out.jal_enable;
   if_in.jal_enable2 <= dpath2_out.jal_enable;
   
   dpath1_in.data <= input.dmem_data;
   dpath2_in.data <= input.dmem_data;
--Initialize the different modules
--First datapath lane
DatapathLane_1: entity work.DatapathLane
    port map (
      input  => dpath1_in,
      output => dpath1_out);
      
--Second datapath lane
  DatapathLane_2: entity work.DatapathLane
    port map (
      input  => dpath2_in,
      output => dpath2_out);
      
--Program counter or fetch unit
InstructionFetch_1: entity work.InstructionFetch
    port map (
      input  => if_in,
      output => if_out);
      
--Register file
RegisterFile_1 : RegisterFile
    port map (
      input  => rf_in,
      output => rf_out,
      debug_input => rf_debug_in,
      debug_output => rf_debug_out);

end DualIssue;
