library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.Constants.all;

entity Towers is 
	port (	clk : in std_logic;
			reset : in std_logic;

            enemArr : in EnemyArr;

			-- control signals to place/upgrade tower at cursor
            placeTwr : in std_logic;
            upgrade : in UpgradeType;
            cursorI : in std_logic_vector(7 downto 0);

			-- control signals that go straight to grid
			changeDir : out std_logic;
			newDir : out Direction;
			changeAnim : out std_logic;
			cmdI : out std_logic_vector(7 downto 0);

			-- control signals that go straight to enemies
			attackI : out std_logic_vector(4 downto 0);
			damage : out std_logic_vector(14 downto 0);
            statusMod : out EnemyStatus;

            twrArr : out TowerArr;

            curDamage : out std_logic_vector(14 downto 0);
            curRng : out std_logic_vector(11 downto 0);
            curSpeed : out std_logic_vector(1 downto 0);

            numTwrs : out std_logic_vector(5 downto 0));
end Towers;

architecture Behavioral of Towers is 
	signal myTwrArr : TowerArr;

    type UpStateType is (NoUpgrade, Upgrading);
    signal upState : UpStateType;
    signal placeI : std_logic_vector(7 downto 0);
    signal myUpgrade : UpgradeType;

    signal myCurDamage : std_logic_vector(14 downto 0);
    signal myCurRng : std_logic_vector(11 downto 0);
    signal myCurSpeed : std_logic_vector(1 downto 0);

    signal myNumTwrs : std_logic_vector(5 downto 0);
begin
    twrArr <= myTwrArr;
    curDamage <= myCurDamage;
    curRng <= myCurRng;
    curSpeed <= myCurSpeed;
    numTwrs <= myNumTwrs;

    cmdI <= myTwrArr(MAX_TOWERS - 1).gridI;

	process (reset, clk)
        variable towerPos : Position;
        variable towerPxPos : PxPos;
        variable enemPxPos : PxPos;

        variable enemOffX, enemOffY : std_logic_vector(9 downto 0);

        variable offDiff, offSum : std_logic_vector(10 downto 0);
	begin
		if (reset = '1') then
            upState <= NoUpgrade;
            for i in 0 to MAX_TOWERS - 1 loop
                myTwrArr(i).gridI <= UNUSED_GRID_I;
            end loop;
            damage <= tov(0, 15);
            attackI <= tov(0, 5);
            statusMod <= Normal;
			changeDir <= '0';
			changeAnim <= '0';

            myNumTwrs <= tov(0, 6);
		elsif (rising_edge(clk)) then
            damage <= tov(0, 15);
            attackI <= tov(0, 5);
            statusMod <= Normal;
			changeDir <= '0';
			changeAnim <= '0';

            -- always shift
            myTwrArr(MAX_TOWERS - 1) <= myTwrArr(0);
            myTwrArr(MAX_TOWERS - 2 downto 0) <= myTwrArr(MAX_TOWERS - 1 downto 1);

            if (myTwrArr(0).gridI = cursorI) then
                myCurDamage <= myTwrArr(0).damage;
                myCurRng <= myTwrArr(0).rng;
                myCurSpeed <= myTwrArr(0).speed;
            end if;

            case upState is
                when Upgrading =>
                    if (myUpgrade = BasicCreate and myTwrArr(0).gridI = UNUSED_GRID_I) then
                        myTwrArr(MAX_TOWERS - 1).gridI <= placeI;
                        myTwrArr(MAX_TOWERS - 1).rng <= tov(START_RNG, 12);
                        myTwrArr(MAX_TOWERS - 1).damage <= tov(START_DAMAGE, 15);
                        myTwrArr(MAX_TOWERS - 1).speed <= tov(0, 2);
                        myTwrArr(MAX_TOWERS - 1).shotCntr <= tov(-1, 21);
                        myTwrArr(MAX_TOWERS - 1).modifier <= BasicMod;
                        upState <= NoUpgrade;
                    elsif (myTwrArr(0).gridI = placeI) then
                        case myUpgrade is
                            when RangeUp =>
                                myTwrArr(MAX_TOWERS - 1).rng <= myTwrArr(0).rng + tov(ADD_RNG, 12);
                            when DamageUp =>
                                if (myTwrArr(0).modifier = BasicMod) then
                                    myTwrArr(MAX_TOWERS - 1).damage <= myTwrArr(0).damage + tov(ADD_DAMAGE * 2, 15);
                                else
                                    myTwrArr(MAX_TOWERS - 1).damage <= myTwrArr(0).damage + tov(ADD_DAMAGE, 15);
                                end if;
                            when SpeedUp =>
                                myTwrArr(MAX_TOWERS - 1).speed <= myTwrArr(0).speed + tov(1, 2);
                            when SlowUp =>
                                myTwrArr(MAX_TOWERS - 1).modifier <= SlowMod;
                            when PoisonUp =>
                                myTwrArr(MAX_TOWERS - 1).modifier <= PoisonMod;
                            when others =>
                                null;
                        end case;
                        upState <= NoUpgrade;
                    end if;
                when NoUpgrade =>
                    if (placeTwr = '1') then
                        myUpgrade <= upgrade;
                        placeI <= cursorI;
                        upState <= Upgrading;
                        if (upgrade = BasicCreate) then
                            myNumTwrs <= myNumTwrs + tov(1, 6);
                        end if;
                    elsif (myTwrArr(0).gridI /= UNUSED_GRID_I) then
                        towerPos := i_to_pos(myTwrArr(0).gridI);
                        towerPxPos.x := towerPos.x * tov(30, 5) + tov(15, 9);
                        towerPxPos.y := towerPos.y * tov(30, 5) + tov(15, 9);

                        if (myTwrArr(0).shotCntr /= tov(-1, 21)) then
                            myTwrArr(MAX_TOWERS - 1).shotCntr <= myTwrArr(0).shotCntr + tov(1, 21);
                            if ((myTwrArr(0).speed = "01" and myTwrArr(0).shotCntr = tov(1048576, 21))
                                    or (myTwrArr(0).speed = "10" and myTwrArr(0).shotCntr = tov(699051, 21))
                                    or (myTwrArr(0).speed = "11" and myTwrArr(0).shotCntr = tov(524288, 21))) then
                                -- prematurely end counting based on speed: speed 1 => 2x as fast, speed 2 => 3x as fast, etc
                                myTwrArr(MAX_TOWERS - 1).shotCntr <= tov(-1, 21);
                            end if;
                        end if;

                        if (myTwrArr(0).shotCntr = tov(-1, 21)) then
                            for i in 0 to NUM_ENEMIES - 1 loop
                                -- find new enemy
                                if (enemArr(i).status = Dead) then
                                    next;
                                end if;

                                enemPxPos.x := enemArr(i).pos.x + tov(15, 9);  -- since enemArr(i).pos refers to top left
                                enemPxPos.y := enemArr(i).pos.y + tov(15, 9);

                                enemOffX := ("0" & enemPxPos.x) - ("0" & towerPxPos.x);
                                enemOffY := ("0" & enemPxPos.y) - ("0" & towerPxPos.y);

                                if (square_vec(signed(enemOffX(9 downto 3))) + square_vec(signed(enemOffY(9 downto 3))) <= unsigned(myTwrArr(0).rng)) then
                                    changeAnim <= '1';

                                    offDiff := sxt(enemOffY, 11) - sxt(enemOffX, 11);
                                    offSum := sxt(enemOffY, 11) + sxt(enemOffX, 11);

                                    changeDir <= '1';
                                    if (offDiff(10) = '1') then
                                        if (offSum(10) = '1') then
                                            newDir <= UpDir;
                                        else
                                            newDir <= RightDir;
                                        end if;
                                    else
                                        if (offSum(10) = '1') then
                                            newDir <= LeftDir;
                                        else
                                            newDir <= DownDir;
                                        end if;
                                    end if;

                                    myTwrArr(MAX_TOWERS - 1).shotCntr <= tov(0, 21);
                                    myTwrArr(MAX_TOWERS - 1).shotVelo.x <= enemOffX(9 downto 3); -- divide by 8 and truncate
                                    myTwrArr(MAX_TOWERS - 1).shotVelo.y <= enemOffY(9 downto 3);
                                    myTwrArr(MAX_TOWERS - 1).shotPos <= towerPxPos;

                                    attackI <= tov(i, 5);
                                    damage <= myTwrArr(0).damage;
                                    case myTwrArr(0).modifier is
                                        when SlowMod =>
                                            statusMod <= Slow;
                                        when PoisonMod =>
                                            statusMod <= Poison;
                                        when others =>
                                            statusMod <= Normal;
                                    end case;

                                    exit;
                                end if;
                            end loop;
                        elsif (myTwrArr(0).shotCntr(15 downto 0) = tov(0, 16) and myTwrArr(0).shotCntr(20 downto 19) = tov(0, 2)) then
                            myTwrArr(MAX_TOWERS - 1).shotPos.x <= myTwrArr(0).shotPos.x + sxt(myTwrArr(0).shotVelo.x, 9);
                            myTwrArr(MAX_TOWERS - 1).shotPos.y <= myTwrArr(0).shotPos.y + sxt(myTwrArr(0).shotVelo.y, 9);
                            if (myTwrArr(0).shotCntr(18 downto 16) = "100") then
                                changeAnim <= '1';
                            end if;
                        end if;
                    end if;
            end case;

--		gridI : std_logic_vector(7 downto 0);
--		rng : std_logic_vector(7 downto 0);	-- range is a keyword -_-
--		damage : std_logic_vector(7 downto 0);
--		speed : std_logic_vector(1 downto 0);
--		shotCntr : std_logic_vector(25 downto 0);	-- 50MHz / 2^26 = .75Hz
--		shotVelo : ShotVelocity;
--		shotPos : PxPos;
		end if;
	end process;
end Behavioral;
