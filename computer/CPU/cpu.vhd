library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity cpu is
	port(clock : in std_logic;
		reset : in std_logic;
		from_memory : in std_logic_vector (7 downto 0);
		
		address : out std_logic_vector (7 downto 0);
		writer : out std_logic;
		to_memory : out std_logic_vector (7 downto 0));

end entity;

architecture cpu_arch of cpu is
	component data_path
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
	end component;

	component control_unit
		port(clock : in std_logic;
		reset : in std_logic;
		IR : in std_logic_vector (7 downto 0);
		CCR_Result : in std_logic_vector (3 downto 0);

		IR_Load : out std_logic;
		MAR_Load : out std_logic;
		PC_Load : out std_logic;
		PC_Inc : out std_logic;
		A_Load : out std_logic;
		B_Load : out std_logic;
		ALU_Sel : out std_logic_vector (2 downto 0);
		CCR_Load : out std_logic;
		Bus2_Sel : out std_logic_vector (1 downto 0);
		Bus1_Sel : out std_logic_vector (1 downto 0);
		writer : out std_logic);
	end component;

	signal IR_Load : std_logic;
	signal IR : std_logic_vector (7 downto 0);
	signal MAR_Load : std_logic;
	signal PC_Load : std_logic;
	signal PC_Inc : std_logic;
	signal A_Load : std_logic;
	signal B_Load : std_logic;
	signal ALU_Sel : std_logic_vector (2 downto 0);
	signal CCR_Result : std_logic_vector (3 downto 0);
	signal CCR_Load : std_logic;
	signal Bus2_Sel : std_logic_vector (1 downto 0);
	signal Bus1_Sel : std_logic_vector (1 downto 0);

begin 

	DATA : data_path port map (clock, reset, from_memory, IR_Load, MAR_Load, PC_Load, PC_Inc, A_Load, B_Load, ALU_Sel, CCR_Load, Bus2_Sel, Bus1_Sel, IR, CCR_Result, address, to_memory);
	CONTROL : control_unit port map (clock, reset, IR, CCR_Result, IR_Load, MAR_Load, PC_Load, PC_Inc, A_Load, B_Load, ALU_Sel, CCR_Load, Bus2_Sel, Bus1_Sel, writer);

end architecture;