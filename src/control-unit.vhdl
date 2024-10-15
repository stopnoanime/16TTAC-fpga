library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.package_16TTAC.all;

entity ControlUnit is
    port (
        bus_in        : out cpu_bus_in;
        bus_out       : in cpu_bus_out;
        carry_flag_in : in std_logic;
        zero_flag_in  : in std_logic
    );
end ControlUnit;

architecture rtl of ControlUnit is

begin

end architecture;