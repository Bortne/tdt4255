library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defs.all;
use work.alu_ops.all;

entity Alu is
  port (
    alu_op_a      : in  datapath_t;
    alu_op_b      : in  datapath_t;
    shift_amount  : in  std_logic_vector(4 downto 0);
    alu_operation : in  alu_op_t;
    result        : out datapath_t;
    is_res_zero   : out std_logic);

end entity Alu;

architecture Behavioural of Alu is
  signal tmp_res      : signed(datapath_t'range);
  signal is_a_lt_b : std_logic;
begin  -- architecture Behavioural

  result      <= datapath_t(tmp_res);
  is_res_zero <= '1' when tmp_res = (tmp_res'range => '0') else
                 '0';
  is_a_lt_b <= '1' when signed(alu_op_a) < signed(alu_op_b) else
               '0';

  with alu_operation select
    tmp_res <=
    signed(alu_op_a) + signed(alu_op_b) when ALU_OP_ADD,
    signed(alu_op_a) - signed(alu_op_b) when ALU_OP_SUB,
    (0 => is_a_lt_b, others => '0') when ALU_OP_LT,
    shift_left(signed(alu_op_b), to_integer(unsigned(shift_amount))) when ALU_OP_SHIFT;


end architecture Behavioural;
