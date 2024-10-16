library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.package_16TTAC.all;

entity UART is
    port (
        interface_in  : in io_interface_in;
        interface_out : out io_interface_out
    );
end entity;

architecture rtl of UART is

begin

    process (interface_in.clk)
    begin

        if rising_edge(interface_in.clk) then

        end if;

    end process;

end architecture;