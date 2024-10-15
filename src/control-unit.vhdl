library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.package_16TTAC.all;

entity ControlUnit is
    generic (
        SEL_SRC_OP : select_type
    );
    port (
        clk_in   : in std_logic;
        reset_in : in std_logic;

        halt_in       : in std_logic;
        carry_flag_in : in std_logic;
        zero_flag_in  : in std_logic;
        data_in       : in std_logic_vector(15 downto 0);

        src_sel_out  : out select_type;
        dest_sel_out : out select_type
    );
end ControlUnit;

architecture rtl of ControlUnit is

    signal src_sel : select_type;
    signal dest_sel : select_type;
    signal should_execute : boolean;

    type state_type is (FETCH, SRC, DEST);
    signal state : state_type := FETCH;
    signal delayed_dest_sel : select_type;

begin

    should_execute <=
        state = SRC and
        ((not data_in(1)) or carry_flag_in) = '1' and
        ((not data_in(0)) or zero_flag_in) = '1';

    src_sel <=
        SEL_SRC_OP when state = FETCH else
        data_in(15 downto 9) when should_execute else
        (others => '0');

    dest_sel <=
        data_in(8 downto 2) when should_execute else
        (others => '0');

    src_sel_out <= (others => '0') when halt_in else
        src_sel;
    dest_sel_out <= (others => '0') when halt_in else
        delayed_dest_sel;

    process (clk_in)
    begin
        if rising_edge(clk_in) then
            if reset_in = '1' then

                delayed_dest_sel <= (others => '0');
                state <= FETCH;

            elsif halt_in = '0' then

                delayed_dest_sel <= dest_sel;

                case state is
                    when FETCH =>
                        state <= SRC;
                    when SRC =>
                        state <= DEST;
                    when DEST =>
                        state <= FETCH;
                end case;

            end if;
        end if;
    end process;
end architecture;