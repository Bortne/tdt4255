library ieee;
use ieee.std_logic_1164.all;

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
begin
--Sends the instruction to decode
  decoder_in.instruction <= input.instruction;
--Signals going to the registerfile
  output.reg1_addr <= decoder_out.reg1_addr;
  output.reg2_addr <= decoder_out.reg2_addr;
  output.reg_dst <= decoder_out.reg_dest;
  output.reg_we <= decoder_out.reg_we;
--Gives input to the ALU
  alu_op_a <= input.reg1_value;
  alu_op_b <= input.reg2_value;
  alu_operation <= ALU_OP_ADD;
  shift_amount <= (others => '0');
--Recieve the result from ALU
  output.reg_value <= result;

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
end architecture Behavioural;
