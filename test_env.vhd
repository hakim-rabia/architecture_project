library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

signal en,reset,wen: STD_LOGIC;
signal output:STD_LOGIC_VECTOR(15 downto 0):=x"0000";
signal instruction,next_instruction:std_logic_vector(15 downto 0);

signal regdst,extop,alusrc,branch,memwrite,memtoreg,regwrite,sa,jump,brne: std_logic;
signal aluop: std_logic_vector(1 downto 0);
signal extimm,rd1,rd2,wd:std_logic_vector(15 downto 0);
signal func:std_logic_vector(2 downto 0);

signal alures,branchAddr,jumpAddr,memdata,aluresout:std_logic_vector(15 downto 0);
signal zero,pcsrc:std_logic;

component MPG 
port ( input: in std_logic;
        clk:in std_logic;
       enable: out std_logic
      );
end component;

component SSD
port( clk:in STD_LOGIC;
      digit0,digit1,digit2,digit3: in STD_LOGIC_VECTOR(3 downto 0);
      an : out STD_LOGIC_VECTOR (3 downto 0);
      cat : out STD_LOGIC_VECTOR (6 downto 0));
end component;

component IFetch
port(jump: in std_logic;
     jumpAddress: in std_logic_vector (15 downto 0);
     PCSrc: in std_logic;
     BranchAddress: in std_logic_vector (15 downto 0);
     en: in std_logic;
     rst: in std_logic;
     clk: in std_logic;
     instr: out std_logic_vector (15 downto 0);
     next_instr: out std_logic_vector (15 downto 0) );
end component;

component ID
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
end component;

component MainControl 
    Port( Instr : in std_logic_vector(15 downto 0);
          RegDst,ExtOp,ALUSrc,Branch,Jump,MemWrite,MemtoReg,RegWrite,BrNE: out std_logic;
          ALUOp:out std_logic_vector(1 downto 0));
end component;

component EX
    Port(RD1: in std_logic_vector(15 downto 0);
     RD2: in std_logic_vector(15 downto 0);
     AluSrc: in std_logic;
     Ext_Imm: in std_logic_vector(15 downto 0);
     sa: in std_logic;
     func: in std_logic_vector(2 downto 0);
     AluOp: in std_logic_vector(1 downto 0);
     next_addr: in std_logic_vector(15 downto 0);
     zero: out std_logic;
     AluRes:out std_logic_vector(15 downto 0);
     branchAddress: out std_logic_vector(15 downto 0));
end component;

component MEM is
    Port(MemWrite: in std_logic;
         AluResIn: in std_logic_vector(15 downto 0);
         RD2: in std_logic_vector(15 downto 0);
         clk: in std_logic;
         en: in std_logic;
         AluResOut: out std_logic_vector(15 downto 0);
         MemData: out std_logic_vector(15 downto 0));
end component;

begin

process(sw(7 downto 5),instruction,next_instruction,rd1,rd2,extimm,alures,memdata,wd)
begin
    case sw(7 downto 5) is
        when "000" => output<=instruction;
        when "001" => output<=next_instruction;
        when "010" => output<=rd1;
        when "011" => output<=rd2;
        when "100" => output<=extimm;
        when "101" => output<=alures;
        when "110" => output<=memdata;
        when "111" => output<=wd;
        when others => output <= x"0000";
    end case;
end process;

led(10 downto 0)<=aluop&regdst&extop&alusrc&branch&jump&memwrite&memtoreg&regwrite&brne;

pcsrc<=(brne and not(zero)) or(zero and branch);
jumpAddr<=next_instruction(15 downto 13)&instruction(12 downto 0);
wd<=aluresout when memtoreg='0' else memdata;

monoimpulse:MPG port map(input=>btn(0),clk=>clk, enable=>en);
monoimpulseR:MPG port map(input=>btn(1),clk=>clk, enable=>reset);

display:SSD port map(clk=>clk,digit0=>output(3 downto 0),digit1=>output(7 downto 4),digit2=>output(11 downto 8), digit3=>output(15 downto 12),an=>an,cat=>cat);

InstrFetch: IFetch port map(jump=>jump,jumpAddress=>jumpAddr,PCSrc=>pcsrc,branchAddress=>branchAddr,en=>en,rst=>reset,clk=>clk,instr=>instruction,next_instr=>next_instruction);
InstrDecode: ID port map(RegWrite=>regwrite,Instr=>instruction,RegDst=>regdst,clk=>clk,en=>en,ExtOp=>extop,wd=>wd,ext_imm=>extimm,func=>func,sa=>sa,rd1=>rd1,rd2=>rd2);
UC: MainControl port map(Instr=>instruction,RegDst=>regdst,ExtOp=>extop,ALUSrc=>alusrc,Branch=>branch,Jump=>jump,MemWrite=>memwrite,MemtoReg=>memtoreg,RegWrite=>regwrite,BrNE=>brne,ALUOp=>aluop);
EX1: EX port map(RD1=>rd1,RD2=>rd2,AluSrc=>alusrc,Ext_Imm=>extimm,sa=>sa,func=>func,AluOp=>aluop,next_addr=>next_instruction,zero=>zero,AluRes=>alures,branchAddress=>branchAddr);
MEM1: MEM port map(MemWrite=>memwrite,AluResIn=>alures,RD2=>rd2,clk=>clk,en=>en,AluResOut=>aluresout,MemData=>memdata);

end Behavioral;
