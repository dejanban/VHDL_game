
library IEEE;
use IEEE.std_logic_1164.all; -- definicija std_logic_vector
use IEEE.numeric_std.all;    -- def. unsigned in sestevanja 	

entity proc is
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
end proc;

architecture Opis of proc is

-- 12-bitni mikroprocesor
  component CPU is							
   port ( clk, ce: in std_logic;
	  	  rst: in std_logic;
		  
		  data: in unsigned(11 downto 0); -- BRAM signali
		  adr: out unsigned(7 downto 0);
		  dout: out unsigned(11 downto 0);
		  we: out std_logic;

		  dat_i: in unsigned(11 downto 0); -- IO signali
		  adr_o: out unsigned(7 downto 0);
		  we_o: out std_logic;
		  dat_o: out unsigned (11 downto 0);
		  
		  busy: out std_logic; -- debug signali
		  pcout: out unsigned (7 downto 0)
	   );
  end component;

-- programski pomnilnik MegaWizard RAM: 1-PORT
  component program is -- RAM
   port ( 		
	 address : IN std_logic_vector (7 DOWNTO 0);
	 clken  : IN STD_LOGIC  := '1';
	 clock	: IN STD_LOGIC  := '1';
	 data  : IN std_logic_vector (11 DOWNTO 0);
	 wren  : IN STD_LOGIC ;
	 q    : OUT std_logic_vector (11 DOWNTO 0)
   );
  end component;

  -- clock enable za upocasnitev procesorja
  signal ce, ce1: std_logic;
  signal cpu_enable: std_logic:='1';
  signal del, ndel: unsigned (23 downto 0) := x"000000";
  
  signal rst,rst1,busy: std_logic;

  -- povezave med procesorjem in pomnilnikom
  signal data, dout: unsigned (11 downto 0) := x"000";
  signal adr: unsigned (7 downto 0);
  signal we: std_logic := '0';
  signal dataout, q: std_logic_vector (11 DOWNTO 0);
  signal address: std_logic_vector (7 DOWNTO 0);
  
  -- povezave na zunanje enote (vrata)
  signal dat_i:  unsigned (11 downto 0);
  signal adr_o:  unsigned (7 downto 0);
  signal dat_o:  unsigned (11 downto 0);
  signal we_o :  std_logic;
  signal int1: std_logic;
  signal int2: std_logic;
  signal start1: std_logic:='0';
  signal interrupt1: std_logic:='0';
  
begin

 U_CPU: CPU port map (
 	clk=>clk, ce=>ce, rst=>rst, 
 	data=>data, adr=>adr, dout=>dout, we=>we,
 	dat_i=>dat_i, adr_o=>adr_o, we_o=>we_o, dat_o=>dat_o,  
 	busy=>busy, pcout=>pc );
 	               
 U_RAM: program port map (
 	clock=>clk, clken=>ce, address=>address, data=>dataout, wren=>we, q=>q);
  
 address <= std_logic_vector(adr);
 dataout <= std_logic_vector(dout);
 data <= unsigned(q);
 
 pio: process(clk) -- proces za izhodni vmesnik...
 begin
	if rising_edge(clk) then
			
		interrupt1<=interrupt;
		start1<=start;
		--interrupt
		if interrupt1='0' and interrupt='1' then int1<='1'; end if;		--se postavi če je prejšnja vrednost različna od nove
		if we_o='1' and ce='1' and adr_o = 3 then int1<='0'; end if;    -- int1 = 0 (reset interrupt)
		--start
		if start1='0' and start='1' then int2<='1'; end if;
		if ce = '1' and we_o = '1' and adr_o = 3 then int2<='0'; end if; -- int2 = 0 (reset start)
		--branje tipk
		if ce = '1' and we_o = '1' and adr_o = 1 then pout1 <= dat_o; end if; -- pout1 = xz
		if ce = '1' and we_o = '1' and adr_o = 2 then pout2 <= dat_o; end if;
	
	end if;
 end process; 
					 
 rst <= '1' when reset='1' or rst1='1' else '0';
					 
 -- delilnik ure in generator kontrolnih signalov za CPU
 ce_generator: process(clk)
 begin
 if rising_edge(clk) then
	rst1 <= '0';
	ce <= '0';
	
	
	if debug(2)='1' then -- nov debug ukaz    
	case debug(1 downto 0) is
	   when  "00"  => -- stop
	     cpu_enable <= '0';     
	   when  "01"  => -- reset
	     rst1 <= '1'; cpu_enable <= '0'; ce <= '1'; 
	   when  "10"  => -- enable run
	     cpu_enable <= '1';     
	   when others => -- korak
	     cpu_enable <= '0'; ce <= '1'; 
	 end case;
	end if;

	-- register (ukaz OUTP 0) za programsko nastavitev delilnika
	if adr_o=x"00" and we_o='1' then
	  ndel <= dat_o & x"001";
	end if;
	
   if cpu_enable='1' then -- enable cpu + delilnik
		ce <= '0';
		if del < ndel then --10000000
			del <= del + 1;
		else
			del <= x"000000";
			ce <= '1';
		end if;  
	end if;

	ce1 <= ce;	
	if busy='1' and ce1='1' then -- podaljsaj cikel
		ce <= '1';
	end if;

 end if;
end process;
--------------------------------------------

dat_i <= "00000000000"&int1 when adr_o=x"00"else
			"00000000000"&int2 when adr_o=x"01"else
				xzoge				 when adr_o=x"02"else pin;
end Opis;
