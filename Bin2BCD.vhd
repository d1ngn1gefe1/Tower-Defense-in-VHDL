library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.Constants.all;

entity Bin2BCD is
    generic (   binW : integer;
                bcdW : integer);
    Port (	bin : in std_logic_vector(binW - 1 downto 0);
            bcd : out std_logic_vector(bcdW - 1 downto 0));
end Bin2BCD;

architecture Behavioral of Bin2BCD is
    constant sumW : integer := binW + bcdW;
begin
	process (bin)
        variable reg : std_logic_vector(sumW - 1 downto 0);
	begin
        reg(binW - 1 downto 0) := bin;
        reg(sumW - 1 downto binW) := tov(0, bcdW);

        for i in 0 to binW - 1 loop
            for j in 0 to bcdW / 4 - 1 loop
                if (reg(j * 4 + binW + 3 downto j * 4 + binW) > tov(4, 4)) then
                    reg(j * 4 + binW + 3 downto j * 4 + binW) := reg(j * 4 + binW + 3 downto j * 4 + binW) + tov(3, 4);
                end if;
            end loop;

            reg(sumW - 1 downto 1) := reg(sumW - 2 downto 0);
            reg(0) := '0';
        end loop;

        bcd <= reg(sumW - 1 downto binW);
	end process;
end Behavioral;
