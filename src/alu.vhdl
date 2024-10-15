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
    bus_in         : in cpu_bus_in;
    bus_out        : out cpu_bus_out;
    carry_flag_out : out std_logic;
    zero_flag_out  : out std_logic
  );
end ALU;

architecture rtl of ALU is

  signal acc        : std_logic_vector(15 downto 0);
  signal carry_flag : std_logic;
  signal zero_flag  : std_logic;

begin

  carry_flag_out <= carry_flag;
  zero_flag_out  <= zero_flag;

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

      if bus_in.dest_sel = SEL_DEST_ACC then
        result := unsigned('0' & bus_in.data);
      elsif bus_in.dest_sel = SEL_DEST_ADD then
        result := unsigned('0' & acc) + unsigned('0' & bus_in.data) + ("" & carry_flag);
      elsif bus_in.dest_sel = SEL_DEST_SUB then
        result := unsigned('0' & acc) - unsigned('0' & bus_in.data) - ("" & carry_flag);

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
        carry_flag <= or bus_in.data;

      elsif bus_in.dest_sel = SEL_DEST_ZERO then
        save_result := FALSE;
        zero_flag <= or bus_in.data;

      else
        save_result := FALSE;

      end if;

      if save_result = TRUE then
        carry_flag <= result(16);
        zero_flag  <= nor result(15 downto 0);
        acc        <= std_logic_vector(result(15 downto 0));
      end if;

    end if;

  end process;

end architecture;