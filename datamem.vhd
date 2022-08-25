library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory IS
	port (
		clk: in std_logic;
		data: in std_logic_vector (31 downto 0);
		address: in std_logic_vector (7 downto 0);
		write_en: in std_logic;
		load_en: in std_logic;
		q: out std_logic_vector (31 downto 0):= x"00000000";
		probe_out: out std_logic_vector (31 downto 0)
	);
end data_memory;

architecture behav OF data_memory IS
   type mem is array(0 to 255) of std_logic_vector(31 downto 0);
   signal ram_block : mem:=(
		others => x"00000000"
	);
	signal probe_out_sig: std_logic_vector (31 downto 0);
	signal addr:integer:=0;
begin

	process (clk)
		begin
		if rising_edge(clk) then
				addr <= to_integer(unsigned(address));
			if (write_en = '1') then
				ram_block(to_integer(unsigned(address))) <= data;
			end if;
		end if;
	end process;			
	q <= ram_block(addr) when load_en = '1' else (others => 'X');
	probe_out <= ram_block(13);
end behav;
