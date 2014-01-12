library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.Types.all;
use work.BcdPack.all;

entity BCDTest is
	generic (
	Displays : positive := 8
	);
	port (
	Clk      : in bit1;
	--
	Segments : out word(8-1 downto 0);
	Display  : out word(Displays-1 downto 0)
	);
end entity;

architecture rtl of BCDTest is
	constant Freq : positive := 50000000;
	signal ClkCnt_N, ClkCnt_D : word(bits(freq)-1 downto 0);
	signal Tick : bit1;
	signal Nbr_N, Nbr_D : word(4-1 downto 0);
	--
	signal DispCnt_N, DispCnt_D : word(bits(Displays)-1 downto 0);

begin
	ClkCntAsync : process (ClkCnt_D)
	begin
		ClkCnt_N <= ClkCnt_D + 1;
		Tick <= '0';
		if ClkCnt_D = Freq then
			ClkCnt_N <= (others => '0');
			Tick <= '1';
		end if;
	end process;
	
	ClkCntSync : process (Clk)
	begin
		if rising_edge(Clk) then
			ClkCnt_D <= ClkCnt_N;
		end if;
	end process;
	
	NbrAsync : process (Nbr_D, Tick)
	begin
		Nbr_N <= Nbr_D;
		if (Tick = '1') then
			if Nbr_D = 9 then
				Nbr_N <= (others => '0');
			else
				Nbr_N <= Nbr_D + 1;
			end if;
		end if;
	end process;

	NbrSync : process (Clk)
	begin
		if rising_edge(Clk) then
			Nbr_D <= Nbr_N;
		end if;
	end process;
	Segments <= BcdArray(conv_integer(Nbr_D));
	
	DispCntAsync : process (DispCnt_D)
	begin
		DispCnt_N <= DispCnt_D + 1;
	end process;
	
	DispCntSync : process (Clk)
	begin
		if rising_edge(Clk) then
			DispCnt_D <= DispCnt_N;
		end if;
	end process;
	Display <= SHL(xt1(Displays-1) & "0", DispCnt_D);

end architecture rtl;