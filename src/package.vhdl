library ieee;
use ieee.std_logic_1164.all;

package package_16TTAC is

    subtype select_type is std_logic_vector(6 downto 0);

    type cpu_bus_in is record
        clk      : std_logic;
        src_sel  : select_type;
        dest_sel : select_type;
        data     : std_logic_vector(15 downto 0);
    end record;

    type cpu_bus_out is record
        data : std_logic_vector(15 downto 0);
        halt : std_logic;
    end record;

end package;