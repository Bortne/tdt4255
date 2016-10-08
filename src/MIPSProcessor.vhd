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
begin

  regfile_inst : RegisterFile
    port map (
      input => rf_in,
      output => rf_out,
      debug_input  => rf_debug_in,
      debug_output => rf_debug_out);
  rf_in.clk <= input.clk;
  rf_in.rst <= input.rst;

end Pipelined;
