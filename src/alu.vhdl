library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.package_16TTAC.all;

entity ALU is
    port (
        bus_in         : in cpu_bus_in;
        bus_out        : out cpu_bus_out;
        carry_flag_out : out std_logic;
        zero_flag_out  : out std_logic
    );
end entity;

architecture rtl of ALU is

    signal acc        : std_logic_vector(15 downto 0);
    signal carry_flag : std_logic;
    signal zero_flag  : std_logic;

begin

    bus_out.halt   <= '0';
    carry_flag_out <= carry_flag;
    zero_flag_out  <= zero_flag;

    process (bus_in.clk)

        variable result      : unsigned(16 downto 0);
        variable mul_result  : unsigned(31 downto 0);
        variable save_result : boolean;

    begin

        if rising_edge(bus_in.clk) then

            if bus_in.reset = '1' then

                acc        <= (others => '0');
                carry_flag <= '0';
                zero_flag  <= '1';

            else

                -- SOURCE
                if bus_in.src_sel = SEL_SRC_ACC then
                    bus_out.data <= acc;
                elsif bus_in.src_sel = SEL_SRC_TRUE then
                    bus_out.data <= (others => '1');
                else
                    bus_out.data <= (others => '0');
                end if;

                -- DESTINATION
                save_result := TRUE;

                if bus_in.dest_sel = SEL_DEST_ACC then
                    result := unsigned('0' & bus_in.data);

                elsif bus_in.dest_sel = SEL_DEST_ADD then
                    result := unsigned('0' & acc) + unsigned('0' & bus_in.data);
                elsif bus_in.dest_sel = SEL_DEST_ADDC then
                    result := unsigned('0' & acc) + unsigned('0' & bus_in.data) + ("" & carry_flag);
                elsif bus_in.dest_sel = SEL_DEST_SUB then
                    result := unsigned('0' & acc) - unsigned('0' & bus_in.data);
                elsif bus_in.dest_sel = SEL_DEST_SUBC then
                    result := unsigned('0' & acc) - unsigned('0' & bus_in.data) - ("" & carry_flag);

                elsif bus_in.dest_sel = SEL_DEST_CMP then
                    save_result := FALSE;
                    result      := unsigned('0' & acc) - unsigned('0' & bus_in.data);
                    carry_flag <= result(16);
                    zero_flag  <= '1' when result(15 downto 0) = x"0000" else '0';

                elsif bus_in.dest_sel = SEL_DEST_MUL then
                    mul_result          := unsigned(acc) * unsigned(bus_in.data);
                    result(16)          := '0' when mul_result(31 downto 16) = x"0000" else '1';
                    result(15 downto 0) := mul_result(15 downto 0);

                elsif bus_in.dest_sel = SEL_DEST_SHL then
                    result := shift_left(unsigned('0' & acc), to_integer(unsigned(bus_in.data)));
                elsif bus_in.dest_sel = SEL_DEST_SHR then
                    result := shift_right(unsigned('0' & acc), to_integer(unsigned(bus_in.data)));

                elsif bus_in.dest_sel = SEL_DEST_AND then
                    result := unsigned('0' & bus_in.data) and unsigned('0' & acc);
                elsif bus_in.dest_sel = SEL_DEST_OR then
                    result := unsigned('0' & bus_in.data) or unsigned('0' & acc);
                elsif bus_in.dest_sel = SEL_DEST_XOR then
                    result := unsigned('0' & bus_in.data) xor unsigned('0' & acc);

                elsif bus_in.dest_sel = SEL_DEST_CARRY then
                    save_result := FALSE;
                    carry_flag <= '0' when bus_in.data = x"0000" else '1';

                elsif bus_in.dest_sel = SEL_DEST_ZERO then
                    save_result := FALSE;
                    zero_flag <= '0' when bus_in.data = x"0000" else '1';

                else
                    save_result := FALSE;

                end if;

                if save_result then
                    carry_flag <= result(16);
                    zero_flag  <= '1' when result(15 downto 0) = x"0000" else '0';
                    acc        <= std_logic_vector(result(15 downto 0));
                end if;

            end if;

        end if;

    end process;

end architecture;