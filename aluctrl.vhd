library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_controller is
	port (
		ALUop_in: in std_logic_vector (2 downto 0);
		funct7: in std_logic;
		funct3: in std_logic_vector (2 downto 0);
		ALUop_out: out std_logic_vector (4 downto 0)
	);
end alu_controller;

architecture behav of alu_controller is 
begin
	process (ALUop_in, funct7, funct3) 
	begin
		if ALUop_in = "011" then
			ALUop_out <= '1'&x"f";
		elsif ALUop_in = "010" then
			ALUop_out <= "10"&funct3;
		elsif ALUop_in = "000" and funct7 = '0' then
			ALUop_out <= "00"&funct3;
		elsif ALUop_in = "000" and funct7 = '1' then
			ALUop_out <= "01"&funct3;
		elsif ALUop_in = "000" then
			ALUop_out <= "00"&funct3;
		elsif ALUop_in = "001" and funct7 = '0' and funct3 = "101" then
			ALUop_out <= "00"&funct3;
		elsif ALUop_in = "001" and funct7 = '1' and funct3 = "101" then
			ALUop_out <= "01"&funct3;
		elsif ALUop_in = "001" and funct3 = "101" then
			ALUop_out <= "00"&funct3;
		elsif ALUop_in = "001" then
			ALUop_out <= "00"&funct3;
		else
			ALUop_out <= "00000";
		end if;
	end process;
end behav;
