library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defs.all;

entity PC is
    port(
    clk         : in std_logic;
    pro_enable  : in std_logic;
    rst         : in std_logic;
    j           : in std_logic;
    j_target    : in std_logic_vector(25 downto 0);
    jr_target   : in std_logic_vector(31 downto 0);
    jr_enable   : in std_logic; 
    out_to_imem : out std_logic_vector(9 downto 0)
    );
end PC;
 
 architecture Behaviroal of PC is
    
    signal pc : imem_addr_t :=(others => '0');
    signal to_imem : std_logic_vector(9 downto 0);
    
begin
    process(clk) is
      begin
          if rising_edge(clk) then
               if rst ='1' then
                  pc <= (others =>'0');
              elsif pro_enable = '1' then
                  pc <= std_logic_vector(unsigned(to_imem) + 1);
              end if;
          end if;
     end process;
     
     out_to_imem <= j_target(9 downto 0) when j='1'
                    else jr_target(9 downto 0) when jr_enable='1'
                    else pc;
     
 end architecture Behaviroal;