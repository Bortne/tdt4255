library ieee;
use ieee.std_logic_1164.all;

use work.defs.all;
use work.bundles.all;

entity Decoder is
  port (
    input : in decoder_in_t;
    output : out decoder_out_t);
end entity Decoder;

architecture Behavioural of Decoder is

  signal reg_dst : reg_addr_t;

begin

  output.reg1_addr <= input.instruction(25 downto 21);
  output.reg2_addr <= input.instruction(20 downto 16);
  reg_dst <= input.instruction(15 downto 11);
  output.reg_dest <= reg_dst;
  output.reg_we <= reg_dst /= "00000";


end architecture Behavioural;
