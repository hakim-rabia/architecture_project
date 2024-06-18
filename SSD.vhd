library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SSD is
    Port (clk: in STD_LOGIC;
          digit0,digit1,digit2,digit3: in STD_LOGIC_VECTOR(3 downto 0);
          an : out STD_LOGIC_VECTOR (3 downto 0);
          cat : out STD_LOGIC_VECTOR (6 downto 0));
end SSD;

architecture Behavioral of SSD is

signal count: STD_LOGIC_VECTOR(15 downto 0);
signal hex,output: STD_LOGIC_VECTOR(3 downto 0);

begin

process(clk)
begin
    if rising_edge(clk) then
        count <= count +1;
    end if;
end process;

process(count(15 downto 14), digit0,digit1,digit2,digit3)
begin
    case count(15 downto 14)is
        when "00" => hex<=digit0;
        when "01" => hex<=digit1;
        when "10" => hex<=digit2;
        when others  => hex<=digit3;
     end case;
end process;

process(count(15 downto 14))
begin
    case count(15 downto 14) is
        when "00" => output<="1110";
        when "01" => output<="1101";
        when "10" => output<="1011";
        when others => output<="0111";
     end case;
end process;

an<=output;

process (hex)
begin
    case hex is
        when "0001" => cat<= "1111001";   --1
        when "0010" => cat<="0100100";  --2
        when "0011" => cat<="0110000";   --3
        when "0100" => cat<="0011001";   --4
        when "0101" => cat<="0010010";   --5
        when "0110" => cat<="0000010";   --6
        when "0111" => cat<="1111000";   --7
        when "1000" => cat<="0000000";   --8
        when "1001" => cat<="0010000";   --9
        when "1010" => cat<="0001000";   --A
        when "1011" => cat<="0000011";   --b
        when "1100" => cat<="1000110";   --C
        when "1101" => cat<="0100001";   --d
        when "1110" => cat<="0000110";   --E
        when "1111" => cat<="0001110";   --F
        when others => cat<="1000000";   --0
     end case;
end process;
  
end Behavioral;
