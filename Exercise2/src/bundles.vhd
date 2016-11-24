library ieee;
use ieee.std_logic_1164.all;

use work.defs.all;

package bundles is

  type instruction_fetch_in_t is record
    clk              : std_logic;
    rst              : std_logic;
    processor_enable : std_logic;
    j_enable1 : std_logic;
    j_enable2 : std_logic;
    instruction1 : std_logic_vector(25 downto 0);
    instruction2 : std_logic_vector(25 downto 0);
    jr_target1  :datapath_t;
    jr_target2  :datapath_t;
    jr_enable1 : std_logic;
    jr_enable2 : std_logic;
    branch_target1 : std_logic_vector(9 downto 0);
    branch_target2 : std_logic_vector(9 downto 0); 
    beq_enable1 : std_logic;
    bne_enable1 : std_logic;
    beq_enable2 : std_logic;
    bne_enable2 : std_logic;
    alu_zero1 : std_logic;
    alu_zero2 : std_logic;
    misaligned1 : std_logic;
    misaligned2 : std_logic;
    jal_enable1 : std_logic;
    jal_enable2 : std_logic;
  end record instruction_fetch_in_t;

  type instruction_fetch_out_t is record
    address : imem_addr_t;
    misaligned : boolean;
  end record instruction_fetch_out_t;

  type datapath_lane_in_t is record
    instruction : instruction_data_t;
    reg1_value : datapath_t;
    reg2_value : datapath_t;
    program_counter : std_logic_vector(9 downto 0);
    clk : std_logic;
    data : datapath_t;
  end record datapath_lane_in_t;

  type datapath_lane_out_t is record
    reg1_addr : reg_addr_t;
    reg2_addr : reg_addr_t;
    reg_dst : reg_addr_t;
    reg_we : boolean;
    reg_value : datapath_t;
    dmem_wen    : std_logic;
    alu_result  : datapath_t;
    j_enable : std_logic;
    instruction : std_logic_vector(25 downto 0);
    jr_target : datapath_t;
    jr_enable : std_logic;
    branch_target : std_logic_vector(9 downto 0); 
    beq_enable : std_logic;
    bne_enable : std_logic; 
    alu_zero : std_logic;
    misaligned : std_logic;
    jal_enable : std_logic;
  end record datapath_lane_out_t;

  type decoder_in_t is record
    instruction : instruction_data_t;
  end record decoder_in_t;

  type decoder_out_t is record
    reg1_addr : reg_addr_t;
    reg2_addr : reg_addr_t;
    reg_dest : reg_addr_t;
    reg_we : boolean;
    immediate_en : std_logic;
    dmem_wen    : std_logic;
    j_enable : std_logic;
    beq_enable : std_logic;
    bne_enable : std_logic;
    jal_enable : std_logic;
    load_enable : std_logic;
  end record decoder_out_t;

--const R-types : std_logic_vector(5 downto 0) :="000000";

--const ADDU 	: std_logic_vector(5 downto 0) :="100001";
--const ShiftLL   : std_logic_vector(5 downto 0) :="000000";
--const SLT	: std_logic_vector(5 downto 0) :="101010";

 end package bundles;
