library ieee;
use ieee.std_logic_1164.all;

entity ldi_tb is -- ldi R1,85
end;

architecture logic of ldi_tb is
signal clk_tb : std_logic;
signal clr_tb : std_logic;
signal IncPC_tb	: std_logic;
signal MDRRead_tb	: std_logic;
signal MDRWrite_tb : std_logic;
signal Baout_tb	: std_logic;
signal Gra_tb		: std_logic;
signal Grb_tb		: std_logic;
signal Grc_tb		: std_logic;
signal Rin_tb		: std_logic;
signal Rout_tb		: std_logic;
signal inport_tb	: std_logic_vector(31 downto 0);
signal outport_tb	: std_logic_vector(31 downto 0);
signal conffout_tb	: std_logic;
signal ADD_tb			: std_logic_vector(4 downto 0);
signal encoderIn_tb	: std_logic_vector(15 downto 0);
signal RegEnable_tb	: std_logic_vector(15 downto 0);
signal BusMuxOut_tb	: std_logic_vector(31 downto 0);
signal R0out_tb		: std_logic_vector(31 downto 0);
signal R1out_tb		: std_logic_vector(31 downto 0);
signal R2out_tb		: std_logic_vector(31 downto 0);
signal HIout_tb		: std_logic_vector(31 downto 0);
signal LOout_tb		: std_logic_vector(31 downto 0);
signal IRout_tb		: std_logic_vector(31 downto 0);
signal Zout_tb			: std_logic_vector(63 downto 0);
signal dummyInput_tb : std_logic_vector(31 downto 0);

--signal md_tb: std_logic_vector(31 downto 0);
--signal mar_tb:  std_logic_vector(31 downto 0);

type	state is(default, Reg_load1, Reg_load2, Reg_load3, T0, T1, T2, T3, T4, T5, T6, T7);
signal	present_state: State := default;

component datapath
	PORT (
		
		clk: in std_logic;
		clr: in std_logic;
		PC_plus: in std_logic;
		
		encoder_In: in std_logic_vector(15 downto 0);
		reg_enable: in std_logic_vector(15 downto 0);
		
		dummyInput	: in std_logic_vector(31 downto 0);
		MDR_read: in std_logic;
		MDR_write: in std_logic;
	
		baout: in std_logic;
		Gra: in std_logic;
		Grb: in std_logic;
		Grc: in std_logic;
		Rin: in std_logic;
		Rout:in std_logic;
		ALU_sel: in std_logic_vector(4 downto 0);
		in_port: in std_logic_vector (31 downto 0);
		out_port: out std_logic_vector (31 downto 0);
		conff_out: out std_logic;
		
		BusMuxOut: out std_logic_vector(31 downto 0);
		----------------------------------------------
		R0out	: out std_logic_vector(31 downto 0);
		R1out	: out std_logic_vector(31 downto 0);
		R2out	: out std_logic_vector(31 downto 0);
		HIout	: out std_logic_vector(31 downto 0);
		LOout	: out std_logic_vector(31 downto 0);
		IRout	: out std_logic_vector(31 downto 0);
		Zout: out std_logic_vector(63 downto 0)
	);
end component;

begin
datapathTest : datapath port map (clk_tb, clr_tb, IncPC_tb, encoderIn_tb, RegEnable_tb, dummyInput_tb, MDRRead_tb, MDRWrite_tb, Baout_tb, Gra_tb, Grb_tb, 
Grc_tb, Rin_tb, Rout_tb, ADD_tb, inport_tb, outport_tb, conffout_tb, BusMuxOut_tb, R0out_tb, R1out_tb, R2out_tb, HIout_tb, LOout_tb, IRout_tb, Zout_tb);

clk_process: process
begin
	clk_tb <= '1', '0' after 10 ns;--10
	wait for 20 ns;--20
end process clk_process;

process(clk_tb)
begin
	if(clk_tb'EVENT and clk_tb = '1') then
		case present_state is
			when default =>
				present_state <= Reg_load1;
			when Reg_load1 =>
				present_state <= T0;
			when T0 =>
				present_state <= T1;
			when T1 =>
				present_state <= T2;
			when T2 =>
				present_state <= T3;
			when T3 =>
				present_state <= T4;
			when T4 =>
				present_state <= T5;
		
			when others =>
		end case;
	end if;
end process;

process (present_state)
begin
	case present_state is

		when default =>
			clr_tb <= '1';
			IncPC_tb <= '0';
			MDRRead_tb <= '0';
			MDRWrite_tb <= '0';
			Baout_tb <= '0';
			Gra_tb <= '0';
			Grb_tb <= '0';
			Grc_tb <= '0';
			Rin_tb <= '0';
			Rout_tb <= '0';
			inport_tb <= (others => '0');
			outport_tb <= (others => '0');
			conffout_tb <= '0';
			ADD_tb <= (others => '0');
			encoderIn_tb <= (others => '0');
			RegEnable_tb <= (others => '0');
			
		when Reg_load1 =>
			dummyInput_tb <= x"00000000"; --ldi R1, $85; 
			RegEnable_tb <= (2  => '1', others => '0');-- pc enable 
			encoderIn_tb <= (8 => '1', others => '0'); --all zeros
			
		when T0 =>
			encoderIn_tb <= (4 => '1', others => '0'); --PCout signal to the bus encoder
			RegEnable_tb <= (5 => '1', 7 => '1', others => '0'); -- MAR enable and Z enable 
			IncPC_tb <= '1'; -- a signal the alu for increment pc 
		
		when T1 =>
			encoderIn_tb <= (3 => '1', others => '0'); --Zlow --(the incremented pc address)
			RegEnable_tb <= (2 => '1', 4 => '1', others => '0'); --PC enable, MDR enable 
			IncPC_tb <= '0';
			MDRRead_tb <= '1'; -- read from the memory for the first instruction in memory (000000...)
			
		when T2 =>
			MDRRead_tb <= '0'; -- read from the bus 
			encoderIn_tb <= (5 => '1', others => '0');--MDR out 
			RegEnable_tb <= (3 => '1', others => '0');-- IR in (put the content in memory to IR)
			
		when T3 =>
			Grb_tb <= '1';
			Baout_tb <= '1';
			encoderIn_tb <= (others => '0'); 
			RegEnable_tb <= (6 => '1', others => '0'); -- Yin (Y get loaded with all zeros)
			
		when T4 =>
			Grb_tb <= '0';
			Baout_tb <= '0';
			encoderIn_tb <= (7 => '1', others => '0');-- Cout (take C extended as input)
			ADD_tb <= "00011"; -- in this case is 
			RegEnable_tb <= (7 => '1', others => '0');--Zin (load the C+R0 in to Z)
			
		when T5 =>
			Gra_tb <= '1'; -- select which register the content should be put in
			Rin_tb <= '1'; --- enable register 
			encoderIn_tb <= (3 => '1', others => '0'); --Zlow --3 
			RegEnable_tb <= (others=>'0');

		when others =>

	end case;
end process;
end architecture;