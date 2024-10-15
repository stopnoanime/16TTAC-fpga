library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.package_16TTAC.all;

entity ALU is
  generic (
    SEL_SRC_ACC    : select_type;
    SEL_SRC_TRUE   : select_type;

    SEL_DEST_ACC   : select_type;
    SEL_DEST_ADD   : select_type;
    SEL_DEST_SUB   : select_type;
    SEL_DEST_SHL   : select_type;
    SEL_DEST_SHR   : select_type;
    SEL_DEST_AND   : select_type;
    SEL_DEST_XOR   : select_type;
    SEL_DEST_OR    : select_type;

    SEL_DEST_CARRY : select_type;
    SEL_DEST_ZERO  : select_type
  );
  port (
    bus_in     : in cpu_bus_in;
    bus_out    : out cpu_bus_out;
    carry_flag : out std_logic;
    zero_flag  : out std_logic
  );
end ALU;

architecture rtl of ALU is

  signal acc : std_logic_vector(15 downto 0);

begin

  process (bus_in.clk)

    variable result      : unsigned(16 downto 0);
    variable save_result : boolean;

  begin

    if rising_edge(bus_in.clk) then

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
      case bus_in.dest_sel is
        when SEL_DEST_ACC =>
          result := unsigned(bus_in.data);
        when SEL_DEST_ADD =>
          result := unsigned('0' & bus_in.data) + unsigned(acc) + ("" & carry_flag);
        when SEL_DEST_SUB =>
          result := unsigned(acc) - unsigned('0' & bus_in.data) - ("" & carry_flag);
        when SEL_DEST_SHL =>
          result := shift_left(unsigned(acc), to_integer(unsigned(bus_in.data)));
        when SEL_DEST_SHR =>
          result := shift_right(unsigned(acc), to_integer(unsigned(bus_in.data)));
        when SEL_DEST_AND =>
          result := unsigned(bus_in.data) and unsigned(acc);
        when SEL_DEST_OR =>
          result := unsigned(bus_in.data) or unsigned(acc);
        when SEL_DEST_XOR =>
          result := unsigned(bus_in.data) xor unsigned(acc);

        when SEL_DEST_CARRY =>
          save_result := FALSE;
        when SEL_DEST_ZERO =>
          save_result := FALSE;

        when others =>
          save_result := FALSE;

      end case;

      if save_result = TRUE then
        if result(31 downto 0) = x"0000" then
          zero_flag <= '1';
        else
          zero_flag <= '0';
        end if;

        if result(32) = '1' then
          carry_flag <= '1';
        else
          carry_flag <= '0';
        end if;

        acc <= std_logic_vector(result(31 downto 0));
      end if;

    end if;

  end process;

end architecture;