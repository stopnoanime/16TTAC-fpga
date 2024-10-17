library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.package_16TTAC.all;
use std.textio.all;

entity Memory is
    generic (
        MEM_SIZE  : natural;
        INIT_FILE : string
    );
    port (
        interface_in  : in mem_interface_in;
        interface_out : out mem_interface_out
    );
end entity;

architecture rtl of Memory is

    type mem_type is array (0 to MEM_SIZE - 1) of std_logic_vector(15 downto 0);

    impure function init_ram return mem_type is
        file text_file     : text open read_mode is INIT_FILE;
        variable text_line : line;
        variable temp_ram  : mem_type;
    begin

        for i in 0 to MEM_SIZE - 1 loop
            readline(text_file, text_line);
            hread(text_line, temp_ram(i));
        end loop;

        return temp_ram;

    end function;

    signal block_ram : mem_type := init_ram;

begin

    process (interface_in.clk)
    begin

        if rising_edge(interface_in.clk) then

            if interface_in.write_en = '1' then
                block_ram(to_integer(unsigned(interface_in.adr))) <= interface_in.data;
            end if;

            interface_out.data <= block_ram(to_integer(unsigned(interface_in.adr)));
        end if;

    end process;

end architecture;