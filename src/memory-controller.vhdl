library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.package_16TTAC.all;

entity MemoryController is
    generic (
        SEL_SRC_ADR  : select_type;
        SEL_SRC_MEM  : select_type;
        SEL_SRC_OP   : select_type;

        SEL_DEST_ADR : select_type;
        SEL_DEST_MEM : select_type
    );
    port (
        bus_in            : in cpu_bus_in;
        bus_out           : out cpu_bus_out;

        pc_in             : in std_logic_vector(15 downto 0);

        interface_out : out mem_interface_in;
        interface_in  : in mem_interface_out
    );
end entity;

architecture rtl of MemoryController is

    signal adr             : std_logic_vector(15 downto 0);
    signal data_out        : std_logic_vector(15 downto 0);
    signal pass_mem_output : boolean;

begin

    interface_out.clk      <= bus_in.clk;
    interface_out.data     <= bus_in.data;
    interface_out.write_en <= '1' when bus_in.dest_sel = SEL_DEST_MEM else '0';
    interface_out.adr <= pc_in when bus_in.src_sel = SEL_SRC_OP else adr;

    bus_out.data <= interface_in.data when pass_mem_output else data_out;

    process (bus_in.clk)
    begin

        if rising_edge(bus_in.clk) then

            -- SOURCE
            if bus_in.src_sel = SEL_SRC_MEM or bus_in.src_sel = SEL_SRC_OP then
                pass_mem_output <= TRUE;
            elsif bus_in.src_sel = SEL_SRC_ADR then
                data_out        <= adr;
                pass_mem_output <= FALSE;
            else
                data_out        <= (others => '0');
                pass_mem_output <= FALSE;
            end if;

            -- DESTINATION
            if bus_in.dest_sel = SEL_DEST_ADR then
                adr <= bus_in.data;
            end if;

        end if;

    end process;

end architecture;