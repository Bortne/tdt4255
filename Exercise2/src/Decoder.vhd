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
  reg_dst <= input.instruction(20 downto 16) when input.instruction(31 downto 26) = "001001" or input.instruction(31 downto 26) = "001111" or input.instruction(31 downto 26)="100011" else
             "11111" when input.instruction(31 downto 26)="000011"
             else input.instruction(15 downto 11);
  output.reg_dest <= reg_dst;
  output.reg_we <= false when input.instruction(31 downto 26) = "101011" else
                   false when input.instruction(31 downto 26) = "000010" else
                   false when input.instruction(31 downto 26) = "000100" else --beq
                   false when input.instruction(31 downto 26) = "000101" else --bne
                   reg_dst /= "00000";

  output.immediate_en <= '1' when input.instruction(31 downto 26) = "001001" or input.instruction(31 downto 26) = "001111" or input.instruction(31 downto 26) = "101011" or input.instruction(31 downto 26) ="100011" else '0';
  output.dmem_wen <= '1' when input.instruction(31 downto 26) = "101011" else '0';
  
  output.j_enable <= '1' when input.instruction(31 downto 26)="000010" else '0';
  output.beq_enable <= '1' when input.instruction(31 downto 26)="000100" else '0';
  output.bne_enable <= '1' when input.instruction(31 downto 26)="000101" else '0';
  output.jal_enable <= '1' when input.instruction(31 downto 26)="000011" else '0';
  output.load_enable <= '1' when input.instruction(31 downto 26)="100011" else '0';

end architecture Behavioural;
