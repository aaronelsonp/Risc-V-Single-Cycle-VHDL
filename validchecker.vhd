library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity validchecker is
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
end validchecker;

architecture Behavioral of validchecker is
	signal DataIn32_sig: std_logic_vector (31 downto 0);
	type t_State is (idle, transfer, waitnext);
	type readen_State is (readenable, readdisable);
	type writeen_State is (writeenable, writedisable);
	type fifo_readen_State is (fiforeadenable, fiforeaddisable);
	
	signal fifo_read_State: fifo_readen_State := fiforeaddisable;
	signal write_State: writeen_State := writeenable;
	signal read_State: readen_State := readenable;
	signal State : t_State := idle;
	signal validout_sig: std_logic;
begin
	process (CLK) is
	begin
		if rising_edge(CLK) then
			if clr = '1' then
				fifo_read_State <= fiforeadenable;
				fifo_read_next <= '1';
			else
				case fifo_read_State is
					when fiforeadenable =>
						if fifo_readen_sig = '1' then
							fifo_read_next <= '0';
							fifo_read_State <= fiforeaddisable;
						end if;
						fifo_read_next <= '1';
					when fiforeaddisable =>
						if fifo_readen_sig = '0' then
							fifo_read_next <= read_next_sig;
							fifo_read_State <= fiforeadenable;
						end if;
						fifo_read_next <= '0';
				end case;
			end if;
		end if;
	end process;
	
	process (CLK) is
	begin
		if rising_edge(CLK) then
			if clr = '1' then
				write_State <= writeenable;
				fifo32_4_writeen_sig <= fifo_valid_sig;
			else
				case write_State is
					when writeenable =>
						if read_next_sig = '0'  then 
							fifo32_4_writeen_sig <= '0';
							write_State <= writedisable;
						end if;
						fifo32_4_writeen_sig <= fifo_valid_sig;
					when writedisable =>
						if fifo_valid_sig = '0' then 
							fifo32_4_writeen_sig <= fifo_valid_sig;
							write_State <= writeenable;
						end if;
						fifo32_4_writeen_sig <= '0';
				end case;
			end if;
		end if;
	end process;
	
	process (CLK) is
	begin
		if rising_edge(CLK) then
			if clr = '1' then
				read_State <= readenable;
				nextwordreaden_sig <= '1';
			else
				case read_State is
					when readenable =>
						if (datavalidin = '1' or tx_active_sig = '1')
						then 
							read_State <= readdisable;
							nextwordreaden_sig <= '0';
						end if;
						nextwordreaden_sig <= '1';
					when readdisable =>
						if (tx_done_sig = '1' and tx_active_sig = '0')
						then 
							read_State <= readenable;
							nextwordreaden_sig <= '1';
						end if;
						nextwordreaden_sig <= '0';
				end case;
			end if;
		end if;
	end process;
	
	process(CLK) is
	begin
		if rising_edge(CLK) then
			if clr = '1' then
				State <= idle;
				validout_sig <= '0';
			else
				case State is
					when idle => 
						validout_sig <= '0';
						if datavalidin = '1' then
							State <= transfer;
						end if;
					when transfer => 
						validout_sig <= '1';
						if txactive = '1' then
							State <= waitnext;
						end if;
					when waitnext => 
						validout_sig <= '0';
						if datavalidin = '0' then 
							State <= idle;
						end if;
				end case;
			end if;
		end if;
	end process;
	validout <= validout_sig;
	
end Behavioral;
