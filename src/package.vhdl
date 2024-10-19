library ieee;
use ieee.std_logic_1164.all;

package package_16TTAC is

    subtype select_type is std_logic_vector(6 downto 0);

    type cpu_bus_in is record
        clk      : std_logic;
        reset    : std_logic;
        src_sel  : select_type;
        dest_sel : select_type;
        data     : std_logic_vector(15 downto 0);
    end record;

    type cpu_bus_out is record
        data : std_logic_vector(15 downto 0);
        halt : std_logic;
    end record;

    type mem_interface_in is record
        clk      : std_logic;
        write_en : std_logic;
        adr      : std_logic_vector(15 downto 0);
        data     : std_logic_vector(15 downto 0);
    end record;

    type mem_interface_out is record
        data : std_logic_vector(15 downto 0);
    end record;

    type io_interface_in is record
        clk      : std_logic;
        reset    : std_logic;
        write_en : std_logic;
        data     : std_logic_vector(7 downto 0);
    end record;

    type io_interface_out is record
        write_avail : std_logic;
        new_data    : std_logic;
        data        : std_logic_vector(7 downto 0);
    end record;

    -- SOURCES
    constant SEL_SRC_NULL   : select_type := 7x"00";
    constant SEL_SRC_ACC    : select_type := 7x"01";
    constant SEL_SRC_TRUE   : select_type := 7x"02";
    constant SEL_SRC_OP     : select_type := 7x"03";
    constant SEL_SRC_ADR    : select_type := 7x"04";
    constant SEL_SRC_MEM    : select_type := 7x"05";
    constant SEL_SRC_PC     : select_type := 7x"06";
    constant SEL_SRC_POP    : select_type := 7x"07";
    constant SEL_SRC_IN     : select_type := 7x"08";
    constant SEL_SRC_IN_AV  : select_type := 7x"09";
    constant SEL_SRC_OUT_AV : select_type := 7x"0A";
    constant SEL_SRC_LED    : select_type := 7x"0B";

    -- DESTINATIONS
    constant SEL_DEST_NULL  : select_type := 7x"00";
    constant SEL_DEST_ACC   : select_type := 7x"01";
    constant SEL_DEST_ADD   : select_type := 7x"02";
    constant SEL_DEST_ADDC  : select_type := 7x"03";
    constant SEL_DEST_SUB   : select_type := 7x"04";
    constant SEL_DEST_SUBC  : select_type := 7x"05";
    constant SEL_DEST_MUL   : select_type := 7x"06";
    constant SEL_DEST_SHL   : select_type := 7x"07";
    constant SEL_DEST_SHR   : select_type := 7x"08";
    constant SEL_DEST_AND   : select_type := 7x"09";
    constant SEL_DEST_XOR   : select_type := 7x"0A";
    constant SEL_DEST_OR    : select_type := 7x"0B";
    constant SEL_DEST_CARRY : select_type := 7x"0C";
    constant SEL_DEST_ZERO  : select_type := 7x"0D";
    constant SEL_DEST_HALT  : select_type := 7x"0E";
    constant SEL_DEST_OUT   : select_type := 7x"0F";
    constant SEL_DEST_LED   : select_type := 7x"10";
    constant SEL_DEST_ADR   : select_type := 7x"11";
    constant SEL_DEST_MEM   : select_type := 7x"12";
    constant SEL_DEST_CALL  : select_type := 7x"13";
    constant SEL_DEST_PC    : select_type := 7x"14";
    constant SEL_DEST_PUSH  : select_type := 7x"15";

end package;