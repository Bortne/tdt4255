library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defs.all;

package custom_defs is

    type EX is record
        ALUSrc          : boolean;
        RegDst          : boolean;
    end record EX;
    
    type MEMORY is record
        MemRead         : boolean;
        MemWrite        : boolean;
        Branch_enable   : boolean;
    end record MEMORY;
    
    type WB  is record
        MEMtoReg        : boolean;
        RegWrite        : boolean;
    end record WB;
    
end package custom_defs;