library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sevenseg is
	port (
		clk: in std_logic;
		data_in: in std_logic_vector (31 downto 0);
		seg: out std_logic_vector (7 downto 0);
		dig: out std_logic_vector (3 downto 0)
	);
end sevenseg;

architecture behav of sevenseg is 
	signal count, count_dig: integer :=1;
	signal tmp_dig: std_logic_vector (1 downto 0) := "00";
	signal tmp: std_logic := '0';
	signal display_data: std_logic_vector (3 downto 0) := x"0";
begin

	process (clk)
	begin
		if rising_edge(clk) then 
			count <= count+1;
			count_dig <= count_dig+1;
			if (count_dig = 250000) then
				tmp_dig <= std_logic_vector(unsigned(tmp_dig)+to_unsigned(1,2));
				count_dig <= 1;
			end if;
			if (count = 25000000) then
				tmp <= not tmp;
				count <= 1;
			end if;
		end if;
	end process;
	
	dig <= "1110" when tmp_dig = "00" else "1101" when tmp_dig = "01" else "1011" when tmp_dig = "10" else "0111" when tmp_dig = "11" else "1111";
	display_data <= data_in(3 downto 0) when tmp_dig = "00" else data_in(7 downto 4) when tmp_dig = "01" else data_in(11 downto 8) when tmp_dig = "10" else data_in(15 downto 12) when tmp_dig = "11" else "1111";

	process (display_data)
	begin
		case display_data is
			when x"0" => seg <= x"c0";
			when x"1" => seg <= x"f9";
			when x"2" => seg <= x"a4";
			when x"3" => seg <= x"b0";
			when x"4" => seg <= x"99";
			when x"5" => seg <= x"92";
			when x"6" => seg <= x"82";
			when x"7" => seg <= x"f8";
			when x"8" => seg <= x"80";
			when x"9" => seg <= x"90";
			when x"a" => seg <= x"88";
			when x"b" => seg <= x"83";
			when x"c" => seg <= x"c6";
			when x"d" => seg <= x"a1";
			when x"e" => seg <= x"86";
			when x"f" => seg <= x"8e";
			when others => seg <= x"ff";
		end case;
	end process;
end behav;