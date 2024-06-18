library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity IFetch is
    Port ( jump: in std_logic;
          jumpAddress: in std_logic_vector (15 downto 0);
          PCSrc: in std_logic;
          BranchAddress: in std_logic_vector (15 downto 0);
          en: in std_logic;
          rst: in std_logic;
          clk: in std_logic;
          instr: out std_logic_vector (15 downto 0);
          next_instr: out std_logic_vector (15 downto 0) );
end IFetch;

architecture Behavioral of IFetch is
signal d: std_logic_vector(15 downto 0):=x"0000";
signal q: std_logic_vector(15 downto 0):=x"0000";
signal m1: std_logic_vector(15 downto 0); -- mux1 result
signal pc:std_logic_vector(15 downto 0);
type rom is array (0 to 15) of std_logic_vector(15 downto 0);
-- Initialize R1 with 10
-- Initialize R2 with 15
-- Store in R3 the value of R2-R1, meaning 5
-- Store in R4 the value of R2+R1 meaning 25
-- Store the value of R3 (5) at the memory address 6+R1=16 
-- Load in the memory R2 the value from the address R2+1=16 => R2=5
-- Shift right R1 with 1 position => R1=R1/2=10/2=5
-- If R1=R2 jump 2 instructions from the current position
-- Jump to the instruction with the index 4 from the code, meaning the 5th one
-- Store the value of R1 (5) at the address R2+2=7
-- Store in R4 the R4-R2, meaning 20
-- Left shift R1 with 1 position => R1=R1*2=10
-- If R1=R4 jump 2 instructions from the current position
-- Jump to the instruction with the index 11 from the code, meaning the 12th one
-- Store the value of R1 (20) in the memory at address 5 
signal mem_rom: rom:=(
x"208A", -- 001_000_001_0001010, addi $1,$0,10 
    x"210F", -- 001_000_010_0001111, addi $2,$0,15
    x"08B1", -- 000_010_001_011_0_001, sub $3,$2,$1
    x"08C0", -- 000_010_001_100_0_000, add $4,$2,$1
    x"6586", -- 011_001_011_0000110, sw $3,6($1) 
    x"4901", -- 010_010_010_0000001, lw $2,1($2)
    x"049B", -- 000_001_001_001_1_011, srl $1,$1,1
    x"8501", -- 100_001_010_0000001, beq $1,$2,1
    x"E004", -- 111_0000000000000100, j 4
    x"6482", -- 011_001_001_0000010, sw $1,2($1)
    x"1141", -- 000_100_010_100_0_001, sub $4,$4,$2
    x"049A", -- 000_001_001_001_1_010, sll $1,$1,1
    x"8601", -- 100_001_100_0000001, beq $1,$4,1
    x"E00B", -- 111_00000000001011, j 11
    x"6085", -- 011_000_001_0000101, sw $1,5($0)
    x"0000"  -- Default value
);

begin

process(clk)
begin
    if rising_edge(clk) then
        if rst='1' then 
            q<=x"0000";
        elsif en='1' then 
            q<=d;
        end if;
    end if;
end process;
pc<=q+1;
next_instr<=pc;
m1<=pc when PCSrc='0' else BranchAddress; 
d<=jumpAddress when jump='1' else m1;
instr<=mem_rom(conv_integer(q(3 downto 0))); 
            
end Behavioral;
