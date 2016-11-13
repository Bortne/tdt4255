library ieee;
use ieee.std_logic_1164.all;

use work.defs.all;

package bundles is

  type instruction_fetch_in_t is record
    clk              : std_logic;
    rst              : std_logic;
    processor_enable : std_logic;
  end record instruction_fetch_in_t;

  type instruction_fetch_out_t is record
    address : imem_addr_t;
  end record instruction_fetch_out_t;

  type datapath_lane_in_t is record
    instruction : instruction_data_t;
    reg1_value : datapath_t;
    reg2_value : datapath_t;
  end record datapath_lane_in_t;

  type datapath_lane_out_t is record
    reg1_addr : reg_addr_t;
    reg2_addr : reg_addr_t;
    reg_dst : reg_addr_t;
    reg_we : boolean;
    reg_value : datapath_t;
  end record datapath_lane_out_t;

  type decoder_in_t is record
    instruction : instruction_data_t;
  end record decoder_in_t;

  type decoder_out_t is record
    reg1_addr : reg_addr_t;
    reg2_addr : reg_addr_t;
    reg_dest : reg_addr_t;
    reg_we : boolean;
  end record decoder_out_t;

 end package bundles;
