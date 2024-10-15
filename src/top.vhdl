library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.package_16TTAC.all;

entity Top is
    port (
        -- 24MHz clock
        clk_in   : in std_logic;
        reset_in : in std_logic;

        -- UART
        uart_tx  : out std_logic;
        uart_rx  : inout std_logic
    );
end Top;

architecture rtl of Top is

begin

    -- ALU : entity work.ALU
    --     generic map(
    --         SEL_SRC_ACC    => "0000000",
    --         SEL_SRC_TRUE   => "0000000",

    --         SEL_DEST_ACC   => "0000000",
    --         SEL_DEST_ADD   => "0000000",
    --         SEL_DEST_SUB   => "0000000",
    --         SEL_DEST_SHL   => "0000000",
    --         SEL_DEST_SHR   => "0000000",
    --         SEL_DEST_AND   => "0000000",
    --         SEL_DEST_XOR   => "0000000",
    --         SEL_DEST_OR    => "0000000",

    --         SEL_DEST_CARRY => "0000000",
    --         SEL_DEST_ZERO  => "0000000"
    --     )
    --     port map(
    --         bus_in         => open,
    --         bus_out        => open,
    --         carry_flag_out => open,
    --         zero_flag_out  => open
    --     );

end architecture;