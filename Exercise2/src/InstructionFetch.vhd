library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defs.all;
use work.bundles.all;

entity InstructionFetch is

  port (
    input  : in  instruction_fetch_in_t;
    output : out instruction_fetch_out_t);

end entity InstructionFetch;

architecture Behavioural of InstructionFetch is

  signal pc : imem_addr_t;

begin  -- architecture Behavioural

  process (input.clk) is
  begin
    if rising_edge(input.clk) then
      if input.rst = '1' then
        pc <= (others => '0');
      else
        if input.processor_enable = '1' then
          pc <= imem_addr_t(unsigned(pc) + 1);
        end if;
      end if;
    end if;
  end process;

  output.address <= pc;

end architecture Behavioural;
