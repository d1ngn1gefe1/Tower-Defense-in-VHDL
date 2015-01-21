library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.Constants.all;

entity Enemies is 
	port (	clk : in std_logic;
			reset : in std_logic;
			level : in std_logic_vector(7 downto 0);

			-- commands
			startLvl : in std_logic;
			killAll : in std_logic;

			attackI : in std_logic_vector(4 downto 0);
			damage : in std_logic_vector(14 downto 0);
			statusMod : in EnemyStatus;

			escaped : out std_logic;
			killed : out std_logic_vector(3 downto 0);
			enemArr : out EnemyArr;

			poke : out std_logic_vector(15 downto 0));
end Enemies;

architecture Behavioral of Enemies is 
	signal myEnemArr : EnemyArr;

	signal nextEnterI : std_logic_vector(4 downto 0);	-- index of next enemy to introduce on screen
	signal enterCntr : std_logic_vector(24 downto 0);	-- 50 MHz / 2^26 = 0.74Hz for enemy entering

	signal moveCntr : std_logic_vector(25 downto 0);

	type EnemyDestArr is array(41 downto 0) of EnemyDest;
	signal dests : EnemyDestArr;
begin
	enemArr <= myEnemArr;

	process (reset, clk)
		variable enem : Enemy;
		variable attkEnem : Enemy;
		variable newPos : Position;
		variable newDir : Direction;

		variable myKilled : std_logic_vector(3 downto 0);
	begin
		if (reset = '1') then
			enterCntr <= tov(0, 25);
			moveCntr <= tov(0, 26);
			nextEnterI <= tov(NUM_ENEMIES, 5);
			escaped <= '0';
			killed <= tov(0, 4);

			for i in 0 to NUM_ENEMIES - 1 loop
				myEnemArr(i).status <= Dead;
			end loop;

			dests(0).pos.x <= tov(0, 9);
			dests(0).pos.y <= tov(180, 9);
			dests(0).dir <= RightDir;
			dests(1).pos.x <= tov(30, 9);
			dests(1).pos.y <= tov(180, 9);
			dests(1).dir <= UpDir;
			dests(2).pos.x <= tov(30, 9);
			dests(2).pos.y <= tov(90, 9);
			dests(2).dir <= RightDir;
			dests(3).pos.x <= tov(60, 9);
			dests(3).pos.y <= tov(90, 9);
			dests(3).dir <= UpDir;
			dests(4).pos.x <= tov(60, 9);
			dests(4).pos.y <= tov(60, 9);
			dests(4).dir <= RightDir;
			dests(5).pos.x <= tov(90, 9);
			dests(5).pos.y <= tov(60, 9);
			dests(5).dir <= UpDir;
			dests(6).pos.x <= tov(90, 9);
			dests(6).pos.y <= tov(30, 9);
			dests(6).dir <= RightDir;
			dests(7).pos.x <= tov(120, 9);
			dests(7).pos.y <= tov(30, 9);
			dests(7).dir <= UpDir;
			dests(8).pos.x <= tov(120, 9);
			dests(8).pos.y <= tov(0, 9);
			dests(8).dir <= RightDir;
			dests(9).pos.x <= tov(330, 9);
			dests(9).pos.y <= tov(0, 9);
			dests(9).dir <= DownDir;
			dests(10).pos.x <= tov(330, 9);
			dests(10).pos.y <= tov(30, 9);
			dests(10).dir <= RightDir;
			dests(11).pos.x <= tov(360, 9);
			dests(11).pos.y <= tov(30, 9);
			dests(11).dir <= DownDir;
			dests(12).pos.x <= tov(360, 9);
			dests(12).pos.y <= tov(60, 9);
			dests(12).dir <= RightDir;
			dests(13).pos.x <= tov(390, 9);
			dests(13).pos.y <= tov(60, 9);
			dests(13).dir <= DownDir;
			dests(14).pos.x <= tov(390, 9);
			dests(14).pos.y <= tov(90, 9);
			dests(14).dir <= RightDir;
			dests(15).pos.x <= tov(420, 9);
			dests(15).pos.y <= tov(90, 9);
			dests(15).dir <= DownDir;
			dests(16).pos.x <= tov(420, 9);
			dests(16).pos.y <= tov(150, 9);
			dests(16).dir <= RightDir;
			dests(17).pos.x <= tov(450, 9);
			dests(17).pos.y <= tov(150, 9);
			dests(17).dir <= DownDir;
			dests(18).pos.x <= tov(450, 9);
			dests(18).pos.y <= tov(270, 9);
			dests(18).dir <= LeftDir;
			dests(19).pos.x <= tov(270, 9);
			dests(19).pos.y <= tov(270, 9);
			dests(19).dir <= UpDir;
			dests(20).pos.x <= tov(270, 9);
			dests(20).pos.y <= tov(210, 9);
			dests(20).dir <= LeftDir;
			dests(21).pos.x <= tov(180, 9);
			dests(21).pos.y <= tov(210, 9);
			dests(21).dir <= DownDir;
			dests(22).pos.x <= tov(180, 9);
			dests(22).pos.y <= tov(270, 9);
			dests(22).dir <= LeftDir;
			dests(23).pos.x <= tov(0, 9);
			dests(23).pos.y <= tov(270, 9);
			dests(23).dir <= DownDir;
			dests(24).pos.x <= tov(0, 9);
			dests(24).pos.y <= tov(330, 9);
			dests(24).dir <= RightDir;
			dests(25).pos.x <= tov(30, 9);
			dests(25).pos.y <= tov(330, 9);
			dests(25).dir <= DownDir;
			dests(26).pos.x <= tov(30, 9);
			dests(26).pos.y <= tov(360, 9);
			dests(26).dir <= RightDir;
			dests(27).pos.x <= tov(60, 9);
			dests(27).pos.y <= tov(360, 9);
			dests(27).dir <= DownDir;
			dests(28).pos.x <= tov(60, 9);
			dests(28).pos.y <= tov(390, 9);
			dests(28).dir <= RightDir;
			dests(29).pos.x <= tov(90, 9);
			dests(29).pos.y <= tov(390, 9);
			dests(29).dir <= DownDir;
			dests(30).pos.x <= tov(90, 9);
			dests(30).pos.y <= tov(420, 9);
			dests(30).dir <= RightDir;
			dests(31).pos.x <= tov(120, 9);
			dests(31).pos.y <= tov(420, 9);
			dests(31).dir <= DownDir;
			dests(32).pos.x <= tov(120, 9);
			dests(32).pos.y <= tov(450, 9);
			dests(32).dir <= RightDir;
			dests(33).pos.x <= tov(330, 9);
			dests(33).pos.y <= tov(450, 9);
			dests(33).dir <= UpDir;
			dests(34).pos.x <= tov(330, 9);
			dests(34).pos.y <= tov(420, 9);
			dests(34).dir <= RightDir;
			dests(35).pos.x <= tov(360, 9);
			dests(35).pos.y <= tov(420, 9);
			dests(35).dir <= UpDir;
			dests(36).pos.x <= tov(360, 9);
			dests(36).pos.y <= tov(390, 9);
			dests(36).dir <= RightDir;
			dests(37).pos.x <= tov(390, 9);
			dests(37).pos.y <= tov(390, 9);
			dests(37).dir <= UpDir;
			dests(38).pos.x <= tov(390, 9);
			dests(38).pos.y <= tov(360, 9);
			dests(38).dir <= RightDir;
			dests(39).pos.x <= tov(420, 9);
			dests(39).pos.y <= tov(360, 9);
			dests(39).dir <= UpDir;
			dests(40).pos.x <= tov(420, 9);
			dests(40).pos.y <= tov(330, 9);
			dests(40).dir <= RightDir;
			dests(41).pos.x <= tov(0, 9);	-- need dummy one at end
			dests(41).pos.y <= tov(0, 9);
			dests(41).dir <= RightDir;
			poke <= x"FFFF";
		elsif (rising_edge(clk)) then
			escaped <= '0';
			myKilled := tov(0, 4);

			if (startLvl = '1') then
				nextEnterI <= tov(0, 5);
				enterCntr <= tov(0, 25);
				moveCntr <= tov(0, 26);
			elsif (killAll = '1') then
				for i in 0 to NUM_ENEMIES - 1 loop
					myEnemArr(i).status <= Dead;
				end loop;
			else
				if (nextEnterI < tov(NUM_ENEMIES, 5) and enterCntr = tov(0, 25)) then
					myEnemArr(conv_integer(nextEnterI)).hp <= get_start_hp(level);
					myEnemArr(conv_integer(nextEnterI)).pos <= dests(0).pos;
					myEnemArr(conv_integer(nextEnterI)).dir <= RightDir;
					myEnemArr(conv_integer(nextEnterI)).status <= Normal;
					myEnemArr(conv_integer(nextEnterI)).anim <= '0';
					myEnemArr(conv_integer(nextEnterI)).nextI <= tov(0, 6);
					myEnemArr(conv_integer(nextEnterI)).deathCntr <= tov(0, 24);
					nextEnterI <= nextEnterI + tov(1, 5);
				end if;

				attkEnem := myEnemArr(conv_integer(attackI));
				if (damage /= tov(0, 15) and attkEnem.deathCntr = tov(0, 24)) then
					if (attkEnem.status /= Dead and attkEnem.hp <= damage) then
--						poke(7 downto 0) <= attkEnem.hp;
--						poke(12 downto 8) <= attackI;
						myEnemArr(conv_integer(attackI)).deathCntr <= tov(-1, 24);
					else
						myEnemArr(conv_integer(attackI)).hp <= attkEnem.hp - damage;
						if (statusMod /= Normal) then
							case statusMod is
								when Slow =>
									if (attkEnem.status = Poison or attkEnem.status = SlowPoison) then
										myEnemArr(conv_integer(attackI)).status <= SlowPoison;
									else
										myEnemArr(conv_integer(attackI)).status <= Slow;
									end if;
								when Poison =>
									if (attkEnem.status = Slow or attkEnem.status = SlowPoison) then
										myEnemArr(conv_integer(attackI)).status <= SlowPoison;
									else
										myEnemArr(conv_integer(attackI)).status <= Poison;
									end if;
								when SlowPoison =>
									myEnemArr(conv_integer(attackI)).status <= SlowPoison;
								when others =>
									null;
							end case;
						end if;
					end if;
				end if;

				for i in 0 to NUM_ENEMIES - 1 loop
					enem := myEnemArr(i);

					myEnemArr(i).anim <= moveCntr(23);	-- always animate enemies

					if (enem.status = Dead) then
						next;
					end if;

					if (enem.deathCntr = tov(1, 24)) then
						myEnemArr(i).status <= Dead;
						myKilled := myKilled + tov(1, 4);
						next;
					elsif (enem.deathCntr > tov(0, 24)) then
						myEnemArr(i).deathCntr <= enem.deathCntr - tov(1, 24);
					end if;

					if (((enem.status = Normal or enem.status = Poison) and moveCntr(19 downto 0) /= tov(0, 20))
						or ((enem.status = Slow or enem.status = SlowPoison) and moveCntr(20 downto 0) /= tov(0, 21))) then
						next;
					end if;

					if ((enem.status = Poison or enem.status = SlowPoison) and moveCntr = tov(0, 26)) then
						myEnemArr(i).hp <= enem.hp - tov(1, 15);
						if (enem.hp = tov(1, 15) and enem.deathCntr = tov(0, 24)) then
							myEnemArr(i).deathCntr <= tov(-1, 24);
						end if;
					end if;

					if (enem.pos.x = tov(480, 9) and enem.pos.y = tov(330, 9)) then
						myEnemArr(i).status <= Dead;
						escaped <= '1';
						next;
					end if;

					newDir := enem.dir;
					if (enem.pos = dests(conv_integer(enem.nextI)).pos) then
						newDir := dests(conv_integer(enem.nextI)).dir;
						myEnemArr(i).nextI <= enem.nextI + tov(1, 6);
					end if;
					myEnemArr(i).dir <= newDir;

					case newDir is
						when UpDir =>
							myEnemArr(i).pos.y <= enem.pos.y - tov(1, 9);
						when DownDir =>
							myEnemArr(i).pos.y <= enem.pos.y + tov(1, 9);
						when LeftDir =>
							myEnemArr(i).pos.x <= enem.pos.x - tov(1, 9);
						when RightDir =>
							myEnemArr(i).pos.x <= enem.pos.x + tov(1, 9);
					end case;
				end loop;

				enterCntr <= enterCntr + tov(1, 25);
				moveCntr <= moveCntr + tov(1, 26);
			end if;

			killed <= myKilled;
		end if;
	end process;
end Behavioral;
