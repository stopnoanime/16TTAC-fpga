library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.package_16TTAC.all;

entity ResetController is
    generic (
        DEBOUNCE_FACTOR : natural
    );
    port (
        clk_in    : in std_logic;
        resetn_in : in std_logic;

        reset_out : out std_logic
    );
end entity;

architecture rtl of ResetController is
    signal reset_shift      : std_logic_vector(3 downto 0)       := "0000";

    signal debounce_counter : unsigned(DEBOUNCE_FACTOR downto 0) := (others => '0');
    signal debounce_df1     : std_logic                          := '0';
    signal debounce_df2     : std_logic                          := '0';
begin

    reset_out <= (not reset_shift(3)) or debounce_df2;

    process (clk_in)
    begin

        if rising_edge(clk_in) then

            reset_shift      <= reset_shift(2 downto 0) & '1';
            debounce_counter <= debounce_counter + 1;

            if debounce_counter = 0 then
                debounce_df2 <= debounce_df1;
                debounce_df1 <= not resetn_in;
            end if;

        end if;

    end process;

end architecture;