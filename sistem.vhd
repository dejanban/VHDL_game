----------------------------------------------------------------------------------
-- Company:  FE, 2015/2016
-- Engineer: A. Trost
-- 
-- Create Date: 17/11/2015
-- Design Name: Sistem z razsiritveno plosco, VGA
--  clk 50MHz
-- 
-- Revision: 2.0
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.sprites.all;

entity sistem is
	Port( clk : in STD_LOGIC;
			clkout : out STD_LOGIC; 				 -- signali V/I plošče
			addr : out STD_LOGIC_VECTOR(1 DOWNTO 0);
			data : inout STD_LOGIC_VECTOR(7 DOWNTO 0);
			key: in unsigned (1 downto 0);
			led: out unsigned (7 downto 0)
		 );
end sistem;

architecture opis of sistem is
-------------------------------------------------komponente---------------------
 component VGA is
  Port ( clk : in STD_LOGIC;					-- 50 MHz ura
         hsync : out  STD_LOGIC;				-- horizontalni in
         vsync : out  STD_LOGIC;				-- vertikalni sinhronizacijski pulz
         x,y: out unsigned(11 downto 0)	-- koordinate trenutne točke
		 );
 end component;
 
 component proc is
	port ( 
		clk  : in std_logic;
		reset: in std_logic;
		debug: in unsigned(2 downto 0);
		pc: out unsigned (7 downto 0);
		interrupt: in std_logic;
		start: in std_logic;
		pin: in unsigned (11 downto 0); -- vhodna vrata
		xzoge: in unsigned (11 downto 0);
		pout1, pout2: out unsigned (11 downto 0) -- izhodna vrata
	);
 end component;
 
 component vmesnik is
	Port(	clk : in std_logic;     
			hsync, vsync: in std_logic;   				-- signali VGA vmesnika
			rgb: in unsigned(5 downto 0);					-- barve VGA vmesnika (6-bit)
			num : in unsigned(3 downto 0);   			-- stevilo za izpis na LED (4-bit)
			key : out unsigned(3 downto 0); 				-- stanje tipk (4-bit)			
			clkout: out std_logic; 							-- signali razsiritvene plosce
			addr : out STD_LOGIC_VECTOR(1 downto 0);
			data : inout STD_LOGIC_VECTOR(7 downto 0);
			cpu_pc : in unsigned (7 downto 0);
			debug  : out unsigned(2 downto 0)
		 );
 end component;
 ------------------------------------------------------------
 signal st1: unsigned (16 downto 0);
 signal en: std_logic;
 signal hsync, vsync: std_logic;
 signal x,y: unsigned(11 downto 0); 
 signal num, keys: unsigned(3 downto 0);
 signal color: std_logic :='0';
 signal rgb: unsigned(5 downto 0);
 ---------- X PLOŠČKA
 signal xp: unsigned (11 downto 0);
 ---------- X IN Y ZOGE
 signal xz: unsigned (11 downto 0) := to_unsigned(13, 12);
 signal yz: unsigned (11 downto 0) := to_unsigned(550, 12);
 signal xzog: unsigned (11 downto 0);
 -----------zoga----------------------------------------------
 signal vrst: unsigned (29 downto 0);
 signal colorz: std_logic;
 signal smerz: std_logic:='1';
 -----------------tarca---------------------------------------
 signal tarca1: unsigned (78 downto 0);
 signal colorp1: std_logic:='0';
 signal ytarca1: unsigned (11 downto 0):=to_unsigned(30,12);
 signal xtarca1: unsigned (11 downto 0):=to_unsigned(5,12);
 -------------------------------------------------------------
 signal tarca2: unsigned (78 downto 0);
 signal colorp2: std_logic:='0';
 signal ytarca2: unsigned (11 downto 0):=to_unsigned(30,12);
 signal xtarca2: unsigned (11 downto 0):=to_unsigned(84,12);
 ------
 signal tarca3: unsigned (78 downto 0);
 signal colorp3: std_logic:='0';
 signal ytarca3: unsigned (11 downto 0):=to_unsigned(30,12);
 signal xtarca3: unsigned (11 downto 0):=to_unsigned(163,12);
 ------
 signal tarca4: unsigned (78 downto 0);
 signal colorp4: std_logic:='0';
 signal ytarca4: unsigned (11 downto 0):=to_unsigned(30,12);
 signal xtarca4: unsigned (11 downto 0):=to_unsigned(242,12);
 ------
 signal tarca5: unsigned (78 downto 0);
 signal colorp5: std_logic:='0';
 signal ytarca5: unsigned (11 downto 0):=to_unsigned(30,12);
 signal xtarca5: unsigned (11 downto 0):=to_unsigned(321,12);
 ------
 signal tarca6: unsigned (78 downto 0);
 signal colorp6: std_logic:='0';
 signal ytarca6: unsigned (11 downto 0):=to_unsigned(30,12);
 signal xtarca6: unsigned (11 downto 0):=to_unsigned(400,12);
 ------
 signal tarca7: unsigned (78 downto 0);
 signal colorp7: std_logic:='0';
 signal ytarca7: unsigned (11 downto 0):=to_unsigned(30,12);
 signal xtarca7: unsigned (11 downto 0):=to_unsigned(479,12);
 ------
 signal tarca8: unsigned (78 downto 0);
 signal colorp8: std_logic:='0';
 signal ytarca8: unsigned (11 downto 0):=to_unsigned(30,12);
 signal xtarca8: unsigned (11 downto 0):=to_unsigned(558,12);
 ------
 signal tarca9: unsigned (78 downto 0);
 signal colorp9: std_logic:='0';
 signal ytarca9: unsigned (11 downto 0):=to_unsigned(30,12);
 signal xtarca9: unsigned (11 downto 0):=to_unsigned(637,12);
 ------
 signal tarca10: unsigned (78 downto 0);
 signal colorp10: std_logic:='0';
 signal ytarca10: unsigned (11 downto 0):=to_unsigned(30,12);
 signal xtarca10: unsigned (11 downto 0):=to_unsigned(716,12);
 ------------------------------------------------------------
  -----------------tarca1---------------------------------------
 signal tarca11: unsigned (78 downto 0);
 signal colorp11: std_logic:='0';
 signal ytarca11: unsigned (11 downto 0):=to_unsigned(50,12);
 signal xtarca11: unsigned (11 downto 0):=to_unsigned(5,12);
 ------
 signal tarca12: unsigned (78 downto 0);
 signal colorp12: std_logic:='0';
 signal ytarca12: unsigned (11 downto 0):=to_unsigned(50,12);
 signal xtarca12: unsigned (11 downto 0):=to_unsigned(84,12);
 ------
 signal tarca13: unsigned (78 downto 0);
 signal colorp13: std_logic:='0';
 signal ytarca13: unsigned (11 downto 0):=to_unsigned(50,12);
 signal xtarca13: unsigned (11 downto 0):=to_unsigned(163,12);
 ------
 signal tarca14: unsigned (78 downto 0);
 signal colorp14: std_logic:='0';
 signal ytarca14: unsigned (11 downto 0):=to_unsigned(50,12);
 signal xtarca14: unsigned (11 downto 0):=to_unsigned(242,12);
 ------
 signal tarca15: unsigned (78 downto 0);
 signal colorp15: std_logic:='0';
 signal ytarca15: unsigned (11 downto 0):=to_unsigned(50,12);
 signal xtarca15: unsigned (11 downto 0):=to_unsigned(321,12);
 ------
 signal tarca16: unsigned (78 downto 0);
 signal colorp16: std_logic:='0';
 signal ytarca16: unsigned (11 downto 0):=to_unsigned(50,12);
 signal xtarca16: unsigned (11 downto 0):=to_unsigned(400,12);
 ------
 signal tarca17: unsigned (78 downto 0);
 signal colorp17: std_logic:='0';
 signal ytarca17: unsigned (11 downto 0):=to_unsigned(50,12);
 signal xtarca17: unsigned (11 downto 0):=to_unsigned(479,12);
 ------
 signal tarca18: unsigned (78 downto 0);
 signal colorp18: std_logic:='0';
 signal ytarca18: unsigned (11 downto 0):=to_unsigned(50,12);
 signal xtarca18: unsigned (11 downto 0):=to_unsigned(558,12);
 ------
 signal tarca19: unsigned (78 downto 0);
 signal colorp19: std_logic:='0';
 signal ytarca19: unsigned (11 downto 0):=to_unsigned(50,12);
 signal xtarca19: unsigned (11 downto 0):=to_unsigned(637,12);
 ------
 signal tarca20: unsigned (78 downto 0);
 signal colorp20: std_logic:='0';
 signal ytarca20: unsigned (11 downto 0):=to_unsigned(50,12);
 signal xtarca20: unsigned (11 downto 0):=to_unsigned(716,12);
  -----------------tarca3---------------------------------------
 signal tarca21: unsigned (78 downto 0);
 signal colorp21: std_logic:='0';
 signal ytarca21: unsigned (11 downto 0):=to_unsigned(70,12);
 signal xtarca21: unsigned (11 downto 0):=to_unsigned(5,12);
 ------
 signal tarca22: unsigned (78 downto 0);
 signal colorp22: std_logic:='0';
 signal ytarca22: unsigned (11 downto 0):=to_unsigned(70,12);
 signal xtarca22: unsigned (11 downto 0):=to_unsigned(84,12);
 ------
 signal tarca23: unsigned (78 downto 0);
 signal colorp23: std_logic:='0';
 signal ytarca23: unsigned (11 downto 0):=to_unsigned(70,12);
 signal xtarca23: unsigned (11 downto 0):=to_unsigned(163,12);
 ------
 signal tarca24: unsigned (78 downto 0);
 signal colorp24: std_logic:='0';
 signal ytarca24: unsigned (11 downto 0):=to_unsigned(70,12);
 signal xtarca24: unsigned (11 downto 0):=to_unsigned(242,12);
 ------
 signal tarca25: unsigned (78 downto 0);
 signal colorp25: std_logic:='0';
 signal ytarca25: unsigned (11 downto 0):=to_unsigned(70,12);
 signal xtarca25: unsigned (11 downto 0):=to_unsigned(321,12);
 ------
 signal tarca26: unsigned (78 downto 0);
 signal colorp26: std_logic:='0';
 signal ytarca26: unsigned (11 downto 0):=to_unsigned(70,12);
 signal xtarca26: unsigned (11 downto 0):=to_unsigned(400,12);
 ------
 signal tarca27: unsigned (78 downto 0);
 signal colorp27: std_logic:='0';
 signal ytarca27: unsigned (11 downto 0):=to_unsigned(70,12);
 signal xtarca27: unsigned (11 downto 0):=to_unsigned(479,12);
 ------
 signal tarca28: unsigned (78 downto 0);
 signal colorp28: std_logic:='0';
 signal ytarca28: unsigned (11 downto 0):=to_unsigned(70,12);
 signal xtarca28: unsigned (11 downto 0):=to_unsigned(558,12);
 ------
 signal tarca29: unsigned (78 downto 0);
 signal colorp29: std_logic:='0';
 signal ytarca29: unsigned (11 downto 0):=to_unsigned(70,12);
 signal xtarca29: unsigned (11 downto 0):=to_unsigned(637,12);
 ------
 signal tarca30: unsigned (78 downto 0);
 signal colorp30: std_logic:='0';
 signal ytarca30: unsigned (11 downto 0):=to_unsigned(70,12);
 signal xtarca30: unsigned (11 downto 0):=to_unsigned(716,12);

 ----- dodaj deklaracije signalov
 signal reset: std_logic;
 signal debug: unsigned(2 downto 0);
 signal pc: unsigned (7 downto 0);
 signal pin: unsigned (11 downto 0); -- vhodna vrata
 signal pout1, pout2: unsigned (11 downto 0);
 
 ---stanja igre
 signal stanje: unsigned (1 downto 0):="01";
 
 --trki plosckov
 signal trk1: std_logic:='0';
 signal trk2: std_logic:='0';
 signal trk3: std_logic:='0';
 signal trk4: std_logic:='0';
 signal trk5: std_logic:='0';
 signal trk6: std_logic:='0';
 signal trk7: std_logic:='0';
 signal trk8: std_logic:='0';
 signal trk9: std_logic:='0';
 signal trk10: std_logic:='0';
 signal trk11: std_logic:='0';
 signal trk12: std_logic:='0';
 signal trk13: std_logic:='0';
 signal trk14: std_logic:='0';
 signal trk15: std_logic:='0';
 signal trk16: std_logic:='0';
 signal trk17: std_logic:='0';
 signal trk18: std_logic:='0';
 signal trk19: std_logic:='0';
 signal trk20: std_logic:='0';
 signal trk21: std_logic:='0';
 signal trk22: std_logic:='0';
 signal trk23: std_logic:='0';
 signal trk24: std_logic:='0';
 signal trk25: std_logic:='0';
 signal trk26: std_logic:='0';
 signal trk27: std_logic:='0';
 signal trk28: std_logic:='0';
 signal trk29: std_logic:='0';
 signal trk30: std_logic:='0';
 
 signal trkst: unsigned(11 downto 0):="000000000000";
 
 signal start: std_logic:='0';
 
 ---SRCA--------------------------------------
 signal ysrce1: unsigned (11 downto 0):=to_unsigned(10,12);
 signal xsrce1: unsigned (11 downto 0):=to_unsigned(10,12);
 signal colorsrce1: std_logic:='0';
 signal srce1: unsigned (15 downto 0);
 
 signal ysrce2: unsigned (11 downto 0):=to_unsigned(10,12);
 signal xsrce2: unsigned (11 downto 0):=to_unsigned(30,12);
 signal colorsrce2: std_logic:='0';
 signal srce2: unsigned (15 downto 0);
 
 signal ysrce3: unsigned (11 downto 0):=to_unsigned(10,12);
 signal xsrce3: unsigned (11 downto 0):=to_unsigned(50,12);
 signal colorsrce3: std_logic:='0';
 signal srce3: unsigned (15 downto 0);
 
 signal ysrce4: unsigned (11 downto 0):=to_unsigned(10,12);
 signal xsrce4: unsigned (11 downto 0):=to_unsigned(70,12);
 signal colorsrce4: std_logic:='0';
 signal srce4: unsigned (15 downto 0);
 
 signal src1: std_logic:='1';
 signal src2: std_logic:='1';
 signal src3: std_logic:='1';
 signal src4: std_logic:='1';
 signal trksrc: unsigned (2 downto 0):="000";
 
 --------------- 
 signal xzstart: unsigned (11 downto 0):="000000000000";
 signal interrupt: std_logic:='0';

 
begin

 U0: vmesnik port map (
		clk => clk, 
		hsync => hsync, 
		vsync => vsync, 
		rgb => rgb,
		num =>num, 
		key =>keys, 
		clkout =>clkout, 
		addr =>addr, 
		data =>data, 
		cpu_pc =>pc, 
		debug =>debug);
		
 U1: VGA port map (
		clk => clk, 
		hsync => hsync, 
		vsync => vsync, 
		x => x, 
		y => y  );
		
 U2: proc port map (clk=>clk, 
		reset=>reset, 
		debug=>debug, 
		pc=>pc, 
		pin=>pin, 
		pout1=>pout1, 
		pout2=>pout2,
		interrupt => interrupt,
		start => start,
		xzoge => xzstart);
--------------------------------------------------------------------------------------------------------------------------------------------------
 reset <= not key(0);
 num <= keys;   -- prikazuj stanje tipk
 --led <= pout2 (7 downto 0);
 led <= "0000000"&trk21;
p1 :process (clk,en,st1)
begin
	-------------------- novi clock (en) 1X NA 100000 -----------------
	if rising_edge(clk)  then st1<=st1 + 1; if st1=80000  then en<='1'; st1<=(others=> '0'); else en<='0'; end if; end if;
 end process;
 

p2: process(clk, keys, xp, en, smerz, yz, interrupt, color, colorz, y, x, rgb, stanje, start)
begin
	
----------------------------------ZAČETEK----------------------------------------------------------------------------------------------------------
if rising_edge(clk) then
	if reset = '1' then stanje <= "01"; xz<=to_unsigned(13, 12); yz<=to_unsigned(550, 12); xp <= to_unsigned(5, 12);
	
	
	
   else	
	if stanje = "01" then
		--postavitev vsega
		
		interrupt<='0';
		start<='0';
		
		--- ploscek x os
		if keys(0)='1' and en = '1' then xp <= xp-1; elsif keys(3)='1' and en = '1' then xp <= xp+1; end if;
		if xp >= 746 then xp <= xp-1; elsif xp <= 0 then xp <= xp+1; end if;
				
		--zoga x os
		if keys(0)='1' and en = '1' then xz <= xz-1; elsif keys(3)='1' and en = '1' then xz <= xz+1; end if;
		if xz <= 12 then xz <= xz+1; elsif xz >= 763 then xz <= xz-1; end if;
		
		--- tipke 1 in 2
		if keys(1)='1' then stanje<="10"; start<='1'; xzstart<=xz; end if;
		
		smerz<='1';
		
		--- poraz
		if trksrc="100" then stanje <= "00"; end if;
		
		--- srca
		if trksrc="100" then src1<='0';
		elsif trksrc="011" then src2<='0';
		elsif trksrc="010" then src3<='0';
		elsif trksrc="001" then src4<='0'; 
		end if;
----------------------------------IGRA-------------------------------------------------------------------------------------------------------------------
	elsif stanje = "10" then
		
		-- xz ploscka
		xz <= pout1;
				
		--- ploscek x pozicija
		if keys(0)='1' and en = '1' then xp <= xp-1; elsif keys(3)='1' and en = '1' then xp <= xp+1; end if;	
		if xp >= 746 then xp <= xp-1; elsif xp <= 0 then xp <= xp+1; end if;
		
		------ premik zoge gor al dol
		if smerz = '0' and en  ='1' then	yz <= yz+1;	elsif smerz = '1' and en = '1' and yz > 5 then yz <= yz-1; end if;
		---- trk v steno zgoraj
		if yz = 30 then smerz <= '0'; end if;
		--- trk zoge z plosckom
		if color = '1' and colorz = '1' then smerz <= '1'; end if;
		
		--- trk v tarco
		if colorp1 = '1' and colorz = '1' and trk1 = '0' then trk1 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp2 = '1' and colorz = '1' and trk2 = '0' then trk2 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp3 = '1' and colorz = '1' and trk3 = '0' then trk3 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp4 = '1' and colorz = '1' and trk4 = '0' then trk4 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp5 = '1' and colorz = '1' and trk5 = '0' then trk5 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp6 = '1' and colorz = '1' and trk6 = '0' then trk6 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp7 = '1' and colorz = '1' and trk7 = '0' then trk7 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp8 = '1' and colorz = '1' and trk8 = '0' then trk8 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp9 = '1' and colorz = '1' and trk9 = '0' then trk9 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp10 = '1' and colorz = '1' and trk10 = '0' then trk10 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp11 = '1' and colorz = '1' and trk11 = '0' then trk11 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp12 = '1' and colorz = '1' and trk12 = '0' then trk12 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp13 = '1' and colorz = '1' and trk13 = '0' then trk13 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp14 = '1' and colorz = '1' and trk14 = '0' then trk14 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp15 = '1' and colorz = '1' and trk15 = '0' then trk15 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp16 = '1' and colorz = '1' and trk16 = '0' then trk16 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp17 = '1' and colorz = '1' and trk17 = '0' then trk17 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp18 = '1' and colorz = '1' and trk18 = '0' then trk18 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp19 = '1' and colorz = '1' and trk19 = '0' then trk19 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp20 = '1' and colorz = '1' and trk20 = '0' then trk20 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp21 = '1' and colorz = '1' and trk21 = '0' then trk21 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp22 = '1' and colorz = '1' and trk22 = '0' then trk22 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp23 = '1' and colorz = '1' and trk23 = '0' then trk23 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp24 = '1' and colorz = '1' and trk24 = '0' then trk24 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp25 = '1' and colorz = '1' and trk25 = '0' then trk25 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp26 = '1' and colorz = '1' and trk26 = '0' then trk26 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp27 = '1' and colorz = '1' and trk27 = '0' then trk27 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp28 = '1' and colorz = '1' and trk28 = '0' then trk28 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp29 = '1' and colorz = '1' and trk29 = '0' then trk29 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		if colorp30 = '1' and colorz = '1' and trk30 = '0' then trk30 <= '1'; smerz<='0'; trkst<=trkst+1; end if;
		
		--- zgresitev ploscka
		if yz = 600 then 
			interrupt<='1'; trksrc<=1+trksrc; xz<=to_unsigned(13, 12); yz<=to_unsigned(550, 12); xp <= to_unsigned(5, 12); stanje<="01"; 
		end if;
		
		---zmaga
		if trkst="000000011110" then stanje<="11"; interrupt<='1'; end if;	
	
--------------------------------PORAZ----------------------------------------------------------------------------------------------------
	elsif stanje = "11" then
		trk1<='0'; trk2<='0'; trk3<='0'; trk4<='0'; trk5<='0'; trk6<='0'; trk7<='0'; trk8<='0'; trk9<='0'; trk10<='0';
		trk11<='0'; trk12<='0'; trk13<='0'; trk14<='0'; trk15<='0'; trk16<='0'; trk17<='0'; trk18<='0'; trk19<='0'; trk20<='0';
		trk21<='0'; trk22<='0'; trk23<='0'; trk24<='0'; trk25<='0'; trk26<='0'; trk27<='0'; trk28<='0'; trk29<='0'; trk30<='0';
		src1<='1'; src2<='1'; src3<='1'; src4<='1';
		stanje<="01";
		trkst<="000000000000";
		xz<=to_unsigned(13, 12); 
		yz<=to_unsigned(550, 12); 
		xp<=to_unsigned(5, 12);
		trksrc <= "000";
	
--------------------------------ZMAGA------------------------------------------------------------------------------------------------------	
	elsif stanje="00"  then
		trk1<='0'; trk2<='0'; trk3<='0'; trk4<='0'; trk5<='0'; trk6<='0'; trk7<='0'; trk8<='0'; trk9<='0'; trk10<='0';
		trk11<='0'; trk12<='0'; trk13<='0'; trk14<='0'; trk15<='0'; trk16<='0'; trk17<='0'; trk18<='0'; trk19<='0'; trk20<='0';
		trk21<='0'; trk22<='0'; trk23<='0'; trk24<='0'; trk25<='0'; trk26<='0'; trk27<='0'; trk28<='0'; trk29<='0'; trk30<='0';
		src1<='1'; src2<='1'; src3<='1'; src4<='1';
		stanje<="01";
		trkst<="000000000000";
		xz<=to_unsigned(13, 12); 
		yz<=to_unsigned(550, 12); 
		xp<=to_unsigned(5, 12);
		trksrc <= "000";
		
	
	end if;
	end if;
-------------------------------Barve-----------------------
 if x<800 and y<600 then
	if x<800 and y<600 and color='1' then rgb <="111100";
	elsif x<800 and y<600 and colorz='1' then rgb <="001100";
	elsif x<800 and y<600 and colorp1='1' and trk1='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp2='1' and trk2='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp3='1' and trk3='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp4='1' and trk4='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp5='1' and trk5='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp6='1' and trk6='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp7='1' and trk7='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp8='1' and trk8='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp9='1' and trk9='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp10='1' and trk10='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp11='1' and trk11='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp12='1' and trk12='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp13='1' and trk13='0' then rgb <="111101"; 
	elsif x<800 and y<600 and colorp14='1' and trk14='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp15='1' and trk15='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp16='1' and trk16='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp17='1' and trk17='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp18='1' and trk18='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp19='1' and trk19='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp20='1' and trk20='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp21='1' and trk21='0' then rgb <="111101"; 
	elsif x<800 and y<600 and colorp22='1' and trk22='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp23='1' and trk23='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp24='1' and trk24='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp25='1' and trk25='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp26='1' and trk26='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp27='1' and trk27='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp28='1' and trk28='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp29='1' and trk29='0' then rgb <="111101";
	elsif x<800 and y<600 and colorp30='1' and trk30='0' then rgb <="111101";
	elsif x<800 and y<600 and colorsrce1='1' and src1='1' then rgb <="110000";
	elsif x<800 and y<600 and colorsrce2='1' and src2='1' then rgb <="110000";
	elsif x<800 and y<600 and colorsrce3='1' and src3='1' then rgb <="110000";
	elsif x<800 and y<600 and colorsrce4='1' and src4='1' then rgb <="110000";
	elsif y<30 or (y<600 and y>595) then  rgb <="111111";
 	elsif x<5 or (x<800 and x>795) then rgb <="111111";
 	else rgb<="101011";
 	end if;
 else rgb <= "000000";
 end if;
 
 
	
end if;
end process;


-------------------------PLOŠČEK-------------------------------------------------------------------------------------------------------------
 color <= '1' when x>xp and x<xp+64 and y>580 and y<595 else
		  '0';

------------------žoga-----------------------------------------------------------------------------------------------------------------------
 vrst <= zoga(to_integer(y-yz)) when y>=yz and y<yz+30 else (others=>'0');	-- postavitev zoge po y osi
 colorz <= vrst(to_integer(x-xz)) when x>=xz and x<xz+30 else '0';			-- postavitev zoge po x osi

------------------TARČE---------------------------------------------------------------------------
 tarca1 <= tarca(to_integer(y-ytarca1)) when y>=ytarca1 and y<ytarca1+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp1 <= tarca1(to_integer(x-xtarca1)) when x>=xtarca1 and x<xtarca1+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca2 <= tarca(to_integer(y-ytarca2)) when y>=ytarca2 and y<ytarca2+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp2 <= tarca2(to_integer(x-xtarca2)) when x>=xtarca2 and x<xtarca2+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca3 <= tarca(to_integer(y-ytarca3)) when y>=ytarca3 and y<ytarca3+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp3 <= tarca3(to_integer(x-xtarca3)) when x>=xtarca3 and x<xtarca3+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca4 <= tarca(to_integer(y-ytarca4)) when y>=ytarca4 and y<ytarca4+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp4 <= tarca4(to_integer(x-xtarca4)) when x>=xtarca4 and x<xtarca4+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca5 <= tarca(to_integer(y-ytarca5)) when y>=ytarca5 and y<ytarca5+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp5 <= tarca5(to_integer(x-xtarca5)) when x>=xtarca5 and x<xtarca5+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca6 <= tarca(to_integer(y-ytarca6)) when y>=ytarca6 and y<ytarca6+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp6 <= tarca6(to_integer(x-xtarca6)) when x>=xtarca6 and x<xtarca6+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca7 <= tarca(to_integer(y-ytarca7)) when y>=ytarca7 and y<ytarca7+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp7 <= tarca7(to_integer(x-xtarca7)) when x>=xtarca7 and x<xtarca7+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca8 <= tarca(to_integer(y-ytarca8)) when y>=ytarca8 and y<ytarca8+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp8 <= tarca8(to_integer(x-xtarca8)) when x>=xtarca8 and x<xtarca8+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca9 <= tarca(to_integer(y-ytarca9)) when y>=ytarca9 and y<ytarca9+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp9 <= tarca9(to_integer(x-xtarca9)) when x>=xtarca9 and x<xtarca9+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca10 <= tarca(to_integer(y-ytarca10)) when y>=ytarca10 and y<ytarca10+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp10 <= tarca10(to_integer(x-xtarca10)) when x>=xtarca10 and x<xtarca10+79 else '0';					-- postavitev zoge po x osi
 ------------------TARČE---------------------------------------------------------------------------
 tarca11 <= tarca(to_integer(y-ytarca11)) when y>=ytarca11 and y<ytarca11+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp11 <= tarca11(to_integer(x-xtarca11)) when x>=xtarca11 and x<xtarca11+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca12 <= tarca(to_integer(y-ytarca12)) when y>=ytarca12 and y<ytarca12+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp12 <= tarca12(to_integer(x-xtarca12)) when x>=xtarca12 and x<xtarca12+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca13 <= tarca(to_integer(y-ytarca13)) when y>=ytarca13 and y<ytarca13+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp13 <= tarca13(to_integer(x-xtarca13)) when x>=xtarca13 and x<xtarca13+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca14 <= tarca(to_integer(y-ytarca14)) when y>=ytarca14 and y<ytarca14+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp14 <= tarca14(to_integer(x-xtarca14)) when x>=xtarca14 and x<xtarca14+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca15 <= tarca(to_integer(y-ytarca15)) when y>=ytarca15 and y<ytarca15+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp15 <= tarca15(to_integer(x-xtarca15)) when x>=xtarca15 and x<xtarca15+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca16 <= tarca(to_integer(y-ytarca16)) when y>=ytarca16 and y<ytarca16+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp16 <= tarca16(to_integer(x-xtarca16)) when x>=xtarca16 and x<xtarca16+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca17 <= tarca(to_integer(y-ytarca17)) when y>=ytarca17 and y<ytarca17+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp17 <= tarca17(to_integer(x-xtarca17)) when x>=xtarca17 and x<xtarca17+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca18 <= tarca(to_integer(y-ytarca18)) when y>=ytarca18 and y<ytarca18+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp18 <= tarca18(to_integer(x-xtarca18)) when x>=xtarca18 and x<xtarca18+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca19 <= tarca(to_integer(y-ytarca19)) when y>=ytarca19 and y<ytarca19+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp19 <= tarca19(to_integer(x-xtarca19)) when x>=xtarca19 and x<xtarca19+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca20 <= tarca(to_integer(y-ytarca20)) when y>=ytarca20 and y<ytarca20+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp20 <= tarca20(to_integer(x-xtarca20)) when x>=xtarca20 and x<xtarca20+79 else '0';					-- postavitev zoge po x osi
 ------------------TARČE---------------------------------------------------------------------------
 tarca21 <= tarca(to_integer(y-ytarca21)) when y>=ytarca21 and y<ytarca21+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp21 <= tarca21(to_integer(x-xtarca21)) when x>=xtarca21 and x<xtarca21+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca22 <= tarca(to_integer(y-ytarca22)) when y>=ytarca22 and y<ytarca22+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp22 <= tarca22(to_integer(x-xtarca22)) when x>=xtarca22 and x<xtarca22+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca23 <= tarca(to_integer(y-ytarca23)) when y>=ytarca23 and y<ytarca23+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp23 <= tarca23(to_integer(x-xtarca23)) when x>=xtarca23 and x<xtarca23+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca24 <= tarca(to_integer(y-ytarca24)) when y>=ytarca24 and y<ytarca24+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp24 <= tarca24(to_integer(x-xtarca24)) when x>=xtarca24 and x<xtarca24+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca25 <= tarca(to_integer(y-ytarca25)) when y>=ytarca25 and y<ytarca25+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp25 <= tarca25(to_integer(x-xtarca25)) when x>=xtarca25 and x<xtarca25+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca26 <= tarca(to_integer(y-ytarca26)) when y>=ytarca26 and y<ytarca26+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp26 <= tarca26(to_integer(x-xtarca26)) when x>=xtarca26 and x<xtarca26+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca27 <= tarca(to_integer(y-ytarca27)) when y>=ytarca27 and y<ytarca27+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp27 <= tarca27(to_integer(x-xtarca27)) when x>=xtarca27 and x<xtarca27+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca28 <= tarca(to_integer(y-ytarca28)) when y>=ytarca28 and y<ytarca28+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp28 <= tarca28(to_integer(x-xtarca28)) when x>=xtarca28 and x<xtarca28+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca29 <= tarca(to_integer(y-ytarca29)) when y>=ytarca29 and y<ytarca29+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp29 <= tarca29(to_integer(x-xtarca29)) when x>=xtarca29 and x<xtarca29+79 else '0';					-- postavitev zoge po x osi
 ------
 tarca30 <= tarca(to_integer(y-ytarca30)) when y>=ytarca30 and y<ytarca30+20 else (others=>'0');	-- postavitev zoge po y osi
 colorp30 <= tarca30(to_integer(x-xtarca30)) when x>=xtarca30 and x<xtarca30+79 else '0';					-- postavitev zoge po x osi

 --------------------------------------------SRCA----------------------------------------------
 srce1 <= srce(to_integer(y-ysrce1)) when y>=ysrce1 and y<ysrce1+10 else (others=>'0');	-- postavitev zoge po y osi
 colorsrce1 <= srce1(to_integer(x-xsrce1)) when x>=xsrce1 and x<xsrce1+16 else '0';	
 ---------------------
 srce2 <= srce(to_integer(y-ysrce2)) when y>=ysrce2 and y<ysrce2+10 else (others=>'0');	-- postavitev zoge po y osi
 colorsrce2 <= srce2(to_integer(x-xsrce2)) when x>=xsrce2 and x<xsrce2+16 else '0';
 --------------------- 
 srce3 <= srce(to_integer(y-ysrce3)) when y>=ysrce3 and y<ysrce3+10 else (others=>'0');	-- postavitev zoge po y osi
 colorsrce3 <= srce3(to_integer(x-xsrce3)) when x>=xsrce3 and x<xsrce3+16 else '0';	
 ---------------------
 srce4 <= srce(to_integer(y-ysrce4)) when y>=ysrce4 and y<ysrce4+10 else (others=>'0');	-- postavitev zoge po y osi
 colorsrce4 <= srce4(to_integer(x-xsrce4)) when x>=xsrce4 and x<xsrce4+16 else '0';	
 
		
end opis;