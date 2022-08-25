library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity fifo32to4 is
	Port ( 
		clk		: in  std_logic;
		clr		: in  std_logic;
		datain_32: in  std_logic_vector (31 downto 0);
		NextWordReadEn	: in  std_logic;
		WriteEn: in std_logic;
		dataout	: out std_logic_vector (3 downto 0);
		nextout: out std_logic;
		readnext: out std_logic := '1';
		datavalid: out std_logic
	);
end fifo32to4;

architecture Behavioral of fifo32to4 is
	signal DataIn32_sig: std_logic_vector (31 downto 0);
	type t_State is (readWords, nibble8, nibble7, nibble6, nibble5, nibble4, nibble3, nibble2, nibble1, nextline, waitline);
   signal State : t_State := readWords;
	signal datavalid_sig: std_logic;
	signal dataout_sig: std_logic_vector (3 downto 0);
begin
	process(CLK) is
	begin
		if rising_edge(CLK) then
			if clr = '1' then
				State <= readWords;
				nextout <= '0';
				readnext <= '1';
			else
				case State is
					when readWords =>
						nextout <= '0';
						readnext <= '1';
						if WriteEn = '1' then
							DataIn32_sig <= DataIn_32;
							State <= nibble8;	
							readnext <= '0';
						end if;
					when nibble8=> 
						if NextWordReadEn = '1' then
							dataout_sig <= DataIn32_sig(31 downto 28);
							datavalid_sig <= '1';
							State <= nibble7;
						else
							datavalid_sig <= '0';
						end if;
						
					when nibble7=> 
						if NextWordReadEn = '1' then
							dataout_sig <= DataIn32_sig(27 downto 24);
							datavalid_sig <= '1';
							State <= nibble6;
						else
							datavalid_sig <= '0';
						end if;
						
					when nibble6=>
						if NextWordReadEn = '1' then
							dataout_sig <= DataIn32_sig(23 downto 20);
							datavalid_sig <= '1';
							State <= nibble5;
						else
							datavalid_sig <= '0';
						end if;
						
					when nibble5=> 
						if NextWordReadEn = '1' then
							dataout_sig <= DataIn32_sig(19 downto 16);
							datavalid_sig <= '1';
							State <= nibble4;
						else
							datavalid_sig <= '0';
						end if;
					when nibble4=> 
						if NextWordReadEn = '1' then
							dataout_sig <= DataIn32_sig(15 downto 12);
							datavalid_sig <= '1';
							State <= nibble3;
						else
							datavalid_sig <= '0';
						end if;
					when nibble3=> 
						if NextWordReadEn = '1' then
							dataout_sig <= DataIn32_sig(11 downto 8);
							datavalid_sig <= '1';
							State <= nibble2;
						else
							datavalid_sig <= '0';
						end if;
					when nibble2=> 
						if NextWordReadEn = '1' then
							dataout_sig <= DataIn32_sig(7 downto 4);
							datavalid_sig <= '1';
							State <= nibble1;
						else
							datavalid_sig <= '0';
						end if;
					when nibble1=> 
						if NextWordReadEn = '1' then
							datavalid_sig <= '1';
							dataout_sig <= DataIn32_sig(3 downto 0);
							State <= nextline;
						else
							datavalid_sig <= '0';
						end if;
					when nextline => 
						if NextWordReadEn = '1' then
							datavalid_sig <= '1';
							nextout <= '1';
							State <= waitline;	
						else
							datavalid_sig <= '0';
						end if;
					when waitline =>
						if NextWordReadEn = '1' then
							datavalid_sig <= '0';
							readnext <= '1';
							State <= readWords;
						else
							datavalid_sig <= '0';
						end if;
				end case;
			end if;
		end if;
	end process;
	dataout <= dataout_sig;
	datavalid <= datavalid_sig;
	
end Behavioral;
