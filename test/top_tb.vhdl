library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.package_16TTAC.all;
use std.env.stop;

entity Top_tb is
end entity;

architecture tb of Top_tb is

    signal clk          : std_logic := '0';
    constant clk_period : time      := 42 ns;

begin

    clk <= not clk after clk_period / 2;

    Top_inst : entity work.Top
        port map(
            clk_in    => clk,
            resetn_in => '1',
            uart_tx   => open,
            uart_rx   => '1',
            led_out   => open
        );

    process
    begin
        wait for clk_period * 10000;

        stop;
    end process;

end architecture;