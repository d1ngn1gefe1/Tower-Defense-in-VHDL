library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library work;
use work.Constants.all;

entity Controller is
	Port ( 	clk : in std_logic;
			reset : in std_logic;
			keyCode : in std_logic_vector(7 downto 0);
			keyDown : in std_logic;

			curBaseElem : in BaseElem;

			-- control sigs from enemies
			escaped : in std_logic;
			killed : in std_logic_vector(3 downto 0);

			-- control sigs from towers
            curDamage : in std_logic_vector(14 downto 0);
            curRng : in std_logic_vector(11 downto 0);
            curSpeed : in std_logic_vector(1 downto 0);
            numTwrs : in std_logic_vector(5 downto 0);

			-- control sigs to enemies
			killAll : out std_logic;
			startLvl : out std_logic;

			-- control sigs for towers
			placeTwr : out std_logic;
            upgrade : out UpgradeType;

			-- control sigs to grid
			placeItem : out std_logic;
			newItem : out GridElem;
			moveCursor : out std_logic;
			moveDir : out Direction;
			changeMod : out std_logic;
			newMod : out BaseElem;
			incLvl : out std_logic;

			gold : out std_logic_vector(15 downto 0);
			level : out std_logic_vector(7 downto 0);
			lives : out std_logic_vector(4 downto 0));
end Controller;

architecture Behavioral of Controller is
	signal myGold : std_logic_vector(15 downto 0);
	signal myLevel : std_logic_vector(7 downto 0);
	signal myLives : std_logic_vector(4 downto 0);
	
	signal enemsLeft : std_logic_vector(4 downto 0);

	-- counts from 0 to max value before level starts. during level, stays at max value.
	signal prepCntr : std_logic_vector(26 downto 0);	-- 50MHz / 2^27 ~= 2.5s for player to prepare
begin
	gold <= myGold;
	level <= myLevel;
	lives <= myLives;

	process (reset, clk)
	begin
		if (reset = '1') then
			myGold <= tov(START_GOLD, 16);
			myLevel <= tov(0, 8);
			myLives <= tov(START_LIVES, 5);
			enemsLeft <= tov(0, 5);
			prepCntr <= tov(0, 27);

			killAll <= '0';
			startLvl <= '0';
		elsif (rising_edge(clk)) then
			killAll <= '0';
			startLvl <= '0';

			placeItem <= '0';
			newItem <= get_base_elem(Empty);
			moveCursor <= '0';
			moveDir <= UpDir;
			changeMod <= '0';
			newMod <= Empty;
			incLvl <= '0';

			placeTwr <= '0';
			upgrade <= BasicCreate;

			if (prepCntr < tov(-1, 27)) then
				case prepCntr is
					when tov(0, 27) =>
						-- start of prep time
						killAll <= '1';
						enemsLeft <= tov(NUM_ENEMIES, 5);
					when tov(-2, 27) =>
						startLvl <= '1';
					when others =>
						null;
				end case;
				prepCntr <= prepCntr + tov(1, 27);
			end if;

			if (killed /= tov(0, 4) or escaped = '1') then
				if (enemsLeft <= ("0" & killed) + ("0000" & escaped)) then
					prepCntr <= tov(0, 27);
					myLevel <= myLevel + tov(1, 8);
				end if;
				enemsLeft <= enemsLeft - ("0" & killed) - ("0000" & escaped);

				if (killed /= tov(0, 4)) then
					myGold <= myGold + killed * get_gold_per_enemy(myLevel);
				end if;
				if (escaped = '1') then
					myLives <= myLives - tov(1, 5);
				end if;
			end if;

			if (keyDown = '1') then
				case keyCode is
					when KEY_W =>
						moveCursor <= '1';
						moveDir <= UpDir;
					when KEY_A =>
						moveCursor <= '1';
						moveDir <= LeftDir;
					when KEY_S =>
						moveCursor <= '1';
						moveDir <= DownDir;
					when KEY_D =>
						moveCursor <= '1';
						moveDir <= RightDir;
					when KEY_SPACE =>	-- Space
						if (numTwrs < tov(MAX_TOWERS, 6) and myGold >= tov(BASIC_TOWER_COST, 16) and can_place_twr(curBaseElem)) then
							myGold <= myGold - tov(BASIC_TOWER_COST, 16);
							placeItem <= '1';
							newItem <= get_base_elem(BasicTower);
							placeTwr <= '1';
							upgrade <= BasicCreate;
						end if;
					when KEY_1 =>
						if (myGold >= tov(DAMAGE_UP_COST, 16) and is_tower_elem(curBaseElem) and curDamage < curDamage + tov(ADD_DAMAGE, 15)) then
							myGold <= myGold - tov(DAMAGE_UP_COST, 16);
							placeTwr <= '1';
							upgrade <= DamageUp;
							incLvl <= '1';
						end if;
					when KEY_2 =>
						if (myGold >= tov(RNG_UP_COST, 16) and is_tower_elem(curBaseElem) and curRng < curRng + tov(ADD_RNG, 12)) then
							myGold <= myGold - tov(RNG_UP_COST, 16);
							placeTwr <= '1';
							upgrade <= RangeUp;
							incLvl <= '1';
						end if;
					when KEY_3 =>
						if (myGold >= tov(SPEED_UP_COST, 16) and is_tower_elem(curBaseElem) and curSpeed /= "11") then
							myGold <= myGold - tov(SPEED_UP_COST, 16);
							placeTwr <= '1';
							upgrade <= SpeedUp;
							incLvl <= '1';
						end if;
					when others =>
						if (myGold >= tov(MOD_COST, 16) and curBaseElem = BasicTower and (keyCode = KEY_4 or keyCode = KEY_5)) then
							myGold <= myGold - tov(MOD_COST, 16);
							changeMod <= '1';
							placeTwr <= '1';
							case keyCode is
								when KEY_4 =>
									newMod <= SlowTower;
									upgrade <= SlowUp;
								when KEY_5 =>
									newMod <= PoisonTower;
									upgrade <= PoisonUp;
								when others =>
									changeMod <= '0';
									placeTwr <= '0';
							end case;
						end if;
				end case;
			end if;
		end if;
	end process;
end Behavioral;
