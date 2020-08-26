library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

package procpak is
 subtype  koda is unsigned(3 downto 0);
 
 -- osnovni nabor operacij
 constant lda: koda := "0001"; -- nalozi iz pomnilnika v akum
 constant sta: koda := "0010"; -- shrani iz akum v pomnilnik

 constant jmp: koda := "0100"; -- skok na novo pomnilnisko lokacijo
 
 constant add: koda := "1000"; -- pristej k akum vrednost iz pomnilnika
 constant sbt: koda := "1001"; -- odstej vrednost iz pomnilnika
 
 -- razsiritve
 constant nota: koda := "0000"; -- logicna negacija
 
 constant inp: koda := "0011"; -- nalozi iz inport v akum
 constant jze: koda := "0101";  -- skok, ce je akum=0
 constant jcs: koda := "0110";  -- skok, ce je carry=1
 constant outp: koda := "0111"; -- shrani iz akum v outport

 constant anda: koda := "1100"; -- logicna IN
 constant ora:  koda := "1101"; -- logicna ALI
 
 constant call: koda := "1010"; -- skok na podprogram, shrani PC in akum
 constant ret: koda := "1011";  -- vrni se, ponastavi PC in akum
 
 constant shl: koda := "1110"; -- pomik akum za eno v levo (mnozenje z 2)
 constant shr: koda := "1111"; -- pomik akum za eno v desno (deljenje z 2)
 
end procpak;

