----------------------------------------------------------------------------------
-- Company:  FE, 2014
-- Engineer: A. Trost
-- 
-- Create Date: 09/12/2013 04:06:56 PM
-- Design Name: VGA, 800x600, 72 Hz
--  clk50 50MHz
-- 
-- Revision: 1.0
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA is
    Port ( 	clk : in STD_LOGIC;
			hsync : out STD_LOGIC;
			vsync : out STD_LOGIC;
			x,y: out unsigned(11 downto 0)
		  );
end VGA;

architecture Behavioral of VGA is

	signal hst, vst: unsigned (11 downto 0);

begin
p:process (clk, hst, vst)
begin
if rising_edge(clk) then
  if hst < "010000001111" then 			-- hst < 1039   	
    hst <= hst + 1;						-- hst++
  else
    hst <= (others=>'0');				-- hst = 0
		if vst < "001010011001" then  	-- vst < 665
    vst <= vst + 1;						-- vst++
		else
    vst <= (others=>'0');				-- vst = 0
    end if;
  end if;
end if;
end process;
hsync <= '1' when hst>=856 and hst<856+120 else '0';	-- hsync=1 kadar je hst med 856 in 976
vsync <= '1' when vst>=637 and vst<637+6 else '0';		-- vsync=1 kadat je vst med 637 in 643

x <= hst;	--	x = hst
y <= vst;	--	y = vst

end Behavioral;
