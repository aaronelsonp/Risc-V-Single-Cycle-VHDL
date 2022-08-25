library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity progmem IS
	port
	(
		address: in std_logic_vector (29 downto 0);
		clk: in std_logic  := '1';
		instruction_out: out std_logic_vector (31 downto 0)
	);
end progmem;


architecture behav of progmem is
	type rom_type is array (0 to 255) of std_logic_vector (31 downto 0);
	signal ROM : rom_type:=(
		-- Example program
		x"00000000",
		x"000027b7",
		x"70f78513",
		x"00100313",
		x"00000293",
		x"006283b3",
		x"00a3de63",
		x"02702a23",
		x"02602823",
		x"03002283",
		x"02702823",
		x"03002303",
		x"fe5ff0ef",
		x"000000ef",
		others => x"00000000"
	);
begin
	instruction_out <= ROM(to_integer(unsigned(address)));
end behav;