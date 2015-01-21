---------------------------------------------------------------------------
--    Color_Mapper.vhd                                                   --
--    Stephen Kempf                                                      --
--    3-1-06                                                             --
--												 --
--    Modified by David Kesler - 7-16-08						 --
--                                                                       --
--    Spring 2013 Distribution                                             --
--                                                                       --
--    For use with ECE 385 Lab 9                                         --
--    University of Illinois ECE Department                              --
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.Constants.all;

entity Color_Mapper is
	Port (	pxlClk : in std_logic;
			reset : in std_logic;
			
			DrawX : in std_logic_vector(9 downto 0);
			DrawY : in std_logic_vector(9 downto 0);

			grid : in GridType;
			curI : in std_logic_vector(7 downto 0);
			cursorI : in std_logic_vector(7 downto 0);

			enemArr : in EnemyArr;
			twrArr : in TowerArr;
			curBaseElem : in BaseElem;

			goldBCD : in std_logic_vector(19 downto 0);
			level : in std_logic_vector(7 downto 0);
			levelBCD : in std_logic_vector(11 downto 0);
			livesBCD : in std_logic_vector(7 downto 0);

			curDamageBCD : in std_logic_vector(19 downto 0);
			curRngBCD : in std_logic_vector(15 downto 0);
			curSpeed : in std_logic_vector(1 downto 0);
			
			-- font ROM sigs
			fontData : in std_logic_vector(7 downto 0);
			fontAddr : out std_logic_vector(10 downto 0);

			-- SRAM sigs
			data : in std_logic_vector(15 downto 0);
			addr : out std_logic_vector(17 downto 0);
			ce, ub, lb, oe, we : out std_logic;

			R   : out std_logic_vector(9 downto 0);
			G	: out std_logic_vector(9 downto 0);
			B	: out std_logic_vector(9 downto 0));
end Color_Mapper;

architecture Behavioral of Color_Mapper is
	-- location signals - they refer to next pixel location to be rendered, not current, since it takes 2 cycles to read
	-- from memory. 2 clock cycles = 1 pixel clock cycle.
	signal nextCellPos : Position;	-- cell position within the 16x16 grid
	signal pxlColCntr, pxlRowCntr : std_logic_vector(4 downto 0); -- pixel offset within current cell; counts from 0-29 and repeats

	signal pxlData : std_logic_vector(15 downto 0);

	signal myFontAddr: std_logic_vector(10 downto 0);

	signal lastStatus : EnemyStatus;

	signal gameOver : std_logic;
begin
	ce <= '0';
	ub <= '0';
	lb <= '0';
	oe <= '0';
	we <= '1';

	R <= pxlData(15 downto 10) & "0000";	-- red has 6 bits, green/blue have 5 bits
	G <= pxlData(9 downto 5) & "00000";
	B <= pxlData(4 downto 0) & "00000";

	fontAddr <= myFontAddr;

	process (pxlClk, reset)
		variable nextCell : GridElem;
		variable baseAddr : std_logic_vector(17 downto 0);
		variable cursorPos : Position;

		variable nextPxlOff : PxPos;
		variable nextPxlPos : PxPos;
		
		variable shotOff : PxPos;

		variable usedData : std_logic_vector(15 downto 0);
	begin
		if (reset = '1') then
			pxlColCntr <= "00000";
			pxlRowCntr <= "00000";
			nextCellPos.x <= "0000";
			nextCellPos.y <= "0000";
			pxlData <= tov(0, 16);

			gameOver <= '0';
		elsif (rising_edge(pxlClk)) then
			lastStatus <= Normal;

			if (gameOver = '1' or livesBCD = tov(0, 8)) then
				gameOver <= '1';

				myFontAddr <= tov(0, 11);
				if (chk_font_y(DrawY, 224)) then
					if (chk_font_x(DrawX, 280)) then
						myFontAddr <= tov(71, 7) & DrawY(3 downto 0);	-- G
					elsif (chk_font_x(DrawX, 288)) then
						myFontAddr <= tov(97, 7) & DrawY(3 downto 0);	-- a
					elsif (chk_font_x(DrawX, 296)) then
						myFontAddr <= tov(109, 7) & DrawY(3 downto 0);	-- m
					elsif (chk_font_x(DrawX, 304)) then
						myFontAddr <= tov(101, 7) & DrawY(3 downto 0);	-- e
					elsif (chk_font_x(DrawX, 320)) then
						myFontAddr <= tov(111, 7) & DrawY(3 downto 0);	-- o
					elsif (chk_font_x(DrawX, 328)) then
						myFontAddr <= tov(118, 7) & DrawY(3 downto 0);	-- v
					elsif (chk_font_x(DrawX, 336)) then
						myFontAddr <= tov(101, 7) & DrawY(3 downto 0);	-- e
					elsif (chk_font_x(DrawX, 344)) then
						myFontAddr <= tov(114, 7) & DrawY(3 downto 0);	-- r
					elsif (chk_font_x(DrawX, 360)) then
						myFontAddr <= tov(58, 7) & DrawY(3 downto 0);	-- :
					elsif (chk_font_x(DrawX, 368)) then
						myFontAddr <= tov(40, 7) & DrawY(3 downto 0);	-- (
					end if;
				end if;

				if (myFontAddr /= tov(0, 11) and fontData(7 - conv_integer(DrawX(2 downto 0) - tov(1, 3))) = '1') then
					pxlData <= "1111111111111111";
				else
					pxlData <= tov(0, 16);
				end if;
			elsif (DrawX < tov(480, 10) and DrawY < tov(480, 10)) then
				-- within main board

				if (DrawX = tov(478, 10) and DrawY = tov(479, 10)) then
					-- synchronize pixel/cell counters

					-- NOTE: we reset the counters *two* cycles before DrawX = DrawY = 0, so that within this process,
					-- all counters refer to the next pixel. For example, in the next run of this process, DrawX = DrawY
					-- = 479, and all counters are 0, referring to the next pixel to be rendered.
					pxlColCntr <= "00000";
					pxlRowCntr <= "00000";
					nextCellPos.x <= "0000";
					nextCellPos.y <= "0000";
				elsif (pxlColCntr = tov(29, 5)) then
					-- new cell column
					pxlColCntr <= "00000";
					if (nextCellPos.x = tov(15, 4)) then
						-- new pixel row
						nextCellPos.x <= "0000";
						if (pxlRowCntr = tov(29, 5)) then
							-- new cell row 
							pxlRowCntr <= "00000";
							nextCellPos.y <= nextCellPos.y + "0001";
						else
							pxlRowCntr <= pxlRowCntr + "00001";
						end if;
					else
						nextCellPos.x <= nextCellPos.x + "0001";
					end if;
				else
					-- new pixel column
					pxlColCntr <= pxlColCntr + "00001";
				end if;

				nextCell := grid(conv_integer(pos_to_i(nextCellPos) - curI));

				-- display grid
				case nextCell.base is
					when DarkRedBG =>
						addr <= DARK_RED_LOC;
					when RedBG =>
						addr <= RED_LOC;
					when LightRedBG =>
						addr <= LIGHT_RED_LOC;
					when GreyBG =>
						addr <= GREY_LOC;
					when WhiteBG =>
						addr <= WHITE_LOC;
					when others =>
						-- it's a 30x30 sprite grid square, find base address and add offset into cell
						case nextCell.base is
							when Path =>
								baseAddr := PATH_LOC;
							when Empty =>
								baseAddr := EMPTY_LOC;
							when BasicTower =>
								baseAddr := tov(0, 18);
							when PoisonTower =>
								baseAddr := tov(21600, 18);
							when SlowTower =>
								baseAddr := tov(43200, 18);
							when others =>
								null;
						end case;

						case nextCell.level is
							when "01" =>
								baseAddr := baseAddr + tov(7200, 18);
							when "10" =>
								baseAddr := baseAddr + tov(14400, 18);
							when others =>
								null;
						end case;

						case nextCell.dir is
							when LeftDir =>
								baseAddr := baseAddr + tov(1800, 18);
							when RightDir =>
								baseAddr := baseAddr + tov(3600, 18);
							when UpDir =>
								baseAddr := baseAddr + tov(5400, 18);
							when others =>
								null;
						end case;

						if (nextCell.anim = '1') then
							baseAddr := baseAddr + tov(900, 18);
						end if;

						addr <= get_addr(baseAddr, pxlColCntr, pxlRowCntr);
				end case;

				nextPxlPos.x := (nextCellPos.x * tov(30, 5)) + ("0000" & pxlColCntr);
				nextPxlPos.y := (nextCellPos.y * tov(30, 5)) + ("0000" & pxlRowCntr);

				for i in 0 to MAX_TOWERS - 1 loop
					if (twrArr(i).gridI /= UNUSED_GRID_I and twrArr(i).shotCntr(20 downto 19) = "00") then
						shotOff.x := twrArr(i).shotPos.x - nextPxlPos.x;
						shotOff.y := twrArr(i).shotPos.y - nextPxlPos.y;
						
						if ((shotOff.x(8 downto 2) = "0000000" or shotOff.x(8 downto 2) = "1111111") and (shotOff.y(8 downto 2) = "0000000" or shotOff.y(8 downto 2) = "1111111")) then
							case twrArr(i).modifier is
								when BasicMod =>
									addr <= ORANGE_LOC;
								when SlowMod =>
									addr <= BLUE_LOC;
								when PoisonMod =>
									addr <= PURPLE_LOC;
							end case;
							exit;
						end if;
					end if;
				end loop;

				for i in 0 to NUM_ENEMIES - 1 loop
					if (enemArr(i).status = Dead
							or enemArr(i).pos.x > nextPxlPos.x
							or nextPxlPos.x >= enemArr(i).pos.x + tov(30, 9)
							or enemArr(i).pos.y > nextPxlPos.y
							or nextPxlPos.y >= enemArr(i).pos.y + tov(30, 9)) then
						-- enemy is dead or not at this position
						next;
					end if;

					-- get x, y offset of sprite to display
					nextPxlOff.x := nextPxlPos.x - enemArr(i).pos.x;
					nextPxlOff.y := nextPxlPos.y - enemArr(i).pos.y;
					if (enemArr(i).anim = '1') then
						nextPxlOff.x := tov(29, 9) - nextPxlOff.x;
					end if;

					if (MASK_ARR(conv_integer(level(3 downto 0)))(conv_integer(nextPxlOff.y))(conv_integer(nextPxlOff.x)) = '1') then
						baseAddr := nextPxlOff.y * tov(30, 9) + ("000000000" & nextPxlOff.x);
						-- mask says display; add base address of current level's enemies
						addr <= ENEMY_LOC + baseAddr + (tov(900, 14) * level(3 downto 0));
						case enemArr(i).status is
							when Poison =>
								lastStatus <= Poison;
							when SlowPoison =>
								lastStatus <= SlowPoison;
							when Slow =>
								lastStatus <= Slow;
							when others =>
								null;
						end case;
						exit;
					end if;
				end loop;

				-- disp cursor if needed
				if (nextCellPos = i_to_pos(cursorI)
					and (pxlColCntr < tov(CURSOR_W, 5)
						or pxlColCntr >= tov(30 - CURSOR_W, 5)
						or pxlRowCntr < tov(CURSOR_W, 5)
						or pxlRowCntr >= tov(30 - CURSOR_W, 5))) then
					addr <= BLACK_LOC;
					lastStatus <= Normal;
				end if;

				usedData := data;
				if (lastStatus /= Normal) then
					if (lastStatus = Poison or lastStatus = SlowPoison) then
						-- increase red
						if (usedData(15 downto 10) <= tov(43, 6)) then
							usedData(15 downto 10) := usedData(15 downto 10) + tov(20, 6);
						else
							usedData(15 downto 10) := tov(-1, 6);
						end if;
					end if;
					-- always increase blue
					if (usedData(4 downto 0) <= tov(21, 5)) then
						usedData(4 downto 0) := usedData(4 downto 0) + tov(10, 5);
					else
						usedData(4 downto 0) := tov(-1, 5);
					end if;
				end if;
				pxlData <= usedData;
			elsif (DrawX >= tov(480, 10) and DrawX < tov(640, 10) and DrawY < tov(480, 10)) then
				-- in menu area

				myFontAddr <= tov(0, 11);
				if (chk_font_y(DrawY, 16)) then
					-- Gold
					if (chk_font_x(DrawX, 496)) then
						myFontAddr <= G_UP & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 8)) then
						myFontAddr <= O_LO & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 16)) then
						myFontAddr <= L_LO & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 24)) then
						myFontAddr <= D_LO & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 32)) then
						myFontAddr <= COLON & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 48)) then
						myFontAddr <= (ZERO + ("000" & goldBCD(19 downto 16))) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 56)) then
						myFontAddr <= (ZERO + ("000" & goldBCD(15 downto 12))) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 64)) then
						myFontAddr <= (ZERO + ("000" & goldBCD(11 downto 8))) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 72)) then
						myFontAddr <= (ZERO + ("000" & goldBCD(7 downto 4))) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 80)) then
						myFontAddr <= (ZERO + ("000" & goldBCD(3 downto 0))) & DrawY(3 downto 0);
					end if;
				elsif (chk_font_y(DrawY, 32)) then
					-- Level
					if (chk_font_x(DrawX, 496)) then
						myFontAddr <= L_UP & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 8)) then
						myFontAddr <= E_LO & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 16)) then
						myFontAddr <= V_LO & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 24)) then
						myFontAddr <= E_LO & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 32)) then
						myFontAddr <= L_LO & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 40)) then
						myFontAddr <= COLON & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 56)) then
						myFontAddr <= (ZERO + ("000" & levelBCD(11 downto 8))) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 64)) then
						myFontAddr <= (ZERO + ("000" & levelBCD(7 downto 4))) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 72)) then
						myFontAddr <= (ZERO + ("000" & levelBCD(3 downto 0))) & DrawY(3 downto 0);
					end if;
				elsif (chk_font_y(DrawY, 48)) then
					-- Lives
					if (chk_font_x(DrawX, 496)) then
						myFontAddr <= L_UP & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 8)) then
						myFontAddr <= I_LO & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 16)) then
						myFontAddr <= V_LO & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 24)) then
						myFontAddr <= E_LO & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 32)) then
						myFontAddr <= S_LO & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 40)) then
						myFontAddr <= COLON & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 56)) then
						myFontAddr <= (ZERO + ("000" & livesBCD(7 downto 4))) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 496 + 64)) then
						myFontAddr <= (ZERO + ("000" & livesBCD(3 downto 0))) & DrawY(3 downto 0);
					end if;
-- PLACE GENERATED CODE HERE
				elsif (chk_font_y(DrawY, 96)) then
					if (chk_font_x(DrawX, 496)) then
						myFontAddr <= tov(68, 7) & DrawY(3 downto 0);	-- D
					elsif (chk_font_x(DrawX, 504)) then
						myFontAddr <= tov(97, 7) & DrawY(3 downto 0);	-- a
					elsif (chk_font_x(DrawX, 512)) then
						myFontAddr <= tov(109, 7) & DrawY(3 downto 0);	-- m
					elsif (chk_font_x(DrawX, 520)) then
						myFontAddr <= tov(97, 7) & DrawY(3 downto 0);	-- a
					elsif (chk_font_x(DrawX, 528)) then
						myFontAddr <= tov(103, 7) & DrawY(3 downto 0);	-- g
					elsif (chk_font_x(DrawX, 536)) then
						myFontAddr <= tov(101, 7) & DrawY(3 downto 0);	-- e
					elsif (chk_font_x(DrawX, 544)) then
						myFontAddr <= tov(58, 7) & DrawY(3 downto 0);	-- :
					end if;

					if (is_tower_elem(curBaseElem)) then
						if (chk_font_x(DrawX, 560)) then
							myFontAddr <= (ZERO + ("000" & curDamageBCD(19 downto 16))) & DrawY(3 downto 0);
						elsif (chk_font_x(DrawX, 568)) then
							myFontAddr <= (ZERO + ("000" & curDamageBCD(15 downto 12))) & DrawY(3 downto 0);
						elsif (chk_font_x(DrawX, 576)) then
							myFontAddr <= (ZERO + ("000" & curDamageBCD(11 downto 8))) & DrawY(3 downto 0);
						elsif (chk_font_x(DrawX, 584)) then
							myFontAddr <= (ZERO + ("000" & curDamageBCD(7 downto 4))) & DrawY(3 downto 0);
						elsif (chk_font_x(DrawX, 592)) then
							myFontAddr <= (ZERO + ("000" & curDamageBCD(3 downto 0))) & DrawY(3 downto 0);
						end if;
					end if;
				elsif (chk_font_y(DrawY, 112)) then
					if (chk_font_x(DrawX, 496)) then
						myFontAddr <= tov(82, 7) & DrawY(3 downto 0);	-- R
					elsif (chk_font_x(DrawX, 504)) then
						myFontAddr <= tov(97, 7) & DrawY(3 downto 0);	-- a
					elsif (chk_font_x(DrawX, 512)) then
						myFontAddr <= tov(110, 7) & DrawY(3 downto 0);	-- n
					elsif (chk_font_x(DrawX, 520)) then
						myFontAddr <= tov(103, 7) & DrawY(3 downto 0);	-- g
					elsif (chk_font_x(DrawX, 528)) then
						myFontAddr <= tov(101, 7) & DrawY(3 downto 0);	-- e
					elsif (chk_font_x(DrawX, 536)) then
						myFontAddr <= tov(58, 7) & DrawY(3 downto 0);	-- :
					end if;

					if (is_tower_elem(curBaseElem)) then
						if (chk_font_x(DrawX, 552)) then
							myFontAddr <= (ZERO + ("000" & curRngBCD(15 downto 12))) & DrawY(3 downto 0);
						elsif (chk_font_x(DrawX, 560)) then
							myFontAddr <= (ZERO + ("000" & curRngBCD(11 downto 8))) & DrawY(3 downto 0);
						elsif (chk_font_x(DrawX, 568)) then
							myFontAddr <= (ZERO + ("000" & curRngBCD(7 downto 4))) & DrawY(3 downto 0);
						elsif (chk_font_x(DrawX, 576)) then
							myFontAddr <= (ZERO + ("000" & curRngBCD(3 downto 0))) & DrawY(3 downto 0);
						end if;
					end if;
				elsif (chk_font_y(DrawY, 128)) then
					if (chk_font_x(DrawX, 496)) then
						myFontAddr <= tov(83, 7) & DrawY(3 downto 0);	-- S
					elsif (chk_font_x(DrawX, 504)) then
						myFontAddr <= tov(112, 7) & DrawY(3 downto 0);	-- p
					elsif (chk_font_x(DrawX, 512)) then
						myFontAddr <= tov(101, 7) & DrawY(3 downto 0);	-- e
					elsif (chk_font_x(DrawX, 520)) then
						myFontAddr <= tov(101, 7) & DrawY(3 downto 0);	-- e
					elsif (chk_font_x(DrawX, 528)) then
						myFontAddr <= tov(100, 7) & DrawY(3 downto 0);	-- d
					elsif (chk_font_x(DrawX, 536)) then
						myFontAddr <= tov(58, 7) & DrawY(3 downto 0);	-- :
					end if;

					if (is_tower_elem(curBaseElem)) then
						if (chk_font_x(DrawX, 552)) then
							case curSpeed is
								when "00" =>
									myFontAddr <= ZERO & DrawY(3 downto 0);
								when "01" =>
									myFontAddr <= ONE & DrawY(3 downto 0);
								when "10" =>
									myFontAddr <= TWO & DrawY(3 downto 0);
								when "11" =>
									myFontAddr <= THREE & DrawY(3 downto 0);
							end case;
						end if;
					end if;
				elsif (chk_font_y(DrawY, 368)) then
					if (chk_font_x(DrawX, 496)) then
						myFontAddr <= tov(87, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 504)) then
						myFontAddr <= tov(65, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 512)) then
						myFontAddr <= tov(83, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 520)) then
						myFontAddr <= tov(68, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 528)) then
						myFontAddr <= tov(58, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 544)) then
						myFontAddr <= tov(109, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 552)) then
						myFontAddr <= tov(111, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 560)) then
						myFontAddr <= tov(118, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 568)) then
						myFontAddr <= tov(101, 7) & DrawY(3 downto 0);
					end if;
				elsif (chk_font_y(DrawY, 384)) then
					if (chk_font_x(DrawX, 496)) then
						myFontAddr <= tov(83, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 504)) then
						myFontAddr <= tov(112, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 512)) then
						myFontAddr <= tov(97, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 520)) then
						myFontAddr <= tov(99, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 528)) then
						myFontAddr <= tov(101, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 536)) then
						myFontAddr <= tov(58, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 552)) then
						myFontAddr <= tov(112, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 560)) then
						myFontAddr <= tov(108, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 568)) then
						myFontAddr <= tov(97, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 576)) then
						myFontAddr <= tov(99, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 584)) then
						myFontAddr <= tov(101, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 600)) then
						myFontAddr <= tov(116, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 608)) then
						myFontAddr <= tov(111, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 616)) then
						myFontAddr <= tov(119, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 624)) then
						myFontAddr <= tov(101, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 632)) then
						myFontAddr <= tov(114, 7) & DrawY(3 downto 0);
					end if;
				elsif (chk_font_y(DrawY, 400)) then
					if (chk_font_x(DrawX, 496)) then
						myFontAddr <= tov(49, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 504)) then
						myFontAddr <= tov(58, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 520)) then
						myFontAddr <= tov(43, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 528)) then
						myFontAddr <= tov(68, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 536)) then
						myFontAddr <= tov(97, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 544)) then
						myFontAddr <= tov(109, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 552)) then
						myFontAddr <= tov(97, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 560)) then
						myFontAddr <= tov(103, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 568)) then
						myFontAddr <= tov(101, 7) & DrawY(3 downto 0);
					end if;
				elsif (chk_font_y(DrawY, 416)) then
					if (chk_font_x(DrawX, 496)) then
						myFontAddr <= tov(50, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 504)) then
						myFontAddr <= tov(58, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 520)) then
						myFontAddr <= tov(43, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 528)) then
						myFontAddr <= tov(82, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 536)) then
						myFontAddr <= tov(97, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 544)) then
						myFontAddr <= tov(110, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 552)) then
						myFontAddr <= tov(103, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 560)) then
						myFontAddr <= tov(101, 7) & DrawY(3 downto 0);
					end if;
				elsif (chk_font_y(DrawY, 432)) then
					if (chk_font_x(DrawX, 496)) then
						myFontAddr <= tov(51, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 504)) then
						myFontAddr <= tov(58, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 520)) then
						myFontAddr <= tov(43, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 528)) then
						myFontAddr <= tov(83, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 536)) then
						myFontAddr <= tov(112, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 544)) then
						myFontAddr <= tov(101, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 552)) then
						myFontAddr <= tov(101, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 560)) then
						myFontAddr <= tov(100, 7) & DrawY(3 downto 0);
					end if;
				elsif (chk_font_y(DrawY, 448)) then
					if (chk_font_x(DrawX, 496)) then
						myFontAddr <= tov(52, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 504)) then
						myFontAddr <= tov(58, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 520)) then
						myFontAddr <= tov(43, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 528)) then
						myFontAddr <= tov(83, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 536)) then
						myFontAddr <= tov(108, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 544)) then
						myFontAddr <= tov(111, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 552)) then
						myFontAddr <= tov(119, 7) & DrawY(3 downto 0);
					end if;
				elsif (chk_font_y(DrawY, 464)) then
					if (chk_font_x(DrawX, 496)) then
						myFontAddr <= tov(53, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 504)) then
						myFontAddr <= tov(58, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 520)) then
						myFontAddr <= tov(43, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 528)) then
						myFontAddr <= tov(80, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 536)) then
						myFontAddr <= tov(111, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 544)) then
						myFontAddr <= tov(105, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 552)) then
						myFontAddr <= tov(115, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 560)) then
						myFontAddr <= tov(111, 7) & DrawY(3 downto 0);
					elsif (chk_font_x(DrawX, 568)) then
						myFontAddr <= tov(110, 7) & DrawY(3 downto 0);
					end if;
				end if;
-- END GENERATED CODE HERE

--				if (is_tower_elem(curBaseElem)) then = curTwr
--			curTwr : in Tower;
--			curBaseElem : in BaseElem;
				if (myFontAddr /= tov(0, 11) and fontData(7 - conv_integer(DrawX(2 downto 0) - tov(1, 3))) = '1') then
					pxlData <= "1111111111111111";
				elsif (DrawY >= 76 and DrawY < 84) then
					pxlData <= "1000001000010000";
				elsif (DrawY >= 352 and DrawY < 360) then
					pxlData <= "1000001000010000";
				else
					pxlData <= tov(0, 16);
				end if;
			end if;
		end if;
	end process;
end Behavioral;
