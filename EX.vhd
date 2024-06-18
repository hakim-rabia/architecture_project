library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity EX is
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
end EX;

architecture Behavioral of EX is

signal ALUCtrl: std_logic_vector(2 downto 0);
signal A,B,AluResAux: std_logic_vector(15 downto 0):=x"0000";

begin

A<=RD1;
B<=RD2 when AluSrc='0' else Ext_Imm;
BranchAddress<=Ext_Imm+next_addr;

process(AluOp,func)
begin
    case AluOp is
        when "00" =>    --R type
            case func is
                when "000" => ALUCtrl<="000"; --add
                when "001" => ALUCtrl<="001"; --sub
                when "010" => ALUCtrl<="101"; --sll
                when "011" => ALUCtrl<="110"; --srl
                when "100" => ALUCtrl<="010"; --and
                when "101" => ALUCtrl<="011"; --or
                when "110" => ALUCtrl<="100"; --xor
                when "111" => ALUCtrl<="111"; --sra
                when others => ALUCtrl<=(others=>'X');
            end case;
        when "01" => ALUCtrl<="000"; --(+)
        when "10" => ALUCtrl<="001"; --(-)
        when "11" => ALUCtrl<="011"; --(|)
        when others => ALUCtrl<=(others=>'X');
    end case;
end process;

process(ALUCtrl,sa,A,B)
begin
    case ALUCtrl is
        when "000" => AluResAux<=A+B; --(+)
        when "001" => AluResAux<=A-B; --(-)
        when "010" => AluResAux<=A and B; --(&)
        when "011" => AluResAux<=A or B; --(|)
        when "100" => AluResAux<=A xor B; --(^)
        when "101" => --sll
            if(sa='1') then
                 AluResAux<=B(14 downto 0)&'0';
            else
                AluResAux<=B;
            end if;
        when "110" => --srl
            if(sa='1') then
                  AluResAux<='0'&B(15 downto 1);
            else
                  AluResAux<=B;
            end if;
        when "111" => --sra
            if(sa='1') then
                 AluResAux<=B(0)&B(15 downto 1);
            else
                 AluResAux<=B;
            end if;
        when others => AluResAux<=(others => 'X');
    end case;
    
end process;    
    
process(AluResAux)
begin
if(AluResAux=x"0000") then
        zero<='1';
    else 
        zero<='0';
    end if;
end process;

AluRes<=AluResAux;
                
end Behavioral;
