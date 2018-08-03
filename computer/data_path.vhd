library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity data_path is
	port(clock : in std_logic;
		reset : in std_logic;
		from_memory : in std_logic_vector (7 downto 0);
		IR_Load : in std_logic;
		MAR_Load : in std_logic;
		PC_Load : in std_logic;
		PC_Inc : in std_logic;
		A_Load : in std_logic;
		B_Load : in std_logic;
		ALU_Sel : in std_logic_vector (2 downto 0);
		CCR_Load : in std_logic;
		Bus2_Sel : in std_logic_vector (1 downto 0);
		Bus1_Sel : in std_logic_vector (1 downto 0);
	
		IR : out std_logic_vector (7 downto 0);
		CCR_Result : out std_logic_vector (3 downto 0);
		address : out std_logic_vector (7 downto 0);
		to_memory : out std_logic_vector (7 downto 0));
end entity;

architecture data_path_arch of data_path is

	component alu
		port(ALU_Sel : in std_logic_vector (2 downto 0);
		B : in std_logic_vector (7 downto 0);
		BUS1 : in std_logic_vector (7 downto 0);

		NZVC : out std_logic_vector (3 downto 0);
		BUS2 : out std_logic_vector (7 downto 0));
	end component;

	-- All of the internal data_path signals, there are alot!!!!
	signal Bus1 : std_logic_vector(7 downto 0);
	signal Bus2 : std_logic_vector(7 downto 0);
	signal PC : std_logic_vector(7 downto 0);
	signal A : std_logic_vector(7 downto 0);
	signal B : std_logic_vector(7 downto 0);
	signal ALU_Result: std_logic_vector(7 downto 0);
	signal MAR : std_logic_vector(7 downto 0);
	signal PC_uns: unsigned(7 downto 0);
	signal NZVC : std_logic_vector (3 downto 0);
	
	
	
begin

--The data_path within the CPU

--What goes onto the bus and the demultiplexers are all controlled by the
--control_unit.vhd

--What do you need on BUS1? PC, A or B?
MUX_BUS1: process (Bus1_Sel, PC, A, B)
	begin
	case (Bus1_Sel) is
			when "00" => Bus1 <= PC; --Do ya need PC to go to the MAR?
			when "01" => Bus1 <= A; --Ya need to store either A or B?
			when "10" => Bus1 <= B; --Or have A or B
			when others => Bus1 <= x"00";
		end case;
	end process;

--What do you need on BUS2 (the big one)
MUX_BUS2: process (Bus2_Sel, ALU_Result, Bus1, from_memory)
	begin
		case (Bus2_Sel) is
			when "00" => Bus2 <= ALU_Result; --Get result of maths or logic operations
			when "01" => Bus2 <= Bus1; --Either PC (fetching) or A or B
			when "10" => Bus2 <= from_memory;--Get stuff from memory
			when others => Bus2 <= x"00";
		end case;
	end process;

--MAR write to the address!!! give me the memory info!!!
address <= MAR;
to_memory <= Bus1;

----What register do you want to access and load what ever is on
----BUS2 to it, ex. MAR gets whats on the PC 

-- ALL the registers!!!!!

INSTRUCTION_REGISTER : process (Clock, Reset)
	begin
		if(Reset = '0') then
			IR <= x"00";
		elsif (Clock'event and Clock = '1') then 
			if(IR_Load = '1') then
				IR <= Bus2;
			end if;
		end if;
	end process;

MEMORY_ADDRESS_REGISTER : process(Clock, Reset)
	begin	
		if(Reset = '0') then
			MAR <= x"00";
		elsif (Clock'event and Clock = '1') then
			if(MAR_Load = '1') then
				MAR <= Bus2;
			end if;
		end if;
	end process;

PROGRAM_COUNTER : process (Clock, Reset)
	begin
		if (Reset = '0') then 
		
		--More than just a reset!!!! where I am going to get code upon
		-- bootup! How cool is that?
			PC_uns <= x"00";
		elsif (Clock'event and Clock = '1') then
			if(PC_Load = '1') then
				PC_uns <= unsigned(Bus2);
			elsif (PC_Inc = '1') then
				PC_uns <= PC_uns +1;
			end if;
		end if;
	end process;

	PC <= std_logic_vector(PC_uns); -- earlier I wanted the '+' operator to incrament

A_REGISTER : process (Clock, Reset)
	begin
		if (Reset = '0') then 
			A <= x"00";
		elsif (Clock'event and Clock = '1') then
			if(A_Load = '1') then
				A <= Bus2;
			end if;
		end if;
	end process;

B_REGISTER : process (Clock, Reset)
	begin
		if (Reset = '0') then 
			B <= x"00";
		elsif (Clock'event and Clock = '1') then
			if(B_Load = '1') then
				B <= Bus2;
			end if;
		end if;
	end process;

CONDITION_CODE_REGISTER : process (Clock, Reset)
	begin
		if(Reset = '0') then
			CCR_Result <= x"0";
		elsif (Clock'event and Clock = '1') then 
			if(CCR_Load = '1') then
				CCR_Result <= NZVC;
			end if;
		end if;
	end process;

end architecture;