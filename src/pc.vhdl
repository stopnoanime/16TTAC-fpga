library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.package_16TTAC.all;

entity PC is
    generic (
        SEL_SRC_PC    : select_type;
        SEL_SRC_OP    : select_type;

        SEL_DEST_PC   : select_type;
        SEL_DEST_CALL : select_type
    );
    port (
        bus_in  : in cpu_bus_in;
        bus_out : out cpu_bus_out;

        pc_out  : out std_logic_vector(15 downto 0)
    );
end entity;

architecture rtl of PC is

    signal pc_reg : std_logic_vector(15 downto 0) := (others => '0');

begin

    pc_out <= pc_reg;

    process (bus_in.clk)
    begin

        if rising_edge(bus_in.clk) then

            if bus_in.reset = '1' then

                pc_reg       <= (others => '0');
                bus_out.data <= (others => '0');

            else

                -- SOURCE
                if bus_in.src_sel = SEL_SRC_PC then
                    bus_out.data <= pc_reg;
                elsif bus_in.src_sel = SEL_SRC_OP then
                    pc_reg       <= std_logic_vector(unsigned(pc_reg) + 1);
                    bus_out.data <= (others => '0');
                else
                    bus_out.data <= (others => '0');
                end if;

                -- DESTINATION
                if bus_in.dest_sel = SEL_DEST_PC or bus_in.dest_sel = SEL_DEST_CALL then
                    pc_reg <= bus_in.data;
                end if;

            end if;

        end if;

    end process;

end architecture;