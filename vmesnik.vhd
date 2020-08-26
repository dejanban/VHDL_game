library IEEE;
use IEEE.std_logic_1164.all; -- definicija std_logic_vector
use IEEE.numeric_std.all;    -- def. unsigned in sestevanja 	
use ieee.std_logic_unsigned.all; --za sestevanje


entity vmesnik is
	Port(	clk : in std_logic;     
			hsync, vsync: in std_logic;   -- signali VGA vmesnika
			rgb: in unsigned(5 downto 0);
			
			num : in unsigned(3 downto 0);   -- stevilka za izpis na LED
			key : out unsigned(3 downto 0); -- pritisnjena tipka
			
			clkout: out std_logic; -- signali razsiritvene plosce
			addr : out STD_LOGIC_VECTOR(1 DOWNTO 0);
			data : inout STD_LOGIC_VECTOR(7 DOWNTO 0)			
		 );
end vmesnik;

architecture Opis of vmesnik is
	signal data_led : std_logic_vector (7 downto 0);
	signal on_off : std_logic;
	signal hs1, hs2: std_logic;
  
	signal par_counter : unsigned(16 downto 0):="00000000000000000";
	signal ver_counter : unsigned(2 downto 0):="000";
	signal number_counter : unsigned(3 downto 0):="0000";
  
	signal addr_room : std_logic_vector(6 downto 0);
	signal data_room : std_logic_vector(4 downto 0);
	signal message_addr : std_logic_vector(6 downto 0);

   type rom_type is array(0 to 111) of std_logic_vector(4 downto 0);  --64 znakov
   constant FONT: rom_type :=
    (
        -- 0  (0h)
        "01110", --  ### 
        "10001", -- #   #
        "10001", -- #   #
        "10001", -- #   #
        "10001", -- #   #
        "10001", -- #   #
        "01110", --  ###
        -- 1  (1h)
        "00100", --   #
        "01100", --  ##
        "10100", -- # #
        "00100", --   #
        "00100", --   #
        "00100", --   #
        "11111", -- #####
		  -- 2  (2h)
        "01110", --  ###
        "10001", -- #   #
        "00010", --    #
        "00100", --   #
        "01000", --  #
        "10000", -- #
        "11111", -- #####
        -- 3  (3h)
        "11111", -- #####
        "00010", --    #
        "00100", --   #
        "01110", --  ###
        "00001", --     #
        "10001", -- #   #
        "01110", --  ###
        -- 4  (4h)
        "00010", --    #
        "00110", --   ##
        "01010", --  # #
        "10010", -- #  #
        "11111", -- #####
        "00010", --    #
        "00010", --    #
        -- 5  (5h)
        "11111", -- #####
        "10000", -- #
        "11110", -- ####
        "00001", --     #
        "00001", --     #
        "10001", -- #   #
        "01110", --  ###
        -- 6  (6h)
        "00111", --   ###
        "01000", --  #
        "10000", -- #
        "11110", -- ####
        "10001", -- #   #
        "10001", -- #   # 
        "01110", --  ###
        -- 7  (7h)
        "11111", -- #####
        "10001", -- #   #
        "00010", --    #
        "00100", --   #
        "00100", --   #
        "00100", --   # 
        "00100", --   #
        -- 8  (8h)
        "01110", --  ###
        "10001", -- #   #
        "10001", -- #   #
        "01110", --  ###
        "10001", -- #   #
        "10001", -- #   #
        "01110", --  ###
        -- 9  (9h)
        "01110", --  ###
        "10001", -- #   #
        "10001", -- #   #
        "01111", --  ####
        "00001", --     #
        "10001", -- #   #
        "01110", --  ###
        -- A  (Ah)
        "00100", --  #
        "01110", -- ###
        "10001", --#   #
        "10001", --#   #
        "11111", --#####
        "10001", --#   #
        "10001", --#   #
        -- B  (Bh)
        "11110", --####
        "10001", --#   #
        "10001", --#   #
        "11110", --####
        "10001", --#   #
        "10001", --#   #
        "11110", --####
        -- C  (Ch)
        "00110", --  ## 
        "01001", -- #  #
        "10000", --#
        "10000", --#
        "10000", --#
        "01001", -- #  #
        "00110", --  ##
		  -- D  (Dh)
        "11100", --###
        "10010", --#  #
        "10001", --#   #  
        "10001", --#   #
        "10001", --#   #
        "10010", --#  #
        "11100", --###
        -- E  (Eh)
        "11111", --#####
        "10000", --#
        "10000", --#
        "11111", --#####
        "10000", --#
        "10000", --#
        "11111", --#####
        -- F  (Fh)
        "11111", --#####
        "10000", --#
        "10000", --#
        "11100", --###
        "10000", --#
        "10000", --#
        "10000"  --#
    );

begin

 ----------------------------------------------------------------------------------------------
 -- Logika za dostop do komponent na razširitveni plošči
 --  VGA: rgb(5:0), hsync, vsync
 --  LEDmatrika: num(3:0)       
 --  tipke: t(3:0)
 pio: process(clk)
 begin
   if rising_edge(clk) then
   hs1 <= hsync;
	hs2 <= '0';
	if hs1='1' and hsync='0' then			
	  addr <= "01"; data <= "ZZZZZZZZ"; 	-- address = 01, data = ZZZZZZZZ
	  hs2 <= '1';
	elsif hs2='1' then
	  addr <= "10"; data<=data_led; 		-- address = 10, data = data_led (podatki za ledice)
	  key <= unsigned(data(3 downto 0));	-- key
	else
	  addr <= "00";  
	  data(7) <= hsync;
	  data(6) <= vsync;
	  data(5 downto 0) <= std_logic_vector(rgb(1 downto 0) & rgb(3 downto 2) & rgb(5 downto 4));
	end if;
	end if;
 end process;

 --c_LED: ledmatrix port map (clk, data_led, on1, num);
 clkout <= clk;
 
 on_off <= '1'; -- LED matrika je stalno vklopljena


data_room <= FONT(conv_integer(addr_room));
	
main:process (clk)
begin
	if rising_edge(clk) then
		--*********************pararelni_stevec**************
		par_counter<=par_counter+1;
	 
		if (par_counter=1) then  --ko je stevec '1' vpišemo pridobljene podatke v (data_led)
			if (on_off='1') then
				data_led(4)<=data_room(0);
				data_led(3)<=data_room(1);
				data_led(2)<=data_room(2);
				data_led(1)<=data_room(3);
				data_led(0)<=data_room(4);
				if(data_room=0) then  --če je vrstica prazna vpišemo v "000" kar naredi vrstico led matrike neaktivno
					data_led(7 downto 5)<="000";
				else
					data_led(7 downto 5)<= std_logic_vector(ver_counter)+1;  --vpišemo katera vrstica led matrike bo aktivna glede na stevec (ver_counter)
				end if;
			else
				data_led<="00000000";
			end if;
			
			ver_counter<=ver_counter+1;
			if(ver_counter="110") then --nastavimo (number_counter) z zelenim zankom (num), ko smo prikazali celoten znak (number)
				ver_counter<="000";
				number_counter<=unsigned(num); 
			end if;
		end if; 
	end if;                                 	  
end process;                                                                         

--nastavimo message_addr glede na izbran znak (number)
message_addr <= (std_logic_vector(number_counter)*"111");  -- when par_counter=1;  
				
addr_room <= std_logic_vector(ver_counter) + message_addr; -- sestavimo addr_room

end Opis;