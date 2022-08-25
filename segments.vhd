library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity segments_controller is
	port (
		clk: in std_logic;
		seg: out std_logic_vector (7 downto 0);
		dig: out std_logic_vector (3 downto 0)
	);
end segments_controller;

architecture behav of segments_controller is 
	signal count: integer :=1;
	signal tmp: std_logic := '0';
	signal display_data: std_logic_vector (3 downto 0) := x"0";
begin
	process (clk)
	begin
		if rising_edge(clk) then 
			count <= count+1;
			if (count = 25000000) then
			tmp <= not tmp;
			count <= 1;
			end if;
		end if;
	end process;
	
	dig <= x"0";
	
	process (tmp)
	begin
		if rising_edge (tmp) then
			display_data <= std_logic_vector(unsigned(display_data)+to_unsigned(1,4));
		end if;
	end process;
	
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
			when x"f" => seg <= x"83";
			when others => seg <= x"ff";
		end case;
	end process;
end behav;
