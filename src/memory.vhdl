library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.package_16TTAC.all;
--use std.textio.all;
library eagle_macro;
use eagle_macro.EAGLE_COMPONENTS.all;

entity Memory is
	port (
		interface_in  : in mem_interface_in;
		interface_out : out mem_interface_out
	);
end entity;

-- architecture rtl of Memory is

--     type mem_type is array (0 to (2 ** 16) - 1) of std_logic_vector(15 downto 0);

--     impure function init_ram return mem_type is
--         file text_file     : text open read_mode is INIT_FILE;
--         variable text_line : line;
--         variable temp_ram  : mem_type := (others => (others => '0'));
--     begin

--         for i in 0 to (2 ** MEM_POW2_SIZE) - 1 loop
--             exit when endfile(text_file);
--             readline(text_file, text_line);
--             hread(text_line, temp_ram(i));
--         end loop;

--         return temp_ram;

--     end function;

--     signal block_ram : mem_type := init_ram;

-- begin

--     process (interface_in.clk)
--     begin

--         if rising_edge(interface_in.clk) then

--             if interface_in.write_en = '1' then
--                 block_ram(to_integer(unsigned(interface_in.adr))) <= interface_in.data;
--             end if;

--             interface_out.data <= block_ram(to_integer(unsigned(interface_in.adr)));
--         end if;

--     end process;

-- end architecture;

architecture rtl of Memory is
	signal write_en_low  : std_logic;
	signal write_en_high : std_logic;

	signal data_out_low  : std_logic_vector(15 downto 0);
	signal data_out_high : std_logic_vector(15 downto 0);
	signal last_adr_high : std_logic;
begin

	write_en_low       <= interface_in.write_en and (not interface_in.adr(15));
	write_en_high      <= interface_in.write_en and (interface_in.adr(15));

	interface_out.data <= data_out_high when last_adr_high = '1' else data_out_low;

	process (interface_in.clk)
	begin

		if rising_edge(interface_in.clk) then
			last_adr_high <= interface_in.adr(15);
		end if;

	end process;

	inst_32k : EG_LOGIC_BRAM
	generic map(
		DATA_WIDTH_A => 16,
		ADDR_WIDTH_A => 15,
		DATA_DEPTH_A => 32768,
		DATA_WIDTH_B => 16,
		ADDR_WIDTH_B => 15,
		DATA_DEPTH_B => 32768,
		MODE         => "SP",
		REGMODE_A    => "NOREG",
		WRITEMODE_A  => "NORMAL",
		RESETMODE    => "SYNC",
		IMPLEMENT    => "32K",
		DEBUGGABLE   => "NO",
		PACKABLE     => "NO",
		INIT_FILE    => "../low-init.mif",
		FILL_ALL     => "NONE"
	)
	port map(
		dia   => interface_in.data,
		dib => (others => '0'),
		addra => interface_in.adr(14 downto 0),
		addrb => (others => '0'),
		cea   => '1',
		ceb   => '0',
		clka  => interface_in.clk,
		clkb  => '0',
		wea   => write_en_low,
		bea => (others => '0'),
		beb => (others => '0'),
		web   => '0',
		rsta  => '0',
		rstb  => '0',
		doa   => data_out_low,
		dob   => open,
		ocea  => '0',
		oceb  => '0'
	);

	inst_9k : EG_LOGIC_BRAM
	generic map(
		DATA_WIDTH_A => 16,
		ADDR_WIDTH_A => 15,
		DATA_DEPTH_A => 32768,
		DATA_WIDTH_B => 16,
		ADDR_WIDTH_B => 15,
		DATA_DEPTH_B => 32768,
		MODE         => "SP",
		REGMODE_A    => "NOREG",
		WRITEMODE_A  => "NORMAL",
		RESETMODE    => "SYNC",
		IMPLEMENT    => "9K",
		DEBUGGABLE   => "NO",
		PACKABLE     => "NO",
		INIT_FILE    => "../high-init.mif",
		FILL_ALL     => "NONE"
	)
	port map(
		dia   => interface_in.data,
		dib => (others => '0'),
		addra => interface_in.adr(14 downto 0),
		addrb => (others => '0'),
		cea   => '1',
		ceb   => '0',
		clka  => interface_in.clk,
		clkb  => '0',
		wea   => write_en_high,
		bea => (others => '0'),
		beb => (others => '0'),
		web   => '0',
		rsta  => '0',
		rstb  => '0',
		doa   => data_out_high,
		dob   => open,
		ocea  => '0',
		oceb  => '0'
	);

end architecture;