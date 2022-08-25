library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
	port (
		ALUop_in: in std_logic_vector (4 downto 0);
		operand_a: in std_logic_vector (31 downto 0);
		operand_b: in std_logic_vector (31 downto 0);
		result_out: out std_logic_vector (31 downto 0)
	);
end alu;

architecture behav of alu is
	signal lt, eq, neq, gt, lt_u, gt_u: std_logic_vector (31 downto 0);
begin
	
	process (operand_a, operand_b, ALUop_in, lt, eq, neq, gt, lt_u, gt_u) 
	begin
		case ALUop_in is
			when "00000" => result_out <= std_logic_vector(unsigned(operand_a) + unsigned(operand_b));
			when "00001" => result_out <= std_logic_vector(shift_left((unsigned(operand_a)), to_integer(unsigned(operand_b(4 downto 0)))));
			when "00010" => result_out <= lt;
			when "00011" => result_out <= lt_u;
			when "00100" => result_out <= operand_a xor operand_b;
			when "00101" => result_out <= std_logic_vector(shift_right((unsigned(operand_a)), to_integer(unsigned(operand_b(4 downto 0)))));
			when "00110" => result_out <= operand_a or operand_b;
			when "00111" => result_out <= operand_a and operand_b;
			when "01000" =>	result_out <= std_logic_vector(unsigned(operand_a) - unsigned(operand_b));
			when "01101" => result_out <= std_logic_vector(shift_right((signed(operand_a)), to_integer(unsigned(operand_b(4 downto 0)))));
			when "10000" => result_out <= eq;
			when "10001" => result_out <= neq;
			when "10100" => result_out <= lt;
			when "10101" => result_out <= eq or gt;
			when "10110" => result_out <= lt_u;
			when "10111" => result_out <= eq or gt_u;
			when "11111" => result_out <= operand_a;
			when others => result_out <= (others => 'X');
		end case;
	end process;
	
	lt <= x"00000001" when (signed(operand_a) < signed (operand_b)) else x"00000000";
	eq <= x"00000001" when (signed(operand_a) = signed (operand_b)) else x"00000000";
	neq <= x"00000000" when (signed(operand_a) /= signed (operand_b)) else x"00000001";
	gt <= x"00000001" when (signed(operand_a) > signed (operand_b)) else x"00000000";
	lt_u <= x"00000001" when (unsigned(operand_a) < unsigned (operand_b)) else x"00000000";
	gt_u <= x"00000001" when (unsigned(operand_a) > unsigned (operand_b)) else x"00000000";
end behav;


