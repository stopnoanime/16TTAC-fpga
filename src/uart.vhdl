library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.package_16TTAC.all;

entity UART is
    generic (
        CLOCKS_PER_BIT : natural
    );
    port (
        interface_in  : in io_interface_in;
        interface_out : out io_interface_out;

        uart_tx       : out std_logic;
        uart_rx       : in std_logic
    );
end entity;

architecture rtl of UART is

    type tx_state_type is (TX_IDLE, TX_START, TX_DATA, TX_STOP);
    signal tx_state         : tx_state_type;
    signal tx_shift_reg     : std_logic_vector(7 downto 0);
    signal tx_bit_counter   : natural range 0 to 7;
    signal tx_clock_counter : natural range 0 to CLOCKS_PER_BIT - 1;

    type rx_state_type is (RX_IDLE, RX_START, RX_DATA, RX_STOP);
    signal rx_state         : rx_state_type;
    signal rx_buf           : std_logic;
    signal rx_signal        : std_logic;
    signal rx_shift_reg     : std_logic_vector(7 downto 0);
    signal rx_bit_counter   : natural range 0 to 7;
    signal rx_clock_counter : natural range 0 to CLOCKS_PER_BIT - 1;

begin

    -- TX
    process (interface_in.clk)
    begin

        if rising_edge(interface_in.clk) then

            if interface_in.reset = '1' then

                tx_state                  <= TX_IDLE;
                uart_tx                   <= '1';
                interface_out.write_avail <= '1';

            else

                case tx_state is
                    when TX_IDLE =>
                        uart_tx                   <= '1';
                        interface_out.write_avail <= '1';
                        tx_bit_counter            <= 0;
                        tx_clock_counter          <= 0;

                        if interface_in.write_en = '1' then
                            tx_state                  <= TX_START;
                            tx_shift_reg              <= interface_in.data;
                            interface_out.write_avail <= '0';
                        end if;

                    when TX_START =>
                        uart_tx <= '0';

                        if tx_clock_counter < CLOCKS_PER_BIT - 1 then
                            tx_clock_counter <= tx_clock_counter + 1;
                        else
                            tx_clock_counter <= 0;
                            tx_state         <= TX_DATA;
                        end if;

                    when TX_DATA =>
                        uart_tx <= tx_shift_reg(0);

                        if tx_clock_counter < CLOCKS_PER_BIT - 1 then
                            tx_clock_counter <= tx_clock_counter + 1;
                        else
                            tx_clock_counter <= 0;
                            tx_shift_reg     <= '0' & tx_shift_reg(7 downto 1);

                            if tx_bit_counter < 7 then
                                tx_bit_counter <= tx_bit_counter + 1;
                            else
                                tx_state <= TX_STOP;
                            end if;

                        end if;

                    when TX_STOP =>
                        uart_tx <= '1';

                        if tx_clock_counter < CLOCKS_PER_BIT - 1 then
                            tx_clock_counter <= tx_clock_counter + 1;
                        else
                            tx_clock_counter <= 0;
                            tx_state         <= TX_IDLE;
                        end if;

                end case;

            end if;

        end if;

    end process;

    -- RX buffering
    process (interface_in.clk)
    begin

        if rising_edge(interface_in.clk) then
            rx_buf    <= uart_rx;
            rx_signal <= rx_buf;
        end if;

    end process;

    -- RX
    process (interface_in.clk)
    begin

        if rising_edge(interface_in.clk) then

            if interface_in.reset = '1' then

                rx_state               <= RX_IDLE;
                interface_out.new_data <= '0';

            else

                case rx_state is
                    when RX_IDLE =>

                        rx_bit_counter         <= 0;
                        rx_clock_counter       <= 0;
                        interface_out.new_data <= '0';

                        if rx_signal = '0' then
                            rx_state <= RX_START;
                        end if;

                    when RX_START =>

                        -- Wait until middle of start bit
                        if rx_clock_counter < (CLOCKS_PER_BIT - 1)/2 then
                            rx_clock_counter <= tx_clock_counter + 1;
                        else
                            rx_clock_counter <= 0;

                            -- Check if start bit still has correct value
                            if rx_signal = '0' then
                                rx_state <= RX_DATA;
                            else
                                rx_state <= RX_IDLE;
                            end if;
                        end if;

                    when RX_DATA =>

                        if rx_clock_counter < CLOCKS_PER_BIT - 1 then
                            rx_clock_counter <= rx_clock_counter + 1;
                        else
                            rx_clock_counter <= 0;
                            rx_shift_reg     <= rx_signal & rx_shift_reg(7 downto 1);

                            if rx_bit_counter < 7 then
                                rx_bit_counter <= rx_bit_counter + 1;
                            else
                                rx_state <= RX_STOP;
                            end if;

                        end if;

                    when RX_STOP =>

                        if rx_clock_counter < CLOCKS_PER_BIT - 1 then
                            rx_clock_counter <= rx_clock_counter + 1;
                        else
                            rx_clock_counter       <= 0;

                            rx_state               <= RX_IDLE;
                            interface_out.new_data <= '1';
                            interface_out.data     <= rx_shift_reg;
                        end if;

                end case;

            end if;

        end if;

    end process;

end architecture;