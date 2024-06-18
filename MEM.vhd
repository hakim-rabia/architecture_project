library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity MEM is
    Port(MemWrite: in std_logic;
         AluResIn: in std_logic_vector(15 downto 0);
         RD2: in std_logic_vector(15 downto 0);
         clk: in std_logic;
         en: in std_logic;
         AluResOut: out std_logic_vector(15 downto 0);
         MemData: out std_logic_vector(15 downto 0));
end MEM;

architecture Behavioral of MEM is

signal address: std_logic_vector(4 downto 0);
signal writeData: std_logic_vector(15 downto 0);
type memory is array (0 to 31) of std_logic_vector(15 downto 0);
signal MEM: memory; 

begin
address<=AluResIn(4 downto 0);

process(clk)
begin
    if rising_edge(clk) then
        if en='1' and MemWrite='1' then
            MEM(conv_integer(address))<=writeData;
        end if;
   end if;
end process;

MemData<=MEM(conv_integer(address));
writeData<=RD2;

AluResOut<=AluResIn;

end Behavioral;
