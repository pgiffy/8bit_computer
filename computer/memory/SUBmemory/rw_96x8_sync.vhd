library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity rw_96x8_sync is
	port(address : in std_logic_vector (7 downto 0);
		data_in : in std_logic_vector (7 downto 0);
		writer : in std_logic;
		clock : in std_logic;
		
		data_out : out std_logic_vector (7 downto 0));
end entity;

architecture rw_96x8_sync_arch of rw_96x8_sync is

--Setting the memory locations for the rw type memory
type rw_type is array (128 to 223) of std_logic_vector(7 downto 0);

--Signal since we want to read and write to it, NO LONGER a constant as rom
signal RW: rw_type;
signal EN: std_logic; -- Internal enable line

begin
		

		--Enables this block of memory for when address is valid--
		enable: process(address)
		begin
			if((to_integer(unsigned(address)) >= 128) and
			   (to_integer(unsigned(address)) <= 223)) then
			EN <= '1';
			else
			EN <= '0';
			end if;
		end process;
		

----------------Reading or writing capability--------------------------------------------
		memory : process (clock)
		begin
			if (clock'event and clock = '1') then
				if (EN= '1' and writer='1') then

					-- YES FILL ME WITH DATA where you want
					RW (to_integer(unsigned(address))) <= data_in;

				elsif(EN= '1' and writer='0') then

					-- HERE IS YA DATA from where you want
					data_out <= RW(to_integer(unsigned(address)));
				end if;
			end if;
		end process;

end architecture;