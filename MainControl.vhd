library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MainControl is
    Port( Instr : in std_logic_vector(15 downto 0);
          RegDst,ExtOp,ALUSrc,Branch,Jump,MemWrite,MemtoReg,RegWrite,BrNE: out std_logic;
          ALUOp:out std_logic_vector(1 downto 0));
end MainControl;

architecture Behavioral of MainControl is

begin

process(Instr)
begin
    RegDst<='0';ExtOp<='0';ALUSrc<='0';Branch<='0';Jump<='0';
    MemWrite<='0';MemtoReg<='0';RegWrite<='0';BrNE<='0';
    ALUOp<="00";
    case Instr(15 downto 13) is
        when "000" => --RType
                    RegDst<='1'; RegWrite<='1';
        when "001"=> --addi
                    ExtOp<='1';ALUSrc<='1';RegWrite<='1';
                    ALUOp<="01";
        when "010"=> --lw
                   ExtOp<='1';ALUSrc<='1';RegWrite<='1';MemtoReg<='1';
                   ALUOP<="01";
        when "011"=> --sw
                   ExtOp<='1';ALUSrc<='1';MemWrite<='1';
                   ALUOp<="01";
        when "100"=> --beq
                   ExtOp<='1';Branch<='1';
                   ALUOp<="10";
        when "101"=> --ori
                   ALUSrc<='1';RegWrite<='1';
                   ALUOp<="11";
        when "110"=> --bne
                   ExtOp<='1';
                   BrNE<='1';
                   ALUOp<="10";
        when "111"=> --j
                   Jump<='1';
                   ALUOp<="01";
        when others => --RType
                    RegDst<='1'; RegWrite<='1';
    end case;
end process;

end Behavioral;
