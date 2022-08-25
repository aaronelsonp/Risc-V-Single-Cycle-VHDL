library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
	port (
		opcode:in std_logic_vector(6 downto 0);
		mem_write, branch, reg_write, mem_to_reg, load_en: out std_logic;
		ALU_op:out std_logic_vector(2 downto 0);
		operand_a_sel:out std_logic_vector (1 downto 0);
		operand_b_sel:out std_logic;
		extend_sel, next_pc_sel:out std_logic_vector (1 downto 0)
	);
end control_unit;

architecture behav of control_unit is
	signal r_type, load_type, store_type, branch_type, i_type, jalr_type, jal_type, lui_type: std_logic; 
begin
	type_decode:
		r_type <= '1' when opcode = "0110011" else '0';
		load_type <= '1' when opcode = "0000011" else '0';
		store_type <= '1' when opcode = "0100011" else '0';
		branch_type <= '1' when opcode = "1100011" else '0';
		i_type <= '1' when opcode = "0010011" else '0';
		jalr_type <= '1' when opcode = "1100111" else '0';
		jal_type <= '1' when opcode = "1101111" else '0';
		lui_type <= '1' when opcode = "0110111" else '0';
		
	control_decode:
		mem_write <= store_type;
		branch <= branch_type;
		reg_write <= r_type or load_type or i_type or lui_type or jal_type or jalr_type;
		mem_to_reg <= load_type;
		ALU_op <= not (r_type or branch_type or i_type or jal_type or jalr_type) & not(r_type or load_type or store_type or i_type) & not(r_type or load_type or branch_type or lui_type);
		operand_a_sel <= "11" when lui_type = '1' else "10" when jalr_type = '1' else "10" when jal_type = '1' else "00";
		operand_b_sel <= lui_type or store_type or load_type or i_type;
		extend_sel <= store_type&lui_type;
		load_en <= load_type;
		next_pc_sel <= "01" when branch_type = '1' else "10" when jal_type = '1' else "11" when jalr_type = '1' else "00";
end behav;
