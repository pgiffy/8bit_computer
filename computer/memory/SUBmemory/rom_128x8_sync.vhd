library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity rom_128x8_sync is
	port(address : in std_logic_vector (7 downto 0);
		clock : in std_logic;
	
		data_out : out std_logic_vector (7 downto 0));
end entity;

architecture rom_128x8_sync_arch of rom_128x8_sync is

	-- Constants for Instruction neumonics
	constant LDA_IMM : std_logic_vector (7 downto 0) :=x"86";
	constant LDA_DIR : std_logic_vector (7 downto 0) :=x"87";
	constant LDB_IMM : std_logic_vector (7 downto 0) :=x"88";
	constant LDB_DIR : std_logic_vector (7 downto 0) :=x"89";
	constant STA_DIR : std_logic_vector (7 downto 0) :=x"96";
	constant STB_DIR : std_logic_vector (7 downto 0) :=x"97";
	constant ADD_AB : std_logic_vector (7 downto 0) :=x"42";
	constant SUB_AB : std_logic_vector (7 downto 0) :=x"43";
	constant AND_AB : std_logic_vector (7 downto 0) :=x"44";
	constant OR_AB : std_logic_vector (7 downto 0) :=x"45";
	constant INCA : std_logic_vector (7 downto 0) :=x"46";
	constant INCB : std_logic_vector (7 downto 0) :=x"47";
	constant DECA : std_logic_vector (7 downto 0) :=x"48";
	constant DECB : std_logic_vector (7 downto 0) :=x"49";
	constant BRA : std_logic_vector (7 downto 0) :=x"20";
	constant BMI : std_logic_vector (7 downto 0) :=x"21";
	constant BPL : std_logic_vector (7 downto 0) :=x"22";
	constant BEQ : std_logic_vector (7 downto 0) :=x"23";
	constant BNE : std_logic_vector (7 downto 0) :=x"24";
	constant BVS : std_logic_vector (7 downto 0) :=x"25";
	constant BVC : std_logic_vector (7 downto 0) :=x"26";
	constant BCS : std_logic_vector (7 downto 0) :=x"27";
	constant BCC : std_logic_vector (7 downto 0) :=x"28";


	-- Hard coding the addresses in the rom array

	type rom_type is array (0 to 127) of std_logic_vector(7 downto 0);

	-- Is the first program that writes x"AA" to port_out_00 (E0)

	constant ROM : rom_type := (0  => LDA_IMM,
       			 	  1  => x"AA",
			  	  2  => LDA_IMM,
			 	  3  => x"CC",
			 	  4  => STA_DIR,
			 	  5  => x"80",
				  6  => STA_DIR,
				  7  => x"E0",
				  8  => LDA_IMM,
				  9  => x"AA",
				  10 => LDA_DIR,
				  11 => x"80",
				  12 => BRA,
				  13 => x"00",
			 	  others => x"00");
	signal EN : std_logic; -- Internal enable line
	begin

	-- Handels only reading from ROM in a valid range
	enable: process(address)
		begin
			if((to_integer(unsigned(address)) >= 0) and
			   (to_integer(unsigned(address)) <= 127)) then
			EN <= '1';
			else
			EN <= '0';
			end if;
		end process;
	
	memory : process (clock)
		begin
		if (clock'event and clock = '1') then
			if (EN = '1') then
				data_out <= ROM(to_integer(unsigned(address)));
			end if;
		end if;
		end process;

end architecture;