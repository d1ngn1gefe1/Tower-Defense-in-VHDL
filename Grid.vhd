-- Entity containing the 16x16 grid (paths, cursor, towers)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.Constants.all;

entity Grid is
	Port (	reset : in std_logic;
			clk : in std_logic;

			place : in std_logic;	-- control sig to place new item
			newItem : in GridElem;

			changeMod : in std_logic;	-- changes base elem; modifies grid at cursorI
			newMod : in BaseElem;

			changeDir : in std_logic;	-- these control sigs modify grid at cmdI
			newDir : in Direction;
			changeAnim : in std_logic;	-- toggle animation
			cmdI : in std_logic_vector(7 downto 0);

			incLvl : in std_logic;	-- increment level; modify at cursorI

			moveCursor : in std_logic;	-- control sig to move cursor
			moveDir : in Direction;

			grid : out GridType;
			curI : out std_logic_vector(7 downto 0);

			cursorI : out std_logic_vector(7 downto 0);
			curBaseElem : out BaseElem);
end Grid;

architecture Behavioral of Grid is
	signal myGrid : GridType;

	signal myCursorI : std_logic_vector(7 downto 0);

	signal myCurI : std_logic_vector(7 downto 0);	-- the actual grid index of myGrid(0)

	signal myPlace : std_logic;	-- control sig to place new item
	signal myNewItem : GridElem;

	signal myChangeMod : std_logic;	-- changes base elem; modifies grid at cursorI
	signal myNewMod : BaseElem;

	signal myChangeDir : std_logic;	-- these control sigs modify grid at cmdI
	signal myNewDir : Direction;
	signal myChangeAnim : std_logic;	-- toggle animation
	signal myIncLvl : std_logic;
	signal myCmdI : std_logic_vector(7 downto 0);
begin
	grid <= myGrid;
	cursorI <= myCursorI;
	curI <= myCurI;

	process (clk, reset)
	begin
		if (reset = '1') then
			myCursorI <= tov(0, 8);
			myCurI <= tov(0, 8);

			myPlace <= '0';
			myChangeMod <= '0';
			myChangeDir <= '0';
			myChangeAnim <= '0';

			-- row 0
			myGrid(0) <= get_base_elem(Empty);
			myGrid(1) <= get_base_elem(Empty);
			myGrid(2) <= get_base_elem(Empty);
			myGrid(3) <= get_base_elem(Empty);
			myGrid(4) <= get_base_elem(Path);
			myGrid(5) <= get_base_elem(Path);
			myGrid(6) <= get_base_elem(Path);
			myGrid(7) <= get_base_elem(Path);
			myGrid(8) <= get_base_elem(Path);
			myGrid(9) <= get_base_elem(Path);
			myGrid(10) <= get_base_elem(Path);
			myGrid(11) <= get_base_elem(Path);
			myGrid(12) <= get_base_elem(Empty);
			myGrid(13) <= get_base_elem(Empty);
			myGrid(14) <= get_base_elem(Empty);
			myGrid(15) <= get_base_elem(Empty);

			-- row 1
			myGrid(16) <= get_base_elem(Empty);
			myGrid(17) <= get_base_elem(Empty);
			myGrid(18) <= get_base_elem(Empty);
			myGrid(19) <= get_base_elem(Path);
			myGrid(20) <= get_base_elem(Path);
			myGrid(21) <= get_base_elem(RedBG);
			myGrid(22) <= get_base_elem(RedBG);
			myGrid(23) <= get_base_elem(RedBG);
			myGrid(24) <= get_base_elem(RedBG);
			myGrid(25) <= get_base_elem(RedBG);
			myGrid(26) <= get_base_elem(RedBG);
			myGrid(27) <= get_base_elem(Path);
			myGrid(28) <= get_base_elem(Path);
			myGrid(29) <= get_base_elem(Empty);
			myGrid(30) <= get_base_elem(Empty);
			myGrid(31) <= get_base_elem(Empty);

			-- row 2
			myGrid(32) <= get_base_elem(Empty);
			myGrid(33) <= get_base_elem(Empty);
			myGrid(34) <= get_base_elem(Path);
			myGrid(35) <= get_base_elem(Path);
			myGrid(36) <= get_base_elem(LightRedBG);
			myGrid(37) <= get_base_elem(RedBG);
			myGrid(38) <= get_base_elem(RedBG);
			myGrid(39) <= get_base_elem(RedBG);
			myGrid(40) <= get_base_elem(RedBG);
			myGrid(41) <= get_base_elem(RedBG);
			myGrid(42) <= get_base_elem(RedBG);
			myGrid(43) <= get_base_elem(DarkRedBG);
			myGrid(44) <= get_base_elem(Path);
			myGrid(45) <= get_base_elem(Path);
			myGrid(46) <= get_base_elem(Empty);
			myGrid(47) <= get_base_elem(Empty);

			-- row 3
			myGrid(48) <= get_base_elem(Empty);
			myGrid(49) <= get_base_elem(Path);
			myGrid(50) <= get_base_elem(Path);
			myGrid(51) <= get_base_elem(LightRedBG);
			myGrid(52) <= get_base_elem(WhiteBG);
			myGrid(53) <= get_base_elem(LightRedBG);
			myGrid(54) <= get_base_elem(RedBG);
			myGrid(55) <= get_base_elem(RedBG);
			myGrid(56) <= get_base_elem(RedBG);
			myGrid(57) <= get_base_elem(RedBG);
			myGrid(58) <= get_base_elem(RedBG);
			myGrid(59) <= get_base_elem(DarkRedBG);
			myGrid(60) <= get_base_elem(DarkRedBG);
			myGrid(61) <= get_base_elem(Path);
			myGrid(62) <= get_base_elem(Path);
			myGrid(63) <= get_base_elem(Empty);

			-- row 4
			myGrid(64) <= get_base_elem(Empty);
			myGrid(65) <= get_base_elem(Path);
			myGrid(66) <= get_base_elem(LightRedBG);
			myGrid(67) <= get_base_elem(WhiteBG);
			myGrid(68) <= get_base_elem(WhiteBG);
			myGrid(69) <= get_base_elem(WhiteBG);
			myGrid(70) <= get_base_elem(LightRedBG);
			myGrid(71) <= get_base_elem(RedBG);
			myGrid(72) <= get_base_elem(RedBG);
			myGrid(73) <= get_base_elem(RedBG);
			myGrid(74) <= get_base_elem(RedBG);
			myGrid(75) <= get_base_elem(RedBG);
			myGrid(76) <= get_base_elem(DarkRedBG);
			myGrid(77) <= get_base_elem(DarkRedBG);
			myGrid(78) <= get_base_elem(Path);
			myGrid(79) <= get_base_elem(Empty);

			-- row 5
			myGrid(80) <= get_base_elem(Empty);
			myGrid(81) <= get_base_elem(Path);
			myGrid(82) <= get_base_elem(RedBG);
			myGrid(83) <= get_base_elem(LightRedBG);
			myGrid(84) <= get_base_elem(WhiteBG);
			myGrid(85) <= get_base_elem(LightRedBG);
			myGrid(86) <= get_base_elem(RedBG);
			myGrid(87) <= get_base_elem(RedBG);
			myGrid(88) <= get_base_elem(RedBG);
			myGrid(89) <= get_base_elem(RedBG);
			myGrid(90) <= get_base_elem(RedBG);
			myGrid(91) <= get_base_elem(DarkRedBG);
			myGrid(92) <= get_base_elem(DarkRedBG);
			myGrid(93) <= get_base_elem(DarkRedBG);
			myGrid(94) <= get_base_elem(Path);
			myGrid(95) <= get_base_elem(Path);

			-- row 6
			myGrid(96) <= get_base_elem(Path);
			myGrid(97) <= get_base_elem(Path);
			myGrid(98) <= get_base_elem(RedBG);
			myGrid(99) <= get_base_elem(RedBG);
			myGrid(100) <= get_base_elem(LightRedBG);
			myGrid(101) <= get_base_elem(RedBG);
			myGrid(102) <= get_base_elem(RedBG);
			myGrid(103) <= get_base_elem(RedBG);
			myGrid(104) <= get_base_elem(RedBG);
			myGrid(105) <= get_base_elem(RedBG);
			myGrid(106) <= get_base_elem(DarkRedBG);
			myGrid(107) <= get_base_elem(DarkRedBG);
			myGrid(108) <= get_base_elem(DarkRedBG);
			myGrid(109) <= get_base_elem(DarkRedBG);
			myGrid(110) <= get_base_elem(DarkRedBG);
			myGrid(111) <= get_base_elem(Path);

			-- row 7
			myGrid(112) <= get_base_elem(Empty);
			myGrid(113) <= get_base_elem(RedBG);
			myGrid(114) <= get_base_elem(RedBG);
			myGrid(115) <= get_base_elem(RedBG);
			myGrid(116) <= get_base_elem(RedBG);
			myGrid(117) <= get_base_elem(RedBG);
			myGrid(118) <= get_base_elem(Path);
			myGrid(119) <= get_base_elem(Path);
			myGrid(120) <= get_base_elem(Path);
			myGrid(121) <= get_base_elem(Path);
			myGrid(122) <= get_base_elem(DarkRedBG);
			myGrid(123) <= get_base_elem(DarkRedBG);
			myGrid(124) <= get_base_elem(DarkRedBG);
			myGrid(125) <= get_base_elem(DarkRedBG);
			myGrid(126) <= get_base_elem(DarkRedBG);
			myGrid(127) <= get_base_elem(Path);

			-- row 8
			myGrid(128) <= get_base_elem(Empty);
			myGrid(129) <= get_base_elem(RedBG);
			myGrid(130) <= get_base_elem(RedBG);
			myGrid(131) <= get_base_elem(RedBG);
			myGrid(132) <= get_base_elem(RedBG);
			myGrid(133) <= get_base_elem(RedBG);
			myGrid(134) <= get_base_elem(Path);
			myGrid(135) <= get_base_elem(WhiteBG);
			myGrid(136) <= get_base_elem(WhiteBG);
			myGrid(137) <= get_base_elem(Path);
			myGrid(138) <= get_base_elem(DarkRedBG);
			myGrid(139) <= get_base_elem(DarkRedBG);
			myGrid(140) <= get_base_elem(DarkRedBG);
			myGrid(141) <= get_base_elem(DarkRedBG);
			myGrid(142) <= get_base_elem(DarkRedBG);
			myGrid(143) <= get_base_elem(Path);

			-- row 9
			myGrid(144) <= get_base_elem(Path);
			myGrid(145) <= get_base_elem(Path);
			myGrid(146) <= get_base_elem(Path);
			myGrid(147) <= get_base_elem(Path);
			myGrid(148) <= get_base_elem(Path);
			myGrid(149) <= get_base_elem(Path);
			myGrid(150) <= get_base_elem(Path);
			myGrid(151) <= get_base_elem(WhiteBG);
			myGrid(152) <= get_base_elem(WhiteBG);
			myGrid(153) <= get_base_elem(Path);
			myGrid(154) <= get_base_elem(Path);
			myGrid(155) <= get_base_elem(Path);
			myGrid(156) <= get_base_elem(Path);
			myGrid(157) <= get_base_elem(Path);
			myGrid(158) <= get_base_elem(Path);
			myGrid(159) <= get_base_elem(Path);

			-- row 10
			myGrid(160) <= get_base_elem(Path);
			myGrid(161) <= get_base_elem(WhiteBG);
			myGrid(162) <= get_base_elem(WhiteBG);
			myGrid(163) <= get_base_elem(WhiteBG);
			myGrid(164) <= get_base_elem(WhiteBG);
			myGrid(165) <= get_base_elem(WhiteBG);
			myGrid(166) <= get_base_elem(WhiteBG);
			myGrid(167) <= get_base_elem(Path);
			myGrid(168) <= get_base_elem(Path);
			myGrid(169) <= get_base_elem(WhiteBG);
			myGrid(170) <= get_base_elem(WhiteBG);
			myGrid(171) <= get_base_elem(WhiteBG);
			myGrid(172) <= get_base_elem(WhiteBG);
			myGrid(173) <= get_base_elem(WhiteBG);
			myGrid(174) <= get_base_elem(WhiteBG);
			myGrid(175) <= get_base_elem(Empty);

			-- row 11
			myGrid(176) <= get_base_elem(Path);
			myGrid(177) <= get_base_elem(Path);
			myGrid(178) <= get_base_elem(WhiteBG);
			myGrid(179) <= get_base_elem(WhiteBG);
			myGrid(180) <= get_base_elem(WhiteBG);
			myGrid(181) <= get_base_elem(WhiteBG);
			myGrid(182) <= get_base_elem(WhiteBG);
			myGrid(183) <= get_base_elem(WhiteBG);
			myGrid(184) <= get_base_elem(WhiteBG);
			myGrid(185) <= get_base_elem(WhiteBG);
			myGrid(186) <= get_base_elem(WhiteBG);
			myGrid(187) <= get_base_elem(WhiteBG);
			myGrid(188) <= get_base_elem(WhiteBG);
			myGrid(189) <= get_base_elem(GreyBG);
			myGrid(190) <= get_base_elem(Path);
			myGrid(191) <= get_base_elem(Path);

			-- row 12
			myGrid(192) <= get_base_elem(Empty);
			myGrid(193) <= get_base_elem(Path);
			myGrid(194) <= get_base_elem(Path);
			myGrid(195) <= get_base_elem(WhiteBG);
			myGrid(196) <= get_base_elem(WhiteBG);
			myGrid(197) <= get_base_elem(WhiteBG);
			myGrid(198) <= get_base_elem(WhiteBG);
			myGrid(199) <= get_base_elem(WhiteBG);
			myGrid(200) <= get_base_elem(WhiteBG);
			myGrid(201) <= get_base_elem(WhiteBG);
			myGrid(202) <= get_base_elem(WhiteBG);
			myGrid(203) <= get_base_elem(GreyBG);
			myGrid(204) <= get_base_elem(GreyBG);
			myGrid(205) <= get_base_elem(Path);
			myGrid(206) <= get_base_elem(Path);
			myGrid(207) <= get_base_elem(Empty);

			-- row 13
			myGrid(208) <= get_base_elem(Empty);
			myGrid(209) <= get_base_elem(Empty);
			myGrid(210) <= get_base_elem(Path);
			myGrid(211) <= get_base_elem(Path);
			myGrid(212) <= get_base_elem(WhiteBG);
			myGrid(213) <= get_base_elem(WhiteBG);
			myGrid(214) <= get_base_elem(WhiteBG);
			myGrid(215) <= get_base_elem(WhiteBG);
			myGrid(216) <= get_base_elem(WhiteBG);
			myGrid(217) <= get_base_elem(WhiteBG);
			myGrid(218) <= get_base_elem(WhiteBG);
			myGrid(219) <= get_base_elem(GreyBG);
			myGrid(220) <= get_base_elem(Path);
			myGrid(221) <= get_base_elem(Path);
			myGrid(222) <= get_base_elem(Empty);
			myGrid(223) <= get_base_elem(Empty);

			-- row 14
			myGrid(224) <= get_base_elem(Empty);
			myGrid(225) <= get_base_elem(Empty);
			myGrid(226) <= get_base_elem(Empty);
			myGrid(227) <= get_base_elem(Path);
			myGrid(228) <= get_base_elem(Path);
			myGrid(229) <= get_base_elem(GreyBG);
			myGrid(230) <= get_base_elem(GreyBG);
			myGrid(231) <= get_base_elem(GreyBG);
			myGrid(232) <= get_base_elem(GreyBG);
			myGrid(233) <= get_base_elem(GreyBG);
			myGrid(234) <= get_base_elem(GreyBG);
			myGrid(235) <= get_base_elem(Path);
			myGrid(236) <= get_base_elem(Path);
			myGrid(237) <= get_base_elem(Empty);
			myGrid(238) <= get_base_elem(Empty);
			myGrid(239) <= get_base_elem(Empty);

			-- row 15
			myGrid(240) <= get_base_elem(Empty);
			myGrid(241) <= get_base_elem(Empty);
			myGrid(242) <= get_base_elem(Empty);
			myGrid(243) <= get_base_elem(Empty);
			myGrid(244) <= get_base_elem(Path);
			myGrid(245) <= get_base_elem(Path);
			myGrid(246) <= get_base_elem(Path);
			myGrid(247) <= get_base_elem(Path);
			myGrid(248) <= get_base_elem(Path);
			myGrid(249) <= get_base_elem(Path);
			myGrid(250) <= get_base_elem(Path);
			myGrid(251) <= get_base_elem(Path);
			myGrid(252) <= get_base_elem(Empty);
			myGrid(253) <= get_base_elem(Empty);
			myGrid(254) <= get_base_elem(Empty);
			myGrid(255) <= get_base_elem(Empty);
		elsif (rising_edge(clk)) then
			-- always shift right (to the top left)
			myGrid(255) <= myGrid(0);
			myGrid(254 downto 0) <= myGrid(255 downto 1);

			myCurI <= myCurI + tov(1, 8);

			if (myCurI = myCursorI) then
				if (myPlace = '1') then
					myGrid(255) <= myNewItem;
					myPlace <= '0';
				end if;
				if (myChangeMod = '1') then
					myGrid(255).base <= myNewMod;
					myChangeMod <= '0';
				end if;
				if (myIncLvl = '1') then
					if (myGrid(0).level /= tov(2, 2)) then
						myGrid(255).level <= myGrid(0).level + tov(1, 2);
					end if;
					myIncLvl <= '0';
				end if;
				curBaseElem <= myGrid(0).base;
			end if;

			if (myCurI = myCmdI) then
				if (myChangeDir = '1') then
					myGrid(255).dir <= myNewDir;
					myChangeDir <= '0';
				end if;
				if (myChangeAnim = '1') then
					myGrid(255).anim <= not myGrid(0).anim;
					myChangeAnim <= '0';
				end if;
			end if;

			if (moveCursor = '1') then
				case moveDir is 
					when UpDir =>
						if (myCursorI >= tov(16, 8)) then
							myCursorI <= myCursorI - tov(16, 8);
						end if;
					when DownDir =>
						if (myCursorI <= tov(239, 8)) then
							myCursorI <= myCursorI + tov(16, 8);
						end if;
					when LeftDir =>
						if (myCursorI(3) = '1' or myCursorI(2) = '1' or myCursorI(1) = '1' or myCursorI(0) = '1') then
							-- myCursorI % 16 != 0, ie. not on column 0
							myCursorI <= myCursorI - tov(1, 8);
						end if;
					when RightDir =>
						if (not (myCursorI(3) = '1' and myCursorI(2) = '1' and myCursorI(1) = '1' and myCursorI(0) = '1')) then
							-- myCursorI % 16 != 15, ie. not on last column
							myCursorI <= myCursorI + tov(1, 8);
						end if;
				end case;
			end if;

			if (place = '1') then
				myPlace <= '1';
				myNewItem <= newItem;
			end if;

			if (changeDir = '1') then
				myChangeDir <= '1';
				myNewDir <= newDir;
				myCmdI <= cmdI;
			end if;

			if (changeAnim = '1') then
				myChangeAnim <= '1';
				myCmdI <= cmdI;
			end if;

			if (incLvl = '1') then
				myIncLvl <= '1';
			end if;

			if (changeMod = '1') then
				myChangeMod <= '1';
				myNewMod <= newMod;
			end if;
		end if;
	end process;
end Behavioral;
