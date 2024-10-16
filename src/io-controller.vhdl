library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.package_16TTAC.all;

entity IOController is
    generic (
        SEL_SRC_IN    : select_type;
        SEL_SRC_IN_AV : select_type;

        SEL_DEST_OUT  : select_type
    );
    port (
        bus_in        : in cpu_bus_in;
        bus_out       : out cpu_bus_out;

        interface_out : out io_interface_in;
        interface_in  : in io_interface_out
    );
end entity;

architecture rtl of IOController is

    signal waiting_for_write : std_logic := '0';
    signal waiting_for_read  : std_logic := '0';
    signal read_available    : std_logic := '0';

begin

    interface_out.clk   <= bus_in.clk;
    interface_out.reset <= bus_in.reset;

    bus_out.halt        <= waiting_for_write or waiting_for_read;

    process (bus_in.clk)
    begin

        if rising_edge(bus_in.clk) then

            interface_out.write_en <= '0';
            bus_out.data           <= (others => '0');

            if bus_in.reset = '1' then

                waiting_for_write <= '0';
                waiting_for_read  <= '0';
                read_available    <= '0';

            else

                -- SOURCE
                if bus_in.src_sel = SEL_SRC_IN_AV then

                    bus_out.data <= x"FFFF" when read_available = '1' else x"0000";

                elsif bus_in.src_sel = SEL_SRC_IN then

                    if read_available = '1' then
                        bus_out.data   <= x"00" & interface_in.data;
                        read_available <= '0';
                    else
                        waiting_for_read <= '1';
                    end if;

                end if;

                -- READ AVAILABLE
                if interface_in.new_data = '1' then
                    read_available <= '1';
                end if;

                -- READ HALT
                if waiting_for_read = '1' and read_available = '1' then
                    bus_out.data     <= x"00" & interface_in.data;
                    read_available   <= '0';
                    waiting_for_read <= '0';
                end if;

                -- DESTINATION
                if bus_in.dest_sel = SEL_DEST_OUT then
                    interface_out.data <= bus_in.data(7 downto 0);

                    if interface_in.write_avail = '1' then
                        interface_out.write_en <= '1';
                    else
                        waiting_for_write <= '1';
                    end if;
                end if;

                -- WRITE HALT
                if waiting_for_write = '1' and interface_in.write_avail = '1' then
                    interface_out.write_en <= '1';
                    waiting_for_write      <= '0';
                end if;

            end if;

        end if;

    end process;

end architecture;