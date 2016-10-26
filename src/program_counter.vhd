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
    jal_enable  : in std_logic;
    jal_target  : in std_logic_vector(25 downto 0);
    out_to_imem : out std_logic_vector(9 downto 0);
    beq_enable  : in std_logic;
    bne_enable  : in std_logic;
    branch_target :in std_logic_vector(31 downto 0);
    alu_is_zero : in std_logic
    
    );
end PC;
 
 architecture Behaviroal of PC is
    
    signal pc : imem_addr_t :=(others => '0');
    signal to_imem : std_logic_vector(9 downto 0);
    
begin
    process(clk, j, jal_enable, beq_enable, bne_enable) is
      begin
          if rising_edge(clk) then
               if rst ='1' then
                  pc <= (others =>'0');
              elsif pro_enable = '1' then
                  pc <= std_logic_vector(unsigned(to_imem) + 1);
              end if;
          end if;
     end process;
     
     to_imem <= j_target(9 downto 0) when j='1'
                    else jr_target(9 downto 0) when jr_enable='1'
                    else jal_target(9 downto 0) when jal_enable='1'
                    else branch_target(9 downto 0) when beq_enable ='1' and alu_is_zero='1'
                    else branch_target(9 downto 0) when bne_enable ='1' and alu_is_zero='0'
                    else pc;
                    
    out_to_imem <= to_imem;
     
 end architecture Behaviroal;