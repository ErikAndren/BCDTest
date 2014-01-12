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
	--
	signal ClkCnt_N, ClkCnt_D : word(bits(freq)-1 downto 0);
	signal Tick : bit1;
	--
	signal CntVal_N, CntVal_D : word(8-1 downto 0);
	signal CntValBcd : word(16-1 downto 0);
	signal CurSeg : word(4-1 downto 0);

begin
	ClkCntAsync : process (ClkCnt_D)
	begin
		CntVal_N <= CntVal_D;
		ClkCnt_N <= ClkCnt_D + 1;
		Tick <= '0';
		if ClkCnt_D = Freq then
			ClkCnt_N <= (others => '0');
			Tick <= '1';
			CntVal_N <= CntVal_D + 1;
		end if;
	end process;
	
	ClkCntSync : process (Clk)
	begin
		if rising_edge(Clk) then
			ClkCnt_D <= ClkCnt_N;
			CntVal_D <= CntVal_N;
		end if;
	end process;
	CntValBcd <= to_bcd(CntVal_D(8-1 downto 0));
	CurSeg    <= ExtractSlice(xt0(16) & CntValBcd, 4, conv_integer(ClkCnt_D(17 downto 15)));
	--
	Segments  <= BcdArray(conv_integer(CurSeg));
	Display   <= not SHL(xt0(Displays-1) & '1', ClkCnt_D(17 downto 15));
end architecture rtl;