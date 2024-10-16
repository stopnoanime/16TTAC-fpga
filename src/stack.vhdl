library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.package_16TTAC.all;

entity Stack is
    generic (
        STACK_POW2_SIZE : natural;

        SEL_SRC_POP     : select_type;

        SEL_DEST_PUSH   : select_type;
        SEL_DEST_CALL   : select_type
    );
    port (
        bus_in  : in cpu_bus_in;
        bus_out : out cpu_bus_out;

        pc_in   : in std_logic_vector(15 downto 0)
    );
end entity;

architecture rtl of Stack is

    type stack_type is array (0 to 2 ** STACK_POW2_SIZE - 1) of std_logic_vector(15 downto 0);
    signal stack_mem : stack_type;

    signal stack_ptr : unsigned(STACK_POW2_SIZE downto 0) := (others => '0');

begin

    process (bus_in.clk)
    begin

        if rising_edge(bus_in.clk) then

            if bus_in.reset = '1' then
                stack_ptr <= (others => '0');
            else

                -- SOURCE
                if bus_in.src_sel = SEL_SRC_POP then
                    bus_out.data <= stack_mem(to_integer(stack_ptr - 1));
                    stack_ptr    <= stack_ptr - 1;
                else
                    bus_out.data <= (others => '0');
                end if;

                -- DESTINATION
                if bus_in.dest_sel = SEL_DEST_PUSH then
                    stack_mem(to_integer(stack_ptr)) <= bus_in.data;
                    stack_ptr                        <= stack_ptr + 1;
                elsif bus_in.dest_sel = SEL_DEST_CALL then
                    stack_mem(to_integer(stack_ptr)) <= pc_in;
                    stack_ptr                        <= stack_ptr + 1;
                end if;

            end if;

        end if;

    end process;

end architecture;