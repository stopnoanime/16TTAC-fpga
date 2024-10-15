library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.package_16TTAC.all;

entity ALU_tb is
end entity;

architecture tb of ALU_tb is

  signal bus_in       : cpu_bus_in;
  signal bus_out      : cpu_bus_out;
  signal carry_flag   : std_logic;
  signal zero_flag    : std_logic;

  constant clk_period : time := 10 ns;

  -- Calculate the number of clock cycles in minutes/seconds
  procedure assert_acc (val : std_logic_vector(15 downto 0); carry : std_logic; zero : std_logic; fail_msg : string)is
  begin
    bus_in.src_sel  <= "01";
    bus_in.dest_sel <= "0";
    wait for clk_period;

    assert bus_out.data = val report fail_msg severity error;
    assert carry_flag = carry report fail_msg severity error;
    assert zero_flag = zero report fail_msg severity error;
  end procedure;

begin

  ALU : entity work.ALU
    generic map(
      SEL_SRC_ACC    => "01",
      SEL_SRC_TRUE   => "10",

      SEL_DEST_ACC   => "0001",
      SEL_DEST_ADD   => "0010",
      SEL_DEST_SUB   => "0011",
      SEL_DEST_SHL   => "0100",
      SEL_DEST_SHR   => "0101",
      SEL_DEST_AND   => "0110",
      SEL_DEST_XOR   => "0111",
      SEL_DEST_OR    => "1000",
      SEL_DEST_CARRY => "1001",
      SEL_DEST_ZERO  => "1010"
    )
    port map(
      bus_in     => bus_in,
      bus_out    => bus_out,
      carry_flag => carry_flag,
      zero_flag  => zero_flag
    );

  bus_in.clk <= not bus_in.clk after clk_period / 2;

  process

  begin
    -- Test NOP
    bus_in.data     <= (others => '0');
    bus_in.src_sel  <= (others => '0');
    bus_in.dest_sel <= (others => '0');
    wait for clk_period;

    assert bus_out.data = x"0001" report "NOP failed!" severity error;

    -- Test ACC
    bus_in.src_sel  <= "0";
    bus_in.dest_sel <= "0001";
    bus_in.data     <= x"5AA5";
    wait for clk_period;

    assert_acc(x"5AA5", '0', '0', "ACC failed!");

    -- Test ZERO flag
    bus_in.src_sel  <= "0";
    bus_in.dest_sel <= "0001";
    bus_in.data     <= x"0";
    wait for clk_period;

    assert_acc(x"0000", '0', '1', "ZERO failed!");

    -- Test ADD
    bus_in.src_sel  <= "0";
    bus_in.dest_sel <= "0010";
    bus_in.data     <= x"2";
    wait for clk_period;

    assert_ACC(x"2", '0', '0', "ADD failed!");

    -- Test SUB
    bus_in.src_sel  <= "0";
    bus_in.dest_sel <= "0011";
    bus_in.data     <= x"4";
    wait for clk_period;

    assert_ACC(x"FFFE", '1', '0', "SUB failed!");

    -- Test ADD CARRY
    bus_in.src_sel  <= "0";
    bus_in.dest_sel <= "0010";
    bus_in.data     <= x"0";
    wait for clk_period;

    assert_ACC(x"FFFF", '0', '0', "ADD CARRY failed!");

    -- Test XOR
    bus_in.src_sel  <= "0";
    bus_in.dest_sel <= "0111";
    bus_in.data     <= x"5555";
    wait for clk_period;

    assert_ACC(x"AAAA", '0', '0', "XOR failed!");

    -- Test SHL
    bus_in.src_sel  <= "0";
    bus_in.dest_sel <= "0100";
    bus_in.data     <= x"0003";
    wait for clk_period;

    assert_ACC(x"5550", '0', '0', "SHL failed!");

    -- Test CARRY SET
    bus_in.src_sel  <= "0";
    bus_in.dest_sel <= "1001";
    bus_in.data     <= x"0000";
    wait for clk_period;

    assert_ACC(x"5550", '0', '0', "CARRY SET failed!");

    bus_in.src_sel  <= "0";
    bus_in.dest_sel <= "1001";
    bus_in.data     <= x"0001";
    wait for clk_period;

    assert_ACC(x"5550", '1', '0', "CARRY SET failed!");

    -- END
    assert false report "Testbench finished" severity note;

  end process;

end architecture;