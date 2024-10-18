library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.package_16TTAC.all;

entity LED is
    port (
        bus_in  : in cpu_bus_in;
        bus_out : out cpu_bus_out;

        led_out : out std_logic_vector(2 downto 0)
    );
end entity;

architecture rtl of LED is

    signal led_reg : std_logic_vector(15 downto 0);

begin

    bus_out.halt <= '0';
    led_out      <= not led_reg(2 downto 0);

    process (bus_in.clk)
    begin

        if rising_edge(bus_in.clk) then

            if bus_in.reset = '1' then

                led_reg <= (others => '0');

            else

                -- SOURCE
                if bus_in.src_sel = SEL_SRC_LED then
                    bus_out.data <= led_reg;
                else
                    bus_out.data <= (others => '0');
                end if;

                -- DESTINATION
                if bus_in.dest_sel = SEL_DEST_LED then
                    led_reg <= bus_in.data;
                end if;

            end if;

        end if;

    end process;

end architecture;