library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity testbench is
end testbench;

architecture Behavioral of testbench is
    
    component MPG
        port (
            input : in std_logic;
            clk : in std_logic;
            enable : out std_logic
        );
    end component;

    component IFetch
        port (
            jump : in std_logic;
            jumpAddress : in std_logic_vector(15 downto 0);
            PCSrc : in std_logic;
            BranchAddress : in std_logic_vector(15 downto 0);
            en : in std_logic;
            rst : in std_logic;
            clk : in std_logic;
            Instr : out std_logic_vector(15 downto 0);
            next_instr : out std_logic_vector(15 downto 0)
        );
    end component;
    
    component ID
        port (
            RegWrite : in std_logic;
            Instr : in std_logic_vector(15 downto 0);
            RegDst : in std_logic;
            clk : in std_logic;
            en : in std_logic;
            ExtOp : in std_logic;
            wd : in std_logic_vector(15 downto 0);
            ext_imm : out std_logic_vector(15 downto 0);
            func : out std_logic_vector(2 downto 0);
            sa : out std_logic;
            rd1 : out std_logic_vector(15 downto 0);
            rd2 : out std_logic_vector(15 downto 0)
        );
    end component;
    
    component MainControl
        port (
            Instr : in std_logic_vector(15 downto 0);
            RegDst : out std_logic;
            ExtOp : out std_logic;
            ALUSrc : out std_logic;
            Branch : out std_logic;
            Jump : out std_logic;
            MemWrite : out std_logic;
            MemtoReg : out std_logic;
            RegWrite : out std_logic;
            BrNE : out std_logic;
            ALUOp : out std_logic_vector(1 downto 0)
        );
    end component;
    
    component EX
        port (
            RD1 : in std_logic_vector(15 downto 0);
            RD2 : in std_logic_vector(15 downto 0);
            AluSrc : in std_logic;
            Ext_Imm : in std_logic_vector(15 downto 0);
            sa : in std_logic;
            func : in std_logic_vector(2 downto 0);
            AluOp : in std_logic_vector(1 downto 0);
            next_addr : in std_logic_vector(15 downto 0);
            zero : out std_logic;
            AluRes : out std_logic_vector(15 downto 0);
            branchAddress : out std_logic_vector(15 downto 0)
        );
    end component;
    
    component MEM
        port (
            MemWrite : in std_logic;
            AluResIn : in std_logic_vector(15 downto 0);
            RD2 : in std_logic_vector(15 downto 0);
            clk : in std_logic;
            en : in std_logic;
            AluResOut : out std_logic_vector(15 downto 0);
            MemData : out std_logic_vector(15 downto 0)
        );
    end component;

    -- Signals for connecting to the MPG component
    signal tb_input_mpg : std_logic := '0';
    signal tb_clk_mpg : std_logic := '0';
    signal tb_enable_mpg : std_logic;

    -- Signals for connecting to the IFetch component
    signal tb_jump_ifetch : std_logic := '0';
    signal tb_jumpAddress_ifetch : std_logic_vector(15 downto 0) := (others => '0');
    signal tb_PCSrc_ifetch : std_logic := '0';
    signal tb_BranchAddress_ifetch : std_logic_vector(15 downto 0) := (others => '0');
    signal tb_en_ifetch : std_logic := '1';
    signal tb_rst_ifetch : std_logic := '0';
    signal tb_clk_ifetch : std_logic := '0';
    signal tb_instr_ifetch : std_logic_vector(15 downto 0);
    signal tb_next_instr_ifetch : std_logic_vector(15 downto 0);
    
    -- Signals for connecting to the ID component
    signal RegWrite : std_logic := '0';
    signal Instr : std_logic_vector(15 downto 0) := (others => '0');
    signal RegDst : std_logic := '0';
    signal clk : std_logic := '0';
    signal en : std_logic := '0';
    signal ExtOp : std_logic := '0';
    signal wd : std_logic_vector(15 downto 0) := (others => '0');
    signal ext_imm : std_logic_vector(15 downto 0);
    signal func : std_logic_vector(2 downto 0);
    signal sa : std_logic;
    signal rd1 : std_logic_vector(15 downto 0);
    signal rd2 : std_logic_vector(15 downto 0); 
    
    -- Signals for connecting to the MainControl component
    signal tb_Instr_maincontrol : std_logic_vector(15 downto 0) := (others => '0');
    signal tb_RegDst_maincontrol, tb_ExtOp_maincontrol, tb_ALUSrc_maincontrol, tb_Branch_maincontrol,
           tb_Jump_maincontrol, tb_MemWrite_maincontrol, tb_MemtoReg_maincontrol, tb_RegWrite_maincontrol,
           tb_BrNE_maincontrol : std_logic;
    signal tb_ALUOp_maincontrol : std_logic_vector(1 downto 0);
    
    -- Signals for connecting to the EX component 
    signal tb_RD1_ex, tb_RD2_ex, tb_Ext_Imm_ex, tb_next_addr_ex, tb_AluRes_ex, tb_branchAddress_ex : std_logic_vector(15 downto 0);
    signal tb_AluSrc_ex, tb_sa_ex, tb_zero_ex : std_logic;
    signal tb_func_ex : std_logic_vector(2 downto 0);
    signal tb_AluOp_ex : std_logic_vector(1 downto 0);
    
    -- Signals for connecting to the MEM component
    signal tb_MemWrite_mem : std_logic;
    signal tb_AluResIn_mem, tb_RD2_mem, tb_AluResOut_mem, tb_MemData_mem : std_logic_vector(15 downto 0);
    signal tb_clk_mem, tb_en_mem : std_logic;

begin
    -- MPG component instantiation
    uut_mpg: MPG port map (
        input => tb_input_mpg,
        clk => tb_clk_mpg,
        enable => tb_enable_mpg
    );

    -- IFetch component instantiation
    uut_ifetch: IFetch port map (
        jump => tb_jump_ifetch,
        jumpAddress => tb_jumpAddress_ifetch,
        PCSrc => tb_PCSrc_ifetch,
        BranchAddress => tb_BranchAddress_ifetch,
        en => tb_en_ifetch,
        rst => tb_rst_ifetch,
        clk => tb_clk_ifetch,
        instr => tb_instr_ifetch,
        next_instr => tb_next_instr_ifetch
    );
    
    -- ID component instantiation
    uut_id: ID port map (
          RegWrite => RegWrite,
          Instr => Instr,
          RegDst => RegDst,
          clk => clk,
          en => en,
          ExtOp => ExtOp,
          wd => wd,
          ext_imm => ext_imm,
          func => func,
          sa => sa,
          rd1 => rd1,
          rd2 => rd2
        );
        
    -- MainControl component instantiation
    uut_maincontrol: MainControl port map (
        Instr => tb_Instr_maincontrol,
        RegDst => tb_RegDst_maincontrol,
        ExtOp => tb_ExtOp_maincontrol,
        ALUSrc => tb_ALUSrc_maincontrol,
        Branch => tb_Branch_maincontrol,
        Jump => tb_Jump_maincontrol,
        MemWrite => tb_MemWrite_maincontrol,
        MemtoReg => tb_MemtoReg_maincontrol,
        RegWrite => tb_RegWrite_maincontrol,
        BrNE => tb_BrNE_maincontrol,
        ALUOp => tb_ALUOp_maincontrol
    );
    
    -- EX component instantiation
    uut_ex: EX port map (
        RD1 => tb_RD1_ex,
        RD2 => tb_RD2_ex,
        AluSrc => tb_AluSrc_ex,
        Ext_Imm => tb_Ext_Imm_ex,
        sa => tb_sa_ex,
        func => tb_func_ex,
        AluOp => tb_AluOp_ex,
        next_addr => tb_next_addr_ex,
        zero => tb_zero_ex,
        AluRes => tb_AluRes_ex,
        branchAddress => tb_branchAddress_ex
    );
    
    -- MEM component instantiation
    uut_mem: MEM port map (
        MemWrite => tb_MemWrite_mem,
        AluResIn => tb_AluResIn_mem,
        RD2 => tb_RD2_mem,
        clk => tb_clk_mem,
        en => tb_en_mem,
        AluResOut => tb_AluResOut_mem,
        MemData => tb_MemData_mem
    );

    -- Clock process for MPG 
    clk_process_mpg : process
    begin
        loop
            tb_clk_mpg <= not tb_clk_mpg;
            wait for 10 ns;
        end loop;
    end process clk_process_mpg;

    -- Clock process for IFetch
    clk_process_ifetch : process
    begin
        loop
            tb_clk_ifetch <= not tb_clk_ifetch;
            wait for 20 ns;
        end loop;
    end process clk_process_ifetch;

    stimulus: process
    begin
        -- Test MPG component
        tb_input_mpg <= '1';
        wait for 20 ns;
        tb_input_mpg <= '0';
        
        -- Test IFetch component
        wait for 40 ns; 
        tb_jump_ifetch <= '1';
        wait for 20 ns;
        tb_jump_ifetch <= '0';
        
        -- Test ID component
        -- initialize inputs 
        RegWrite <= '0';
        Instr <= x"0000";
        RegDst <= '0';
        en <= '1'; -- enable is active
        ExtOp <= '0';
        wd <= (others => '0');
        
        wait for 100 ns;	
      
        Instr <= x"208A"; -- addi $1,$0,10
        wait for 20 ns; 
        -- The expected values are rd1=x"0000" rd2=x"0000" sa='1' func="111" ext_imm=x"000f"
        
        -- Test MainControl component
        tb_Instr_maincontrol <= x"208A"; -- addi $1,$0,10
        wait for 20 ns; 
        -- The expected values are ExtOp<='1';ALUSrc<='1';RegWrite<='1'; ALUOp<="01";
        
        -- Test EX component
        -- Initialize inputs for EX component
        tb_RD1_ex <= (others => '0');
        tb_RD2_ex <= (others => '0');
        tb_AluSrc_ex <= '0';
        tb_Ext_Imm_ex <= (others => '0');
        tb_sa_ex <= '0';
        tb_func_ex <= (others => '0');
        tb_AluOp_ex <= (others => '0');
        tb_next_addr_ex <= (others => '0');
        
        wait for 100 ns; 
        
        -- Apply values to test
        tb_RD1_ex <= "0000000000001010"; 
        tb_RD2_ex <= "0000000000000101";
        tb_AluSrc_ex <= '1'; 
        tb_Ext_Imm_ex <= "0000000000010100"; 
        tb_sa_ex <= '0';
        tb_func_ex <= "010"; 
        tb_AluOp_ex <= "10"; 
        tb_next_addr_ex <= "0000000000001100"; 
        
        wait for 20 ns;
        -- The expected values are zero=0 AluRes="fff6" branchAddress="0020"
        
        -- Test MEM component
        -- Initialize inputs for MEM component
        tb_MemWrite_mem <= '0'; 
        tb_AluResIn_mem <= (others => '0');
        tb_RD2_mem <= (others => '0');
        tb_clk_mem <= '0'; -- Initial clock state
        tb_en_mem <= '1'; -- Enable signal
        
        wait for 100 ns; 
        
        -- Apply values to test
        tb_MemWrite_mem <= '0'; 
        tb_AluResIn_mem <= "0000000000001010"; 
        tb_RD2_mem <= "0000000000000101"; 
        tb_clk_mem <= '0'; -- Initial clock state
        tb_en_mem <= '1'; -- Enable signal
        
        -- Generate clock signal
        tb_clk_mem <= not tb_clk_mem after 10 ns;
        
        wait for 20 ns; 
        -- The expected values are AluResOut=x"000A" and MemData=undefined
            
        wait; 
    end process stimulus;
end Behavioral;
