-- Entity to output the RGB value of a pixel at a memory location

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity Px_Read is
	Port (	data : in std_logic_vector(15 downto 0);	-- SRAM data bus
			
			clk : in std_logic;
			Reset : in std_logic;

			go : in std_logic;	-- start execution
			baseAddr : in std_logic_vector(17 downto 0);	-- address of pixel value

			addr : out std_logic_vector(17 downto 0);	-- SRAM addr bus
			ce, ub, lb, oe, we : out std_logic;	-- SRAM stuff

			busy : out std_logic;	-- high during memory read
			R, G, B: out std_logic_vector(7 downto 0));	-- output pixel values
end Px_Read;

architecture Behavioral of Px_Read is
	signal Rin, Gin, Bin : std_logic_vector(7 downto 0);
	signal curAddr : std_logic_vector(17 downto 0);

	type ctrl_state is (Halted, R1_1, R1_2, R2_1, R2_2);
	signal state : ctrl_state;
begin
	ce <= '0';
	ub <= '0';
	lb <= '0';

	R <= Rin;
	G <= Gin;
	B <= Bin;

	process(clk, Reset)
	begin
		if (Reset = '1') then
			addr <= conv_std_logic_vector(0, 18);
			oe <= '1';
			we <= '1';
			Rin <= conv_std_logic_vector(0, 8);
			Gin <= conv_std_logic_vector(0, 8);
			Bin <= conv_std_logic_vector(0, 8);
			busy <= '0';
		elsif (rising_edge(clk)) then
			oe <= '1';
			we <= '1';

			case state is
				when Halted =>
					if (go = '1') then
						curAddr <= baseAddr;	-- save address
						addr <= baseAddr;	-- memory output at addr
						oe <= '0';
						busy <= '1';

						state <= R1_1;
					else
						addr <= conv_std_logic_vector(0, 18);
						busy <= '0';

						state <= Halted;
					end if;
				when R1_1 =>
					addr <= curAddr;
					oe <= '0';
					Rin <= data(15 downto 8);
					Gin <= data(7 downto 0);

					state <= R1_2;
				when R1_2 =>
					addr <= curAddr + conv_std_logic_vector(1, 18);
					oe <= '0';
					Rin <= data(15 downto 8);
					Gin <= data(7 downto 0);
					curAddr <= curAddr + conv_std_logic_vector(1, 18);

					state <= R2_1;
				when R2_1 =>
					addr <= curAddr;
					oe <= '0';
					Bin <= data(15 downto 8);

					state <= R2_2;
				when R2_2 =>
					addr <= conv_std_logic_vector(0, 18);
					Bin <= data(15 downto 8);

					busy <= '0';

					state <= Halted;
			end case;
		end if;
	end process;
end Behavioral;
