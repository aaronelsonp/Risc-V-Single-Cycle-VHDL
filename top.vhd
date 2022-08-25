library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
	port (
		clr_in: in std_logic;
		clk_in: in std_logic;
		read_en: in std_logic;
		seg: out std_logic_vector (7 downto 0);
		dig: out std_logic_vector (3 downto 0);
		tx_out: out std_logic;
		clk_speed_selector: in std_logic
	);
end top;

architecture behav of top is
	component program_counter is
		port (
			clr, clk: in std_logic;
			address_in: in std_logic_vector(31 downto 0);
			address_out: out std_logic_vector(31 downto 0)
		);
	end component program_counter;
	
	component alu is
	port (
		ALUop_in: in std_logic_vector (4 downto 0);
		operand_a: in std_logic_vector (31 downto 0);
		operand_b: in std_logic_vector (31 downto 0);
		result_out: out std_logic_vector (31 downto 0)
	);
	end component alu;
	
	component control_unit is
	port (
		opcode:in std_logic_vector(6 downto 0);
		mem_write, branch, reg_write, mem_to_reg, load_en: out std_logic;
		ALU_op:out std_logic_vector(2 downto 0);
		operand_a_sel:out std_logic_vector (1 downto 0);
		operand_b_sel:out std_logic;
		extend_sel, next_pc_sel:out std_logic_vector (1 downto 0)
	);
	end component control_unit;
	
	component progmem IS
	port
	(
		address: in std_logic_vector (29 downto 0);
		clk: in std_logic  := '1';
		instruction_out: out std_logic_vector (31 downto 0)
	);
	end component progmem;
	
	component immediate_generator is
	port (
		inst: in std_logic_vector(31 downto 0);
		s_type_out: out std_logic_vector(31 downto 0);
		sb_type_out: out std_logic_vector(31 downto 0);
		u_type_out: out std_logic_vector(31 downto 0);
		uj_type_out: out std_logic_vector(31 downto 0);
		i_type_out: out std_logic_vector(31 downto 0)
	);
	end component immediate_generator;
	
	component register_files is
	port (
		write_en, clk: in std_logic;
		read_address_1: in std_logic_vector(4 downto 0);
		read_address_2: in std_logic_vector(4 downto 0);
		write_address: in std_logic_vector(4 downto 0);
		write_data: in std_logic_vector(31 downto 0);
		data_out_1: out std_logic_vector(31 downto 0);
		data_out_2: out std_logic_vector(31 downto 0)
	);
	end component register_files;
	
	component alu_controller is
	port (
		ALUop_in: in std_logic_vector (2 downto 0);
		funct7: in std_logic;
		funct3: in std_logic_vector (2 downto 0);
		ALUop_out: out std_logic_vector (4 downto 0)
	);
	end component alu_controller;
	
	component data_memory IS
	port (
		clk: in std_logic;
		data: in std_logic_vector (31 downto 0);
		address: in std_logic_vector (7 downto 0);
		write_en: in std_logic;
		load_en: in std_logic;
		q: out std_logic_vector (31 downto 0);
		probe_out: out std_logic_vector(31 downto 0)
	);
	end component data_memory;
	
	component sevenseg is
	port (
		clk: in std_logic;
		data_in: in std_logic_vector (31 downto 0);
		seg: out std_logic_vector (7 downto 0);
		dig: out std_logic_vector (3 downto 0)
	);
	end component sevenseg;
	
	component bin2bcd is
	 port ( 
		  input:      in   std_logic_vector (15 downto 0);
		  ones:       out  std_logic_vector (3 downto 0);
		  tens:       out  std_logic_vector (3 downto 0);
		  hundreds:   out  std_logic_vector (3 downto 0);
		  thousands:  out  std_logic_vector (3 downto 0)
	 );
	end component bin2bcd;
	
	component hex2ascii is
	port(
		input: in std_logic_vector (3 downto 0);
		output: out std_logic_vector (7 downto 0);
		next_out: in std_logic
	);
	end component hex2ascii;
	
	component UART_TX is
		generic (
		 g_CLKS_PER_BIT : integer := 217     -- Needs to be set correctly
		 );
		port (
		 i_Clk       : in  std_logic;
		 i_TX_DV     : in  std_logic;
		 i_TX_Byte   : in  std_logic_vector(7 downto 0);
		 o_TX_Active : out std_logic;
		 o_TX_Serial : out std_logic;
		 o_TX_Done   : out std_logic
		 );
	end component UART_TX;
	
	component fifo is
	Generic (
		constant DATA_WIDTH  : positive := 32;
		constant FIFO_DEPTH	: positive := 256
	);
	Port ( 
		CLK		: in  STD_LOGIC;
		RST		: in  STD_LOGIC;
		WriteEn	: in  STD_LOGIC;
		DataIn	: in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		ReadEn	: in  STD_LOGIC;
		DataOut	: out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		Empty	: out STD_LOGIC;
		Full	: out STD_LOGIC
	);
	end component fifo;

	component fifo32to4 is
		Port ( 
			clk		: in  std_logic;
			clr		: in  std_logic;
			datain_32: in  std_logic_vector (31 downto 0);
			NextWordReadEn	: in  std_logic;
			WriteEn: in std_logic;
			dataout	: out std_logic_vector (3 downto 0);
			nextout: out std_logic;
			readnext: out std_logic;
			datavalid: out std_logic
		);
	end component fifo32to4;
	
	component validchecker is
	Port ( 
		clk		: in  std_logic;
		clr		: in  std_logic;
		datavalidin: in std_logic;
		txactive: in std_logic;
		validout: out std_logic;
		nextwordreaden_sig: out std_logic; 
		tx_done_sig: in std_logic;
		tx_active_sig: in std_logic;
		read_next_sig: in std_logic;
		fifo_valid_sig: in std_logic;
		fifo32_4_writeen_sig: out std_logic;
		fifo_read_next: out std_logic;
		fifo_readen_sig: in std_logic
	);
	end component validchecker;
	
	 
	component Debounce_Switch is
	  port (
		 i_Clk    : in  std_logic;
		 i_Switch : in  std_logic;
		 o_Switch : out std_logic
		 );
	end component Debounce_Switch;
 
	
	signal clr: std_logic := '1';
	signal clk, clk2, clk3, clk4, clk_fifo: std_logic := '0';
	signal count, count2, count3, count4: integer := 1;
	signal pc_in_sig: std_logic_vector (31 downto 0) := x"00000000"; --pc
	signal pc_out_sig: std_logic_vector (31 downto 0) := x"00000000"; --pc
	signal instruction: std_logic_vector (31 downto 0); --pc
	signal s_type_sig, sb_type_sig, u_type_sig, uj_type_sig, i_type_sig, immgen_mux_sig: std_logic_vector (31 downto 0); --immgen
	signal write_data_sig, data_out_1_sig, data_out_2_sig: std_logic_vector (31 downto 0); --regfiles
	signal reg_write_en_sig, branch_sig, mem_write_sig, mem_to_reg_sig, operand_b_sel_sig, load_en_sig: std_logic; --ctrl unit
	signal ALUop_sig: std_logic_vector (2 downto 0); --ctrl unit
	signal operand_a_sel_sig, extend_sel_sig, next_pc_sel_sig: std_logic_vector (1 downto 0); --ctrl unit
	signal ALUop_in_sig: std_logic_vector (4 downto 0); --alu
	signal ALU_branch_sig: std_logic; --alu
	signal operand_a_sig, operand_b_sig, result_sig: std_logic_vector (31 downto 0); --alu
	signal data_memory_out_sig, probe_out_sig: std_logic_vector (31 downto 0); --datamem
	signal jump_sig, jalr_sig: std_logic_vector (31 downto 0); -- jump target
	signal bcd_sig: std_logic_vector (31 downto 0); -- binary to bcd for 7-segments
	signal ones_sig, tens_sig, hundreds_sig, thousands_sig: std_logic_vector(3 downto 0); --binary to bcd for 7-segments
	signal fifo_writeen_sig, fifo_readen_sig, fifo_empty_sig, fifo_empty_sig_r, fifo_full_sig, fifo_valid_sig, fifo_read_next: std_logic; --fifo
	signal fifo_data_out_sig: std_logic_vector(31 downto 0); -- fifo
	signal nextwordreaden_sig, fifo32_4_writeen_sig, next_out_sig: std_logic; --fifo 32 to 4
	signal read_next_sig: std_logic; -- fifo 32 to 4
	signal fifo_4_out_sig: std_logic_vector (3 downto 0); --fifo 32 to 4
	signal asciiout_sig: std_logic_vector (7 downto 0); -- hex2ascii
	signal dv_clr, datavalid_sig: std_logic; -- datavalid checker
	signal datavalid_tx_sig, tx_dv_sig, tx_active_sig, tx_done_sig: std_logic; -- uart tx8
	signal read_en_debounced : std_logic; -- debounce
	
begin
	clr <= not clr_in;
	process (clk_in)
		begin
		if rising_edge(clk_in) then 
			count <= count+1;
			if (count = 250000/1024) then
				clk <= not clk;
				count <= 1;
			end if;
		end if;
	end process;
	
	process (clk_in)
		begin
		if rising_edge(clk_in) then 
			count2 <= count2+1;
			if (count2 = 2) then
				clk2 <= not clk2;
				count2 <= 1;
			end if;
		end if;
	end process;
	
	process (clk_in)
		begin
		if rising_edge(clk_in) then 
			count3 <= count3+1;
			if (count3 = 1) then
				clk3 <= not clk3;
				count3 <= 1;
			end if;
		end if;
	end process;
	
 	process (clk_in)
		begin
		if rising_edge(clk_in) then 
			count4 <= count4+1;
			if (count4 = 25000000/1024) then
				clk4 <= not clk4;
				count4 <= 1;
			end if;
		end if;
	end process;
	
	Debounce_Inst: Debounce_Switch port map (clk_in,read_en,read_en_debounced);
	hex2ascii1: hex2ascii port map (fifo_4_out_sig, asciiout_sig, next_out_sig);
	fifo32to4_1: fifo32to4 port map (clk2, dv_clr, fifo_data_out_sig, nextwordreaden_sig, fifo32_4_writeen_sig, fifo_4_out_sig, next_out_sig, read_next_sig, datavalid_sig);
	fifo1: fifo port map (clk_fifo, clr, fifo_writeen_sig, data_out_2_sig, fifo_readen_sig, fifo_data_out_sig, fifo_empty_sig, fifo_full_sig);
	tx1: uart_tx port map (clk3, tx_dv_sig, asciiout_sig, tx_active_sig, tx_out, tx_done_sig);
	validchecker1: validchecker port map (clk3, dv_clr, datavalid_sig, tx_active_sig, datavalid_tx_sig, nextwordreaden_sig, tx_done_sig, tx_active_sig, read_next_sig, fifo_valid_sig, fifo32_4_writeen_sig, fifo_read_next, fifo_readen_sig);
	sevenseg1: sevenseg port map (clk_in, bcd_sig, seg, dig);
	pc1: program_counter port map (clr, clk, pc_in_sig, pc_out_sig);
	inst1: progmem port map (pc_out_sig(31 downto 2), clk, instruction);
	immgen1: immediate_generator port map (instruction, s_type_sig, sb_type_sig, u_type_sig, uj_type_sig, i_type_sig);
	regfiles1: register_files port map (reg_write_en_sig, clk, instruction(19 downto 15), instruction(24 downto 20), instruction(11 downto 7), write_data_sig, data_out_1_sig, data_out_2_sig);
	aluctrl1: alu_controller port map (ALUop_sig, instruction(30), instruction(14 downto 12), ALUop_in_sig);
	alu1: alu port map (ALUop_in_sig, operand_a_sig, operand_b_sig, result_sig);
	ctrl1: control_unit port map (instruction(6 downto 0), mem_write_sig, branch_sig, reg_write_en_sig, mem_to_reg_sig, load_en_sig, ALUop_sig, operand_a_sel_sig, operand_b_sel_sig, extend_sel_sig, next_pc_sel_sig);
	datamem1: data_memory port map (clk, data_out_2_sig, result_sig(9 downto 2), mem_write_sig, load_en_sig, data_memory_out_sig, probe_out_sig);
	bin2bcd1: bin2bcd port map (probe_out_sig(15 downto 0), ones_sig, tens_sig, hundreds_sig, thousands_sig);
	
	bcd_sig <= x"0000"&thousands_sig&hundreds_sig&tens_sig&ones_sig;
	
	fifo_writeen_sig <= '1' when (mem_write_sig and (not fifo_full_sig or fifo_empty_sig)) = '1' and result_sig(9 downto 2) = x"0d" else '0';
	
	clk_fifo <= clk4 when clk_speed_selector = '1' else clk;
	
	fiforeaden:process(clk)
	begin
		if rising_edge (clk) then
			fifo_readen_sig <= fifo_read_next and read_en_debounced and (not fifo_empty_sig_r);
		end if;
	end process;
	tx_dv_sig <= datavalid_tx_sig and read_en_debounced
	;
	dv_clr <= clr or not read_en_debounced;
	
	fifoemptyregister:process(clk)
	begin
		if rising_edge (clk) then
			fifo_empty_sig_r <= fifo_empty_sig;
		end if;
	end process;


	fifo_valid_sig <= read_en_debounced and fifo_readen_sig;

		
	pc_mux: 
		with next_pc_sel_sig select pc_in_sig <=
			std_logic_vector(unsigned(pc_out_sig) + to_unsigned(4, 32)) when "00",
			jump_sig when "01",
			std_logic_vector(unsigned(uj_type_sig) + unsigned(pc_out_sig)) when "10",
			jalr_sig when "11",
			(others => 'X') when others;
			
	alu_operand_a_mux:
		with operand_a_sel_sig select operand_a_sig <=
			data_out_1_sig when "00",
			pc_out_sig when "01",
			std_logic_vector(unsigned(pc_out_sig) + to_unsigned(4, 32)) when "10",
			data_out_1_sig when "11",
			(others => 'X') when others;
			
	alu_operand_b_mux:
		with operand_b_sel_sig select operand_b_sig <=
			data_out_2_sig when '0',
			immgen_mux_sig when '1',
			(others => 'X') when others;

	immgen_mux:
		with extend_sel_sig select immgen_mux_sig <=
			i_type_sig when "00",
			u_type_sig when "01",
			s_type_sig when "10",
			(others => 'X') when others;
	
	mem_to_reg_mux:
		with mem_to_reg_sig select write_data_sig <=
			result_sig when '0',
			data_memory_out_sig when '1',
			(others => 'X') when others;
			
	jalr_target:
		jalr_sig <= std_logic_vector(unsigned(data_out_1_sig) + unsigned(immgen_mux_sig)) and x"fffffffc";
		
	jump_target:
		ALU_branch_sig <= '1' when (ALUop_in_sig(4 downto 3) = "10") and (result_sig = x"00000001") else '0';
		with ALU_branch_sig and branch_sig select jump_sig <=
			std_logic_vector(unsigned(pc_out_sig) + to_unsigned(4, 32)) when '0',
			std_logic_vector(unsigned(sb_type_sig) + unsigned(pc_out_sig)) when '1',
			(others => 'X') when others;
end behav;
