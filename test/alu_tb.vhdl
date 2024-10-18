library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.package_16TTAC.all;
use std.env.stop;

entity ALU_tb is
end entity;

architecture tb of ALU_tb is

    signal clk          : std_logic := '0';
    signal bus_in       : cpu_bus_in;
    signal bus_out      : cpu_bus_out;
    signal carry_flag   : std_logic;
    signal zero_flag    : std_logic;

    constant clk_period : time := 10 ns;

begin

    ALU : entity work.ALU
        port map(
            bus_in         => bus_in,
            bus_out        => bus_out,
            carry_flag_out => carry_flag,
            zero_flag_out  => zero_flag
        );

    clk        <= not clk after clk_period / 2;
    bus_in.clk <= clk;

    process

        procedure assert_acc (
            val      : std_logic_vector(15 downto 0);
            carry    : std_logic;
            zero     : std_logic;
            fail_msg : string
        ) is
        begin
            bus_in.src_sel  <= SEL_SRC_ACC;
            bus_in.dest_sel <= SEL_DEST_NULL;
            wait for clk_period;

            assert bus_out.data = val report fail_msg severity error;
            assert carry_flag = carry report fail_msg severity error;
            assert zero_flag = zero report fail_msg severity error;
        end procedure;

    begin
        -- Test NOP
        bus_in.src_sel  <= SEL_SRC_NULL;
        bus_in.dest_sel <= SEL_DEST_NULL;
        bus_in.data     <= x"0000";
        wait for clk_period;

        assert bus_out.data = x"0000" report "NOP failed!" severity error;

        -- Test TRUE
        bus_in.src_sel  <= SEL_SRC_TRUE;
        bus_in.dest_sel <= SEL_DEST_NULL;
        bus_in.data     <= x"0000";
        wait for clk_period;

        assert bus_out.data = x"FFFF" report "TRUE failed!" severity error;

        -- Test ACC
        bus_in.src_sel  <= SEL_SRC_NULL;
        bus_in.dest_sel <= SEL_DEST_ACC;
        bus_in.data     <= x"5AA5";
        wait for clk_period;

        assert_acc(x"5AA5", '0', '0', "ACC failed!");

        -- Test ZERO flag
        bus_in.src_sel  <= SEL_SRC_NULL;
        bus_in.dest_sel <= SEL_DEST_ACC;
        bus_in.data     <= x"0000";
        wait for clk_period;

        assert_acc(x"0000", '0', '1', "ZERO failed!");

        -- Test ADD
        bus_in.src_sel  <= SEL_SRC_NULL;
        bus_in.dest_sel <= SEL_DEST_ADD;
        bus_in.data     <= x"0002";
        wait for clk_period;

        assert_ACC(x"0002", '0', '0', "ADD failed!");

        -- Test SUB
        bus_in.src_sel  <= SEL_SRC_NULL;
        bus_in.dest_sel <= SEL_DEST_SUB;
        bus_in.data     <= x"0004";
        wait for clk_period;

        assert_ACC(x"FFFE", '1', '0', "SUB failed!");

        -- Test ADDC
        bus_in.src_sel  <= SEL_SRC_NULL;
        bus_in.dest_sel <= SEL_DEST_ADDC;
        bus_in.data     <= x"0000";
        wait for clk_period;

        assert_ACC(x"FFFF", '0', '0', "ADD CARRY failed!");

        -- Test MUL
        bus_in.src_sel  <= SEL_SRC_NULL;
        bus_in.dest_sel <= SEL_DEST_MUL;
        bus_in.data     <= x"FFFC";

        wait for clk_period;

        assert_ACC(x"0004", '1', '0', "MUL failed!");

        bus_in.src_sel  <= SEL_SRC_NULL;
        bus_in.dest_sel <= SEL_DEST_MUL;
        bus_in.data     <= x"002A";

        wait for clk_period;

        assert_ACC(x"00A8", '0', '0', "MUL failed!");

        -- Test XOR
        bus_in.src_sel  <= SEL_SRC_NULL;
        bus_in.dest_sel <= SEL_DEST_XOR;
        bus_in.data     <= x"5555";
        wait for clk_period;

        assert_ACC(x"55FD", '0', '0', "XOR failed!");

        -- Test SHL
        bus_in.src_sel  <= SEL_SRC_NULL;
        bus_in.dest_sel <= SEL_DEST_SHL;
        bus_in.data     <= x"0002";
        wait for clk_period;

        assert_ACC(x"57F4", '1', '0', "SHL failed!");

        -- Test CARRY SET
        bus_in.src_sel  <= SEL_SRC_NULL;
        bus_in.dest_sel <= SEL_DEST_CARRY;
        bus_in.data     <= x"0000";
        wait for clk_period;

        assert_ACC(x"57F4", '0', '0', "CARRY SET failed!");

        bus_in.src_sel  <= SEL_SRC_NULL;
        bus_in.dest_sel <= SEL_DEST_CARRY;
        bus_in.data     <= x"0001";
        wait for clk_period;

        assert_ACC(x"57F4", '1', '0', "CARRY SET failed!");

        assert false report "Testbench finished" severity note;
        stop;

    end process;

end architecture;