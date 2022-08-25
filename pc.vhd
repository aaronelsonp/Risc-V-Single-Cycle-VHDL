library ieee;
use ieee.std_logic_1164.all;

entity program_counter is
	port (
		clr, clk: in std_logic;
		address_in: in std_logic_vector(31 downto 0);
		address_out: out std_logic_vector(31 downto 0)
	);
end program_counter;

architecture behav of program_counter is
begin
	process (clk, clr) 
	begin
		if (clr = '1') then
			address_out <= (others => '0');
		elsif rising_edge(clk) then
			address_out <= address_in;
		end if;
	end process;
end behav;