library IEEE;
library work;
use work.procpak.all;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cpu is
  port ( 		
		clk, ce: in std_logic;				--clock, ce = clock enable
		rst: in std_logic;
		data: in unsigned(11 downto 0);
		dat_i: in unsigned(11 downto 0);
		adr_o: out unsigned(7 downto 0);
		we_o: out std_logic;
		dat_o: out unsigned (11 downto 0);
		we: out std_logic;
		dout: out unsigned(11 downto 0);
		adr: out unsigned(7 downto 0);
		busy: out std_logic;
		pcout: out unsigned (7 downto 0)
	);
end cpu;

architecture Behavioral of cpu is

type stanje is (reset, zajemi, izvedi);
signal st: stanje;

signal pc, pc1: unsigned(7 downto 0):="00000000";
signal adr_reg, adr_next: unsigned (7 downto 0):="00000000";
signal akum, akum1: unsigned (11 downto 0):=x"000";
signal inst_code: unsigned (3 downto 0);
signal carry: std_logic := '0';
begin

 -- kombinacijsko določi naslov
 adr_next <=  x"00" when st=reset else  -- reset
				  pc1 when st=izvedi and inst_code=ret else   -- dodatek za return 
				  pc when st=izvedi else    -- naslednji ukaz
				  data(7 downto 0);         -- parameter
 adr <= adr_next; -- naslovni signal

 pcout <= pc;  -- izhod za debug

 sekv: process (clk, ce)
  variable rez: unsigned(12 downto 0); -- delni rezultat vsote/razlike
 begin
  if rising_edge(clk) and ce='1' then
	we_o <= '0';
    busy<='0';

	adr_reg <= adr_next;
	
	if rst = '1' then  -- reset postavi pc na 0
		st <= reset;
		pc <= x"00";
	elsif st = reset then
		akum <= x"000";
		adr_reg <= x"00";
		st <=zajemi;
-----------------------------------------------------------------------	  
	elsif st = zajemi then
		pc <= adr_reg + 1;
		busy<='0';
	
		if (data(11 downto 8)=jmp) or 
		   (data (11 downto 8)=jze  and akum= 0) or
		   (data(11 downto 8)=jcs and carry = '1') then
			st <= zajemi;
		elsif (data(11 downto 8)=call) then -- skok na podprogram
			st <= zajemi;
			pc1 <= adr_reg + 1; -- shrani naslednji pc(tj. adr+1) in akumulator
			akum1 <= akum;			
		else 
			st <=izvedi;
			busy<='1';
		end if;

		if data(11 downto 8)=outp then
			dat_o <= akum;
		end if;
		
		if data(11 downto 8)=inp or data(11 downto 8)=outp then
			adr_o <= data (7 downto 0);
		end if;
	
		inst_code <= data(11 downto 8);
-----------------------------------------------------------------------	
	else -- izvedi
		st <=zajemi;		
		case inst_code is		
		 when lda =>
			akum <= data;
			carry <= '0';
		 when inp =>
			akum <= dat_i;
			carry <= '0';
		 when add =>
			rez := ('0' & akum) + ('0' & data);			
			akum <= rez(11 downto 0);
			carry <= rez(12);
		 when sbt =>
			rez := ('0' & akum) - ('0' & data);			
			akum <= rez(11 downto 0);
			carry <= rez(12);
		 when nota =>
			akum <= not akum;
			carry <= '0';
		 when anda =>
			akum <= akum and data;
			carry <= '0';
		 when ora =>
			akum <= akum or data;
			carry <= '0';
		 when shl =>
			akum <= akum sll 1;
			carry <= akum(11);
		 when shr =>
			akum <= akum srl 1;
			carry <= akum(0);
		 when ret =>
			akum <= akum1;			
		 when outp =>
			we_o <= '1';
		 when others =>
			null;
		end case;
------------------------------------------------------------------------
	end if;
  end if;
 end process;

 dout <= akum;

 we<='1' when data(11 downto 8)=sta and st=zajemi else '0';

end Behavioral;
