library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity ID is
    Port ( RegWrite: in std_logic;
           Instr: in std_logic_vector(15 downto 0);
           RegDst: in std_logic;
           clk: in std_logic;
           en: in std_logic;
           ExtOp: in std_logic;
           wd: in std_logic_vector(15 downto 0);
           ext_imm: out std_logic_vector(15 downto 0);
           func: out std_logic_vector(2 downto 0);
           sa: out std_logic;
           rd1: out std_logic_vector(15 downto 0);
           rd2: out std_logic_vector(15 downto 0));
end ID;

architecture Behavioral of ID is

--reg file signals
signal ra1,ra2,wa: std_logic_vector(2 downto 0);
signal writeData:std_logic_vector(15 downto 0);
signal rdata1,rdata2:std_logic_vector(15 downto 0);

type reg_array is array(0 to 7) of std_logic_vector(15 downto 0);

signal reg_file:reg_array:=(
others=>x"0000");

begin

ra1<=Instr(12 downto 10);
ra2<=Instr(9 downto 7);
wa<=Instr(9 downto 7) when RegDst='0' else Instr(6 downto 4);
writeData<=wd;


process(clk)
begin 
    if (rising_edge(clk)) then
           if en='1' and RegWrite='1' then
                reg_file(conv_integer(wa))<=writeData;
           end if;
    end if;
end process;

rd1 <= reg_file(conv_integer(ra1));
rd2 <= reg_file(conv_integer(ra2));

ext_imm <= "000000000" & Instr(6 downto 0) when ExtOp = '0' else Instr(6)&Instr(6)&Instr(6)&Instr(6)&Instr(6)&Instr(6)&Instr(6)&Instr(6)&Instr(6)&Instr(6 downto 0);
func<=Instr(2 downto 0);
sa<=Instr(3);
                
end Behavioral;
