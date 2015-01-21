library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

entity Keyboard is
	Port ( 	clk : in std_logic;
			psClk : in std_logic;
			psData : in std_logic;
			reset : in std_logic;
			keyCode : buffer std_logic_vector(7 downto 0);
			keyDown : out std_logic;
			keyUp : out std_logic);
end Keyboard;

architecture Behavioral of Keyboard is
	signal divClkCount : std_logic_vector(8 downto 0);

	signal psState : std_logic_vector(3 downto 0);
	signal shiftReg : std_logic_vector(10 downto 0);

	-- edge detector for ps2 clock
	signal clkSave : std_logic;
	signal oldCode : std_logic_vector(7 downto 0);
begin
	process (reset, clk)
		variable newCodeVar : std_logic_vector(7 downto 0);
	begin
		if (reset = '1') then
			divClkCount <= conv_std_logic_vector(0, 9);
			psState <= "0000";
			shiftReg <= conv_std_logic_vector(0, 11);
			clkSave <= '0';

			keyCode <= conv_std_logic_vector(0, 8);
			oldCode <= conv_std_logic_vector(0, 8);
			keyDown <= '0';
			keyUp <= '0';
		elsif (rising_edge(clk)) then
			keyDown <= '0';
			keyUp <= '0';

			divClkCount <= divClkCount + "000000001";
			if (divClkCount = "111111111") then
				-- sample ps2 clock
				clkSave <= psClk;

				if (psClk = '0' and clkSave = '1') then
					-- falling edge of ps2 clock
					shiftReg <= psData & shiftReg(10 downto 1);

					if (psState = 10) then
						if (psData = '1' and xor_reduce(shiftReg(10 downto 2)) = '1' and shiftReg(1) = '0') then
							newCodeVar := shiftReg(9 downto 2);
							keyCode <= newCodeVar;
							oldCode <= keyCode;

							if (keyCode = x"F0") then	-- current code is F0, new code must be a released key
								keyUp <= '1';
							elsif ((oldCode = x"F0" or keyCode /= newCodeVar) and newCodeVar /= x"F0") then
								-- can't just use keyCode /= newCodeVar because might be same key pressed
								keyDown <= '1';
							end if;

							psState <= "0000";
						end if;
					else
						psState <= psState + "0001";
					end if;
				end if;
			end if;
		end if;
	end process;
end Behavioral;
