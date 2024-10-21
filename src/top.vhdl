library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.package_16TTAC.all;

entity Top is
    port (
        -- 24MHz clock
        clk_in    : in std_logic;
        resetn_in : in std_logic;

        -- UART
        uart_tx   : out std_logic;
        uart_rx   : in std_logic;

        -- LED
        led_out   : out std_logic_vector(2 downto 0)
    );
end entity;

architecture rtl of Top is

    signal reset         : std_logic;

    signal cpu_bus       : cpu_bus_in;
    signal alu_bus_out   : cpu_bus_out;
    signal halt_bus_out  : cpu_bus_out;
    signal io_bus_out    : cpu_bus_out;
    signal led_bus_out   : cpu_bus_out;
    signal mem_bus_out   : cpu_bus_out;
    signal pc_bus_out    : cpu_bus_out;
    signal stack_bus_out : cpu_bus_out;

    signal bus_data      : std_logic_vector(15 downto 0);
    signal halt          : std_logic;

    signal carry_flag    : std_logic;
    signal zero_flag     : std_logic;

    signal io_intf_in    : io_interface_in;
    signal io_intf_out   : io_interface_out;

    signal mem_intf_in   : mem_interface_in;
    signal mem_intf_out  : mem_interface_out;

    signal pc_value      : std_logic_vector(15 downto 0);

begin

    ResetController_inst : entity work.ResetController
        generic map(
            DEBOUNCE_FACTOR => 18
        )
        port map(
            clk_in    => clk_in,
            resetn_in => resetn_in,
            reset_out => reset
        );

    -- TO CONTROL UNIT
    bus_data <=
        alu_bus_out.data or
        halt_bus_out.data or
        io_bus_out.data or
        led_bus_out.data or
        mem_bus_out.data or
        pc_bus_out.data or
        stack_bus_out.data;

    halt <=
        alu_bus_out.halt or
        halt_bus_out.halt or
        io_bus_out.halt or
        led_bus_out.halt or
        mem_bus_out.halt or
        pc_bus_out.halt or
        stack_bus_out.halt;

    -- TO OTHER UNITS
    cpu_bus.clk   <= clk_in;
    cpu_bus.reset <= reset;
    cpu_bus.data  <= bus_data;

    ControlUnit_inst : entity work.ControlUnit
        port map(
            clk_in        => clk_in,
            reset_in      => reset,

            src_sel_out   => cpu_bus.src_sel,
            dest_sel_out  => cpu_bus.dest_sel,

            data_in       => bus_data,
            halt_in       => halt,

            carry_flag_in => carry_flag,
            zero_flag_in  => zero_flag
        );

    ALU_inst : entity work.ALU
        port map(
            bus_in         => cpu_bus,
            bus_out        => alu_bus_out,
            carry_flag_out => carry_flag,
            zero_flag_out  => zero_flag
        );

    Halt_inst : entity work.Halt
        port map(
            bus_in  => cpu_bus,
            bus_out => halt_bus_out
        );

    IOController_inst : entity work.IOController
        port map(
            bus_in        => cpu_bus,
            bus_out       => io_bus_out,
            interface_out => io_intf_in,
            interface_in  => io_intf_out
        );

    UART_inst : entity work.UART
        generic map(
            CLOCKS_PER_BIT => 208
        )
        port map(
            interface_in  => io_intf_in,
            interface_out => io_intf_out,
            uart_tx       => uart_tx,
            uart_rx       => uart_rx
        );

    LED_inst : entity work.LED
        port map(
            bus_in  => cpu_bus,
            bus_out => led_bus_out,
            led_out => led_out
        );

    MemoryController_inst : entity work.MemoryController
        port map(
            bus_in        => cpu_bus,
            bus_out       => mem_bus_out,
            pc_in         => pc_value,
            interface_out => mem_intf_in,
            interface_in  => mem_intf_out
        );

    Memory_inst : entity work.Memory
        port map(
            interface_in  => mem_intf_in,
            interface_out => mem_intf_out
        );

    PC_inst : entity work.PC
        port map(
            bus_in  => cpu_bus,
            bus_out => pc_bus_out,
            pc_out  => pc_value
        );

    Stack_inst : entity work.Stack
        generic map(
            STACK_POW2_SIZE => 8
        )
        port map(
            bus_in  => cpu_bus,
            bus_out => stack_bus_out,
            pc_in   => pc_value
        );

end architecture;