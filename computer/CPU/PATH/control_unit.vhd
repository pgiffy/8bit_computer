library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity control_unit is
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

end entity;

architecture control_unit_arch of control_unit is

type state_type is
	(S_FETCH_0, S_FETCH_1, S_FETCH_2, -- Opcode fetch states

	S_DECODE_3,                       --Opcode decode state (which FSM path)

	S_LDA_IMM_4, S_LDA_IMM_5, S_LDA_IMM_6, --Load A (Immediate) states

	S_LDA_DIR_4,
	S_LDA_DIR_5, S_LDA_DIR_6, S_LDA_DIR_7, S_LDA_DIR_8, --Load A (Direct) states

	S_STA_DIR_4, S_STA_DIR_5, S_STA_DIR_6, S_STA_DIR_7, S_STA_DIR_8,

	S_LDB_IMM_4, S_LDB_IMM_5, S_LDB_IMM_6, --Load B (Immediate) states

	S_LDB_DIR_4, S_LDB_DIR_5, S_LDB_DIR_6, S_LDB_DIR_7, S_LDB_DIR_8, --Load B (Direct) states

	S_STB_DIR_4, S_STB_DIR_5, S_STB_DIR_6, S_STB_DIR_7, S_STB_DIR_8,

	S_ADD_AB_4, 
	S_SUB_AB_4,

	S_INCA_4, S_INCB_4,
	S_DECA_4, S_DECB_4,

	S_AND_AB_4, S_OR_AB_4,

	S_BRA_4, S_BRA_5, S_BRA_6,
	S_BEQ_4, S_BEQ_5, S_BEQ_6, S_BEQ_7,
	S_BCS_4, S_BCS_5, S_BCS_6, S_BCS_7,
	S_BVS_4, S_BVS_5, S_BVS_6, S_BVS_7,
	S_BMI_4, S_BMI_5, S_BMI_6, S_BMI_7

);

signal current_state, next_state : state_type;

	--Constants for Instruction Neumonics
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

begin

---------------------------------------------------------
--STATE MEMORY
----------------------------------------------------------
STATE_MEMORY : process (Clock, Reset)
	begin 
		if(Reset = '0') then
			current_state <= S_FETCH_0;
		elsif(clock'event and clock = '1') then
			current_state <= next_state;
		end if;
	end process;

---------------------------------------------------------
--NEXT STATE LOGIC
---------------------------------------------------------

-- What controls the path in the finite state machine
NEXT_STATE_LOGIC : process(current_state, IR, CCR_Result)
	begin
		if(current_state = S_FETCH_0) then
			next_state <= S_FETCH_1;
		elsif (current_state = S_FETCH_1) then
			next_state <= S_FETCH_2;
		elsif (current_state = S_FETCH_2) then
			next_state <= S_DECODE_3;
		elsif (current_state = S_DECODE_3) then

			-- This is where the different paths in FSM are decided
			if(IR = LDA_IMM) then
				next_state <= S_LDA_IMM_4; --Register A
			elsif (IR = LDA_DIR) then
				next_state <= S_LDA_DIR_4;
			elsif (IR = STA_DIR) then
				next_state <= S_STA_DIR_4;
			elsif (IR = STA_DIR) then
				next_state <= S_LDB_IMM_4;
			elsif (IR = LDB_DIR) then
				next_state <= S_LDB_DIR_4;
			elsif (IR = STB_DIR) then
				next_state <= S_STB_DIR_4;
			elsif (IR = LDB_IMM) then
				next_state <= S_LDB_IMM_4;

			elsif (IR = BRA) then           -- Branches
				next_state <= S_BRA_4;

			elsif (IR = ADD_AB) then         -- Add
				next_state <= S_ADD_AB_4;

			elsif (IR = SUB_AB) then         -- subtract
				next_state <= S_SUB_AB_4;

			elsif (IR = INCA) then         -- increment A
				next_state <= S_INCA_4;

			elsif (IR = INCB) then         -- increment B
				next_state <= S_INCB_4;

			elsif (IR = DECA) then         -- decrement A
				next_state <= S_DECA_4;

			elsif (IR = DECB) then         -- decrement B
				next_state <= S_DECB_4;

			elsif (IR = AND_AB) then         -- decrement A
				next_state <= S_AND_AB_4;

			elsif (IR = OR_AB) then         -- decrement B
				next_state <= S_OR_AB_4;
			
			elsif (IR = BEQ and CCR_Result(2) = '1') then -- other branches NZVC
				next_state <= S_BEQ_4;
			elsif (IR = BEQ and CCR_Result(2) = '0') then
				next_state <= S_BEQ_7;
			
			elsif (IR = BCS and CCR_Result(4) = '1') then
				next_state <= S_BCS_4;
			elsif (IR = BCS and CCR_Result(4) = '0') then
				next_state <= S_BCS_7;

			elsif (IR = BVS and CCR_Result(3) = '1') then
				next_state <= S_BVS_4;
			elsif (IR = BVS and CCR_Result(3) = '0') then
				next_state <= S_BVS_7;

			elsif (IR = BMI and CCR_Result(1) = '1') then
				next_state <= S_BMI_4;
			elsif (IR = BMI and CCR_Result(1) = '0') then
				next_state <= S_BMI_7;

			else
				next_state <= S_FETCH_0;
			end if;

		elsif (current_state = S_LDA_IMM_4) then  -- Path for LDA_IMM instruction
			next_state <= S_LDA_IMM_5;
		elsif (current_state = S_LDA_IMM_5) then
			next_state <= S_LDA_IMM_6;
		elsif (current_state = S_LDA_IMM_6) then
			next_state <= S_FETCH_0;

		elsif (current_state = S_LDA_DIR_4) then -- Path for LDA_DIR instruction
			next_state <= S_LDA_DIR_5;
		elsif (current_state = S_LDA_DIR_5) then 
			next_state <= S_LDA_DIR_6;
		elsif (current_state = S_LDA_DIR_6) then 
			next_state <= S_LDA_DIR_7;
		elsif (current_state = S_LDA_DIR_7) then 
			next_state <= S_LDA_DIR_8;
		elsif (current_state = S_LDA_DIR_8) then 
			next_state <= S_FETCH_0;

		elsif(current_state = S_STA_DIR_4) then -- Path for STA_DIR
			next_state <= S_STA_DIR_5;
		elsif(current_state = S_STA_DIR_5) then
			next_state <= S_STA_DIR_6;
		elsif(current_state = S_STA_DIR_6) then
			next_state <= S_STA_DIR_7;
		elsif(current_state = S_STA_DIR_7) then
			next_state <= S_FETCH_0;

		elsif (current_state = S_LDB_IMM_4) then  -- Path for LDA_IMM instruction
			next_state <= S_LDB_IMM_5;
		elsif (current_state = S_LDB_IMM_5) then
			next_state <= S_LDB_IMM_6;
		elsif (current_state = S_LDB_IMM_6) then
			next_state <= S_FETCH_0;

		elsif (current_state = S_LDB_DIR_4) then -- Path for LDA_DIR instruction
			next_state <= S_LDB_DIR_5;
		elsif (current_state = S_LDB_DIR_5) then 
			next_state <= S_LDB_DIR_6;
		elsif (current_state = S_LDB_DIR_6) then 
			next_state <= S_LDB_DIR_7;
		elsif (current_state = S_LDB_DIR_7) then 
			next_state <= S_LDB_DIR_8;
		elsif (current_state = S_LDB_DIR_8) then 
			next_state <= S_FETCH_0;

		elsif(current_state = S_STB_DIR_4) then -- Path for STA_DIR
			next_state <= S_STB_DIR_5;
		elsif(current_state = S_STB_DIR_5) then
			next_state <= S_STB_DIR_6;
		elsif(current_state = S_STB_DIR_6) then
			next_state <= S_STB_DIR_7;
		elsif(current_state = S_STB_DIR_7) then
			next_state <= S_FETCH_0;

		elsif(current_state = S_BRA_4) then   -- Path for BRA
			next_state <= S_BRA_5;
		elsif(current_state = S_BRA_5) then
			next_state <= S_BRA_6;
		elsif(current_state = S_BRA_6) then
			next_state <= S_FETCH_0;

		elsif(current_state = S_ADD_AB_4) then -- path for ADD_AB
			next_state <= S_FETCH_0;

		elsif(current_state = S_SUB_AB_4) then -- path for SUB_AB
			next_state <= S_FETCH_0;

		elsif(current_state = S_BEQ_4) then -- path for BEQ with Z = 1
			next_state <= S_BEQ_5;
		elsif(current_state = S_BEQ_5) then
			next_state <= S_BEQ_6;
		elsif(current_state = S_BEQ_6) then
			next_state <= S_FETCH_0;

		elsif(current_state = S_BEQ_7) then -- path for BEQ with Z = 0
			next_state <= S_FETCH_0;

		elsif(current_state = S_BCS_4) then -- path for BCS with C = 1
			next_state <= S_BCS_5;
		elsif(current_state = S_BCS_5) then
			next_state <= S_BCS_6;
		elsif(current_state = S_BCS_6) then
			next_state <= S_FETCH_0;

		elsif(current_state = S_BCS_7) then -- path for BCS with C = 0
			next_state <= S_FETCH_0;

		elsif(current_state = S_BVS_4) then -- path for BVS with V = 1
			next_state <= S_BVS_5;
		elsif(current_state = S_BVS_5) then
			next_state <= S_BVS_6;
		elsif(current_state = S_BVS_6) then
			next_state <= S_FETCH_0;

		elsif(current_state = S_BVS_7) then -- path for BVS with V = 0
			next_state <= S_FETCH_0;

		elsif(current_state = S_BMI_4) then -- path for BMI with N = 1
			next_state <= S_BMI_5;
		elsif(current_state = S_BMI_5) then
			next_state <= S_BMI_6;
		elsif(current_state = S_BMI_6) then
			next_state <= S_FETCH_0;

		elsif(current_state = S_BMI_7) then -- path for BMI with N = 0
			next_state <= S_FETCH_0;


		elsif(current_state = S_INCA_4) then -- Increment A path
			next_state <= S_FETCH_0;

		elsif(current_state = S_INCB_4) then -- Increment B path
			next_state <= S_FETCH_0;

		elsif(current_state = S_DECA_4) then -- Decrement A path
			next_state <= S_FETCH_0;

		elsif(current_state = S_DECB_4) then -- Decrement B path
			next_state <= S_FETCH_0;

		elsif(current_state = S_AND_AB_4) then -- Decrement A path
			next_state <= S_FETCH_0;

		elsif(current_state = S_OR_AB_4) then -- Decrement B path
			next_state <= S_FETCH_0;
		--paths for instructions
		
		end if;
	end process;
	

------------------------------------------------------
--OUTPUT LOGIC
------------------------------------------------------

OUTPUT_LOGIC : process (current_state)
	begin 
	
		-- All of the output signals need to be driven for each state in the FSM
		
	case(current_state) is

-------------------------------------------------------------------
--UNIVERSAL FIRST FOUR States
--Putting the opcode into the IR and then decode the opcode
-------------------------------------------------------------------
		when S_FETCH_0 => -- Put PC onto MAR to read Opcode
			IR_LOAD <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_FETCH_1 => -- Incrament PC
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_FETCH_2 => -- Put Opcode into IR!!!!!
			IR_LOAD <= '1';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_DECODE_3 => -- No outputs, machine is decoding IR to decide which state to go to next
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';
		
------------------------------------------------------------------------------------------------------------
--LDA_IMM
------------------------------------------------------------------------------------------------------------
		when S_LDA_IMM_4 => -- Load MAR with the address contained (PC is already pointing at the location
			IR_LOAD <= '0'; -- In memory of the data we want
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_LDA_IMM_5 => -- Incrament PC
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_LDA_IMM_6 => -- No outputs, machine is decoding IR to decide which state to go to next
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '1';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

------------------------------------------------------------------------------------------------------------
--LDA_DIR
------------------------------------------------------------------------------------------------------------
		when S_LDA_DIR_4 => -- Retrieving the operand!
			IR_LOAD <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';	
			
		when S_LDA_DIR_5 => -- Incrament the clock
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_LDA_DIR_6 => -- The operand has been read is is now available (put it into MAR)
			IR_LOAD <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_LDA_DIR_7 => -- wait for the memory to provide the contents at the address on MAR
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_LDA_DIR_8 => -- MAR is driving the correct address and now put contents into A
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '1';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

------------------------------------------------------------------------------------------------------------
--STA_DIR
------------------------------------------------------------------------------------------------------------
		when S_STA_DIR_4 => -- Operant is the location of where to write A to, put address on MAR
			IR_LOAD <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_STA_DIR_5 => -- itterate the clock
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_STA_DIR_6 => -- The operand has been read and is available on Bus 2
			IR_LOAD <= '0'; --put the address where we want to write to on MAR
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_STA_DIR_7 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "01"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '1';
------------------------------------------------------------------------------------------------------------
--BRA
------------------------------------------------------------------------------------------------------------

		when S_BRA_4 => -- Want to load PC with the address provided in the operand
			IR_LOAD <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_BRA_5 => -- Wait a cycle for MAR to point to right place
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_BRA_6 => -- The operand has been read and is available on BUS2 to be loaded onto PC
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '1';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

------------------------------------------------------------------------------------------------------------
--LDB_IMM
------------------------------------------------------------------------------------------------------------

		when S_LDB_IMM_4 => -- Load MAR with the address contained (PC is already pointing at the location
			IR_LOAD <= '0'; -- In memory of the data we want
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_LDB_IMM_5 => -- Incrament PC
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_LDB_IMM_6 => -- No outputs, machine is decoding IR to decide which state to go to next
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '1';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

------------------------------------------------------------------------------------------------------------
--LDB_DIR
------------------------------------------------------------------------------------------------------------
		when S_LDB_DIR_4 => -- Retrieving the operand!
			IR_LOAD <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';	
			
		when S_LDB_DIR_5 => -- Incrament the clock
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_LDB_DIR_6 => -- The operand has been read is is now available (put it into MAR)
			IR_LOAD <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_LDB_DIR_7 => -- wait for the memory to provide the contents at the address on MAR
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_LDB_DIR_8 => -- MAR is driving the correct address and now put contents into A
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '1';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';
------------------------------------------------------------------------------------------------------------
--STB_DIR
------------------------------------------------------------------------------------------------------------
		when S_STB_DIR_4 => -- Operant is the location of where to write A to, put address on MAR
			IR_LOAD <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_STB_DIR_5 => -- itterate the clock
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_STB_DIR_6 => -- The operand has been read and is available on Bus 2
			IR_LOAD <= '0'; --put the address where we want to write to on MAR
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_STB_DIR_7 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "10"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '1';
------------------------------------------------------------------------------------------------------------
--ADD_AB
------------------------------------------------------------------------------------------------------------
		when S_ADD_AB_4 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '1';
			B_Load <= '0';
			ALU_Sel <= "000"; -- "000" =  add "001" = sub
			CCR_Load <= '1';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "01"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

------------------------------------------------------------------------------------------------------------
--SUB_AB
------------------------------------------------------------------------------------------------------------
		when S_SUB_AB_4 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '1';
			B_Load <= '0';
			ALU_Sel <= "001"; -- "000" =  add "001" = sub
			CCR_Load <= '1';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "01"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

------------------------------------------------------------------------------------------------------------
--INCA
------------------------------------------------------------------------------------------------------------
		when S_INCA_4 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '1';
			B_Load <= '0';
			ALU_Sel <= "010"; -- "000"=add "001"=sub "010"=increment A
			CCR_Load <= '1';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "01"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

------------------------------------------------------------------------------------------------------------
--INCB
------------------------------------------------------------------------------------------------------------
		when S_INCB_4 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '1';
			ALU_Sel <= "011"; -- "000"=add "001"=sub "010"=increment A "011"=incrment B
			CCR_Load <= '1';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

------------------------------------------------------------------------------------------------------------
--DECA
------------------------------------------------------------------------------------------------------------
		when S_DECA_4 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '1';
			B_Load <= '0';
			ALU_Sel <= "100"; -- "000"=add "001"=sub "010"=increment A "100"=Decrement A
			CCR_Load <= '1';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "01"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

------------------------------------------------------------------------------------------------------------
--DECB
------------------------------------------------------------------------------------------------------------
		when S_DECB_4 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '1';
			ALU_Sel <= "101"; -- "000"=add "001"=sub "010"=increment A "011"=incrment B "101" = Decrement B
			CCR_Load <= '1';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';
------------------------------------------------------------------------------------------------------------
--AND_AB
------------------------------------------------------------------------------------------------------------
		when S_AND_AB_4 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '1';
			B_Load <= '0';
			ALU_Sel <= "110"; -- "000"=add "001"=sub "010"=increment A "100"=Decrement A
			CCR_Load <= '1';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "01"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

------------------------------------------------------------------------------------------------------------
--OR_AB
------------------------------------------------------------------------------------------------------------
		when S_OR_AB_4 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '1';
			B_Load <= '0';
			ALU_Sel <= "111"; -- "000"=add "001"=sub "010"=increment A "011"=incrment B "101" = Decrement B
			CCR_Load <= '1';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "01"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

------------------------------------------------------------------------------------------------------------
--BEQ
------------------------------------------------------------------------------------------------------------
		when S_BEQ_4 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000"; -- "000" =  add
			CCR_Load <= '1';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_BEQ_5 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000"; -- "000" =  add
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_BEQ_6 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '1';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000"; -- "000" =  add
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_BEQ_7 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000"; -- "000" =  add
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

------------------------------------------------------------------------------------------------------------
--BCS
------------------------------------------------------------------------------------------------------------
		when S_BCS_4 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000"; -- "000" =  add
			CCR_Load <= '1';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_BCS_5 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000"; -- "000" =  add
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_BCS_6 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '1';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000"; -- "000" =  add
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_BCS_7 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000"; -- "000" =  add
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';
------------------------------------------------------------------------------------------------------------
--BVS
------------------------------------------------------------------------------------------------------------
		when S_BVS_4 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000"; -- "000" =  add
			CCR_Load <= '1';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_BVS_5 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000"; -- "000" =  add
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_BVS_6 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '1';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000"; -- "000" =  add
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_BVS_7 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000"; -- "000" =  add
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

------------------------------------------------------------------------------------------------------------
--BMI
------------------------------------------------------------------------------------------------------------
		when S_BMI_4 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000"; -- "000" =  add
			CCR_Load <= '1';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_BMI_5 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000"; -- "000" =  add
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_BMI_6 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '1';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000"; -- "000" =  add
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

		when S_BMI_7 => -- Now that MAR is pointing to the address write the info to the address
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000"; -- "000" =  add
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';

-- THE OTHER OUTPUT ASSIGNEMNTS ARE HERE

		when others => -- No outputs, machine is decoding IR to decide which state to go to next
			IR_LOAD <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_INC <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';  -- Codes for demultiplexer in the data_path
			Bus1_Sel <= "00"; -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
			writer <= '0';
		end case;
	end process;

end architecture;
