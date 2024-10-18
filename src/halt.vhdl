library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.package_16TTAC.all;

entity Halt is
    port (
        bus_in  : in cpu_bus_in;
        bus_out : out cpu_bus_out
    );
end entity;

architecture rtl of Halt is
begin

    process (bus_in.clk)
    begin

        if rising_edge(bus_in.clk) then

            if bus_in.reset = '1' then

                bus_out.halt <= '0';

            else

                -- DESTINATION
                if bus_in.dest_sel = SEL_DEST_HALT then
                    bus_out.halt <= '1';
                end if;

            end if;

        end if;

    end process;

end architecture;