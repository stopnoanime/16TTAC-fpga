library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.package_16TTAC.all;

entity Memory is
    generic (
        MEM_SIZE : natural
    );
    port (
        interface_in : in mem_interface;
        data_out     : out std_logic_vector(15 downto 0)
    );
end entity;

architecture rtl of Memory is

    type mem_type is array (0 to MEM_SIZE - 1) of std_logic_vector(15 downto 0);
    signal block_ram : mem_type;

begin

    process (interface_in.clk)
    begin

        if rising_edge(interface_in.clk) then

            if interface_in.write_en = '1' then
                block_ram(to_integer(unsigned(interface_in.adr))) <= interface_in.data;
            end if;

            data_out <= block_ram(to_integer(unsigned(interface_in.adr)));
        end if;

    end process;

end architecture;