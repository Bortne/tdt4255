library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defs.all;

entity Sign_Extender is
    port(
    immediate : in std_logic_vector(15 downto 0);
    immediate_signed : out std_logic_vector(31 downto 0)
    );
    
 end Sign_Extender;
 
 architecture Behavioral of Sign_Extender is
     
begin
    process(immediate)
    begin
        immediate_signed <= std_logic_vector(resize(signed(immediate), 32));
    end process;

end architecture Behavioral;