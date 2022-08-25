library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hex2ascii is
port(
	input: in std_logic_vector (3 downto 0);
	output: out std_logic_vector (7 downto 0);
	next_out: in std_logic
);
end hex2ascii;

architecture behav of hex2ascii is
begin
	process(input, next_out)
	begin
		if next_out = '0' then 
			case input is
				when x"0" => output <= x"30";
				when x"1" => output <= x"31";
				when x"2" => output <= x"32";
				when x"3" => output <= x"33";
				when x"4" => output <= x"34";
				when x"5" => output <= x"35";
				when x"6" => output <= x"36";
				when x"7" => output <= x"37";
				when x"8" => output <= x"38";
				when x"9" => output <= x"39";
				when x"a" => output <= x"41";
				when x"b" => output <= x"42";
				when x"c" => output <= x"43";
				when x"d" => output <= x"44";
				when x"e" => output <= x"45";
				when x"f" => output <= x"46";
				when others => output <= (others => 'X');
			end case;
		elsif next_out = '1' then
			output <= x"0a";
		else
			output <= (others => 'X');
		end if;
	end process;
end behav;