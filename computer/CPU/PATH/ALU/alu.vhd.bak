library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity alu is
	port(ALU_Sel : in std_logic_vector (2 downto 0);
	B : in std_logic_vector (7 downto 0);
	BUS1 : in std_logic_vector (7 downto 0);

	NZVC : out std_logic_vector (3 downto 0);
	result : out std_logic_vector (7 downto 0));
end entity;

architecture alu_arch of alu is

signal A : std_logic_vector(7 downto 0);

begin


ALU_PROCESS : process (A, B, ALU_Sel)

variable Sum_uns : unsigned(8 downto 0);

begin
	if(ALU_Sel = "000") then -- ADD
	----Sun CAlC -------------------------------------------------
	Sum_uns := unsigned('0' & A) + unsigned('0' & B);
	Result <= std_logic_vector(Sum_uns(7 downto 0));

	--Negations Flag-----------------------------------------------
	NZVC(3) <= Sum_uns(7);

	--Zero Flag ----------------------------------------------------
		if(Sum_uns(7 downto 0) = x"00") then
			NZVC(2) <= '1';
		else
			NZVC(2) <= '0';
		end if;
	-- Carry Flag (C) ---------------------------------------------
	NZVC(0) <= Sum_uns(8);
	end if;
------------------------------------------------------------------------------------------------
	if(ALU_Sel = "001") then -- Subtract
	----Sun CAlC -------------------------------------------------
	Sum_uns := unsigned('0' & A) - unsigned('0' & B);
	Result <= std_logic_vector(Sum_uns(7 downto 0));

	--Negations Flag-----------------------------------------------
	NZVC(3) <= Sum_uns(7);

	--Zero Flag ----------------------------------------------------
		if(Sum_uns(7 downto 0) = x"00") then
			NZVC(2) <= '1';
		else
			NZVC(2) <= '0';
		end if;
	-- Carry Flag (C) ---------------------------------------------
	NZVC(0) <= Sum_uns(8);
	end if;
--------------------------------------------------------------------------------------------
	if(ALU_Sel = "010") then --incrment A
	----Sun CAlC -------------------------------------------------
	Sum_uns := unsigned('0' & A) + "00000001";
	Result <= std_logic_vector(Sum_uns(7 downto 0));

	--Negations Flag-----------------------------------------------
	NZVC(3) <= Sum_uns(7);

	--Zero Flag ----------------------------------------------------
		if(Sum_uns(7 downto 0) = x"00") then
			NZVC(2) <= '1';
		else
			NZVC(2) <= '0';
		end if;
	-- Carry Flag (C) ---------------------------------------------
	NZVC(0) <= Sum_uns(8);
	end if;
------------------------------------------------------------------------------------------------
	if(ALU_Sel = "011") then --incrment B
	----Sun CAlC -------------------------------------------------
	Sum_uns := unsigned('0' & B) + "00000001";
	Result <= std_logic_vector(Sum_uns(7 downto 0));

	--Negations Flag-----------------------------------------------
	NZVC(3) <= Sum_uns(7);

	--Zero Flag ----------------------------------------------------
		if(Sum_uns(7 downto 0) = x"00") then
			NZVC(2) <= '1';
		else
			NZVC(2) <= '0';
		end if;
	-- Carry Flag (C) ---------------------------------------------
	NZVC(0) <= Sum_uns(8);
	end if;
---------------------------------------------------------------------------------------------------
	if(ALU_Sel = "100") then --decrment A
	----Sun CAlC -------------------------------------------------
	Sum_uns := unsigned('0' & A) - "00000001";
	Result <= std_logic_vector(Sum_uns(7 downto 0));

	--Negations Flag-----------------------------------------------
	NZVC(3) <= Sum_uns(7);

	--Zero Flag ----------------------------------------------------
		if(Sum_uns(7 downto 0) = x"00") then
			NZVC(2) <= '1';
		else
			NZVC(2) <= '0';
		end if;
	-- Carry Flag (C) ---------------------------------------------
	NZVC(0) <= Sum_uns(8);
	end if;
------------------------------------------------------------------------------------------------
	if(ALU_Sel = "101") then --decrment B
	----Sun CAlC -------------------------------------------------
	Sum_uns := unsigned('0' & B) - "00000001";
	Result <= std_logic_vector(Sum_uns(7 downto 0));

	--Negations Flag-----------------------------------------------
	NZVC(3) <= Sum_uns(7);

	--Zero Flag ----------------------------------------------------
		if(Sum_uns(7 downto 0) = x"00") then
			NZVC(2) <= '1';
		else
			NZVC(2) <= '0';
		end if;
	-- Carry Flag (C) ---------------------------------------------
	NZVC(0) <= Sum_uns(8);
	end if;
---------------------------------------------------------------------------------------------------
	if(ALU_Sel = "110") then -- AND
	
	Result <= A AND B;

	end if;
------------------------------------------------------------------------------------------------
	if(ALU_Sel = "111") then -- OR
	
	Result <= A OR B;

	end if;
------------------------------------------------------------------------------------------------


end process;
end architecture;