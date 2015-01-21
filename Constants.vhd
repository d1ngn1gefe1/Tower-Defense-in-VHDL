library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

--library work;
--use work.Constants.all;

package Constants is
	-- GAME PARAMETERS
	constant NUM_ENEMIES : integer := 11;	-- number of enemies in level
	constant MAX_TOWERS : integer := 32;
	constant CURSOR_W : integer := 3;

	constant START_RNG : integer := 32;
	constant ADD_RNG : integer := 16;
	constant RNG_UP_COST : integer := 10;

	constant START_DAMAGE : integer := 1;
	constant ADD_DAMAGE : integer := 1;
	constant DAMAGE_UP_COST : integer := 10;

	constant SPEED_UP_COST : integer := 40;

	constant START_LIVES : integer := 20;
	constant START_GOLD : integer := 50;
	constant BASIC_TOWER_COST : integer := 10;
	constant MOD_COST : integer := 10;

	constant POISON_DAMAGE : integer := 1;

	constant UNUSED_GRID_I : std_logic_vector(7 downto 0) := conv_std_logic_vector(4, 8);	-- used as gridI of non-existent towers in the array

	constant SHOT_RADIUS : integer := 5;

	-- color mask color is (4, 8, 224)
	constant MASK_R : std_logic_vector(5 downto 0) := conv_std_logic_vector(1, 6);
	constant MASK_G : std_logic_vector(4 downto 0) := conv_std_logic_vector(1, 5);
	constant MASK_B : std_logic_vector(4 downto 0) := "11100";

	-- MEMORY LOCATIONS
	constant PATH_LOC : std_logic_vector(17 downto 0) := conv_std_logic_vector(64800, 18);
	constant EMPTY_LOC : std_logic_vector(17 downto 0) := conv_std_logic_vector(65700, 18);
	constant ENEMY_LOC : std_logic_vector(17 downto 0) := conv_std_logic_vector(66600, 18);
	constant ENEMY_END_LOC : std_logic_vector(17 downto 0) := conv_std_logic_vector(81000, 18);

	constant DARK_RED_LOC : std_logic_vector(17 downto 0) := conv_std_logic_vector(81000, 18);
	constant RED_LOC : std_logic_vector(17 downto 0) := conv_std_logic_vector(81001, 18);
	constant LIGHT_RED_LOC : std_logic_vector(17 downto 0) := conv_std_logic_vector(81002, 18);
	constant GREY_LOC : std_logic_vector(17 downto 0) := conv_std_logic_vector(81003, 18);
	constant WHITE_LOC : std_logic_vector(17 downto 0) := conv_std_logic_vector(81004, 18);
	constant BLACK_LOC : std_logic_vector(17 downto 0) := conv_std_logic_vector(81005, 18);
	constant DARK_GREY_LOC : std_logic_vector(17 downto 0) := conv_std_logic_vector(81006, 18);
	constant ORANGE_LOC : std_logic_vector(17 downto 0) := conv_std_logic_vector(81007, 18);
	constant BLUE_LOC : std_logic_vector(17 downto 0) := conv_std_logic_vector(81008, 18);
	constant PURPLE_LOC : std_logic_vector(17 downto 0) := conv_std_logic_vector(81009, 18);

	-- CHAR LOCATIONS
	constant ZERO : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#30#, 7);
	constant ONE : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#31#, 7);
	constant TWO : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#32#, 7);
	constant THREE : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#33#, 7);
	constant FOUR : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#34#, 7);
	constant FIVE : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#35#, 7);
	constant COLON : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#3a#, 7);
	constant D_UP : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#44#, 7);
	constant G_UP : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#47#, 7);
	constant L_UP : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#4c#, 7);
	constant P_UP : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#50#, 7);
	constant R_UP : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#52#, 7);
	constant S_UP : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#53#, 7);
	constant A_LO : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#61#, 7);
	constant C_LO : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#63#, 7);
	constant D_LO : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#64#, 7);
	constant E_LO : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#65#, 7);
	constant G_LO : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#67#, 7);
	constant I_LO : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#69#, 7);
	constant L_LO : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#6c#, 7);
	constant M_LO : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#6d#, 7);
	constant N_LO : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#6e#, 7);
	constant O_LO : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#6f#, 7);
	constant P_LO : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#70#, 7);
	constant S_LO : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#73#, 7);
	constant V_LO : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#76#, 7);
	constant W_LO : std_logic_vector(6 downto 0) := conv_std_logic_vector(16#77#, 7);

	-- KEYS
	constant KEY_W : std_logic_vector(7 downto 0) := x"1D";
	constant KEY_A : std_logic_vector(7 downto 0) := x"1C";
	constant KEY_S : std_logic_vector(7 downto 0) := x"1B";
	constant KEY_D : std_logic_vector(7 downto 0) := x"23";
	constant KEY_SPACE : std_logic_vector(7 downto 0) := x"29";
	constant KEY_1 : std_logic_vector(7 downto 0) := x"16";	-- damage
	constant KEY_2 : std_logic_vector(7 downto 0) := x"1E";	-- range
	constant KEY_3 : std_logic_vector(7 downto 0) := x"26";	-- speed
	constant KEY_4 : std_logic_vector(7 downto 0) := x"25";	-- slow
	constant KEY_5 : std_logic_vector(7 downto 0) := x"2E";	-- poison

	type ColorMaskArrIm is array(29 downto 0) of std_logic_vector(29 downto 0);
	type ColorMaskArr is array(15 downto 0) of ColorMaskArrIm;
	constant MASK_ARR : ColorMaskArr := (
		0 => (
			0 => "000000000000000000000000000000",
			1 => "000000000000000000000000000000",
			2 => "000000000000000000000000000000",
			3 => "000000000000001000000000000000",
			4 => "000111000001011101000000000000",
			5 => "001111100011111111100001110000",
			6 => "011111110011111111100011111000",
			7 => "011111110011111111100111111100",
			8 => "011111100011111111100111111100",
			9 => "001111100111111111110011111100",
			10 => "000111111111111111111111111000",
			11 => "000111111111111111111111110000",
			12 => "000011111111111111111111100000",
			13 => "000001111111111111111111000000",
			14 => "000001111111111111111111000000",
			15 => "000011111111111111111111100000",
			16 => "000111111111111111111111100000",
			17 => "000111111111111111111111110000",
			18 => "001111111111111111111111110000",
			19 => "001111111111111111111111111000",
			20 => "001111111111111111111111111000",
			21 => "000111011111111111111111111000",
			22 => "000000011111111111111111110000",
			23 => "000000111111111111111110000000",
			24 => "000000111111011100011110000000",
			25 => "000000111100000000001100000000",
			26 => "000000011000000000000000000000",
			27 => "000000000000000000000000000000",
			28 => "000000000000000000000000000000",
			29 => "000000000000000000000000000000"
		),
		1 => (
			0 => "000000000000000000000000000000",
			1 => "000000000000000000000000000000",
			2 => "000000000000000000000000000000",
			3 => "000000000000000000000000000000",
			4 => "000000011000000000000110000000",
			5 => "000000011100000000001110000000",
			6 => "000000011110000000011110000000",
			7 => "000000001111000000111100000000",
			8 => "000000001111100001111100000000",
			9 => "000000000111111111111000000000",
			10 => "000000000111111111111000000000",
			11 => "000000000111111111111000000000",
			12 => "000000011111111111111110000000",
			13 => "000000111111111111111111000000",
			14 => "000001111111111111111111100000",
			15 => "000001111111111111111111100000",
			16 => "000011111111111111111111100000",
			17 => "000111111111111111111111110000",
			18 => "000111111111111111111111111000",
			19 => "000111111111111111111111111000",
			20 => "000111111111111111111111111000",
			21 => "000111101111111111111111111000",
			22 => "000011001111111111111111111000",
			23 => "000000011111011110111110110000",
			24 => "000000011111001100011100000000",
			25 => "000000001110000000000000000000",
			26 => "000000000000000000000000000000",
			27 => "000000000000000000000000000000",
			28 => "000000000000000000000000000000",
			29 => "000000000000000000000000000000"
		),
		2 => (
			0 => "000000000000000000000000000000",
			1 => "000000000000000000000000000000",
			2 => "000000000011000000011000000000",
			3 => "000000000111100000111100000000",
			4 => "000000000111111111111100000000",
			5 => "000000000111111111111100000000",
			6 => "000000000011111111111000000000",
			7 => "000000000011111111111000000000",
			8 => "000000000011111111111000000000",
			9 => "000000000111111111111100000000",
			10 => "000000000111111111111100000000",
			11 => "000000000111111111111100000000",
			12 => "000000000111111111111100000000",
			13 => "000000000011111111111000000000",
			14 => "000000000111111111111000000000",
			15 => "000000011111111111111100000000",
			16 => "000001111111111111111111000000",
			17 => "000011111101111111111111110000",
			18 => "000011111001111111111111111000",
			19 => "000011111000111111111111111000",
			20 => "000011100001111111111111111000",
			21 => "000001100011111111111100111000",
			22 => "000000000111111111111100110000",
			23 => "000000000111111111111100000000",
			24 => "000000000111111111111000000000",
			25 => "000000000011111111111000000000",
			26 => "000000000011110001111000000000",
			27 => "000000000011110000110000000000",
			28 => "000000000001100000000000000000",
			29 => "000000000000000000000000000000"
		),
		3 => (
			0 => "000000000000000000000000000000",
			1 => "000000000000000000000000000000",
			2 => "000000000000000000000000000000",
			3 => "000000000000000000000000000000",
			4 => "000000000000000000000000000000",
			5 => "000000000000000100000000000000",
			6 => "000000000000011111000000000000",
			7 => "000000000001111111110000000000",
			8 => "000000000011111111111000000000",
			9 => "000000000011111111111000000000",
			10 => "000000000111111111111100000000",
			11 => "000000000111111111111100000000",
			12 => "000000000111111111111100000000",
			13 => "000000000011111111111000000000",
			14 => "000000000111111111111000000000",
			15 => "000000001111111111111100000000",
			16 => "000000001111111111111110000000",
			17 => "000000000111111111111110000000",
			18 => "000000000011111111111100000000",
			19 => "000000000011111111111000000000",
			20 => "000000000001111111110000000000",
			21 => "000000000001111111000000000000",
			22 => "000000000000110000000000000000",
			23 => "000000000000000000000000000000",
			24 => "000000000000000000000000000000",
			25 => "000000000000000000000000000000",
			26 => "000000000000000000000000000000",
			27 => "000000000000000000000000000000",
			28 => "000000000000000000000000000000",
			29 => "000000000000000000000000000000"
		),
		4 => (
			0 => "000000000000000000000000000000",
			1 => "000000000000000000000000000000",
			2 => "000000000000000000000000000000",
			3 => "000000000000000100000000000000",
			4 => "000000000000001110000000000000",
			5 => "000000001100001110000110000000",
			6 => "000000001110011111001110000000",
			7 => "000011001111011111011110011000",
			8 => "000011100111111111111100111000",
			9 => "000011110111111111111101111000",
			10 => "000011111111111111111111111000",
			11 => "000011111111111111111111111000",
			12 => "000001111111111111111111110000",
			13 => "000001111111111111111111110000",
			14 => "000000111111111111111111100000",
			15 => "000000011111111111111111000000",
			16 => "000000111111111111111111000000",
			17 => "000000111111111111111111100000",
			18 => "000001111111111111111111100000",
			19 => "000001111111111111111111110000",
			20 => "000001111011111111111111110000",
			21 => "000001110011111111111111110000",
			22 => "000001110011111111111101110000",
			23 => "000000110111111111111101110000",
			24 => "000000000111101110111101100000",
			25 => "000000000111100000011000000000",
			26 => "000000000011000000000000000000",
			27 => "000000000000000000000000000000",
			28 => "000000000000000000000000000000",
			29 => "000000000000000000000000000000"
		),
		5 => (
			0 => "000000000000000000000000000000",
			1 => "000000000000000000000000000000",
			2 => "000000000110000000110000000000",
			3 => "000000001111111111111000000000",
			4 => "000000001111111111111000000000",
			5 => "000000001111111111111000000000",
			6 => "000000001111111111111000000000",
			7 => "000000011111111111111100000000",
			8 => "000000011111111111111100000000",
			9 => "000000011111111111111100000000",
			10 => "000011111111111111111110000000",
			11 => "001111111111111111111111100000",
			12 => "011111111111111111111111110000",
			13 => "011111111111111111111111111000",
			14 => "001111111111111111111111111100",
			15 => "000111111111111111111111111100",
			16 => "000111111111111111111111111100",
			17 => "000111111111111111111111111000",
			18 => "000111111111111111111111110000",
			19 => "000111111111111111111111110000",
			20 => "000011111111111111111111100000",
			21 => "000011111111111111111111100000",
			22 => "000011111111111111111111100000",
			23 => "000001111111111111111111000000",
			24 => "000000111111111111111110000000",
			25 => "000000111111111111111110000000",
			26 => "000000111111000001111100000000",
			27 => "000000011110000000000000000000",
			28 => "000000000000000000000000000000",
			29 => "000000000000000000000000000000"
		),
		6 => (
			0 => "000000000000000000000000000000",
			1 => "000000000000000000000000000000",
			2 => "000000000000000000000000000000",
			3 => "000000000000000000000000000000",
			4 => "000000000000000000000000000000",
			5 => "000000000000000000000000000000",
			6 => "000000000000000000000000000000",
			7 => "000000000000011111000000000000",
			8 => "000000000001111111110000000000",
			9 => "000000001111111111111110000000",
			10 => "000000011111111111111111000000",
			11 => "000000111111111111111111100000",
			12 => "000000111111111111111111100000",
			13 => "000000111111111111111111100000",
			14 => "000000011111111111111111000000",
			15 => "000000001111111111111110000000",
			16 => "000000011111111111111111000000",
			17 => "000000011111111111111111000000",
			18 => "000000011111111111111111000000",
			19 => "000000001111111111111110000000",
			20 => "000000001111111111111110000000",
			21 => "000000000111111111111100000000",
			22 => "000000000011111111110000000000",
			23 => "000000000001100000000000000000",
			24 => "000000000000000000000000000000",
			25 => "000000000000000000000000000000",
			26 => "000000000000000000000000000000",
			27 => "000000000000000000000000000000",
			28 => "000000000000000000000000000000",
			29 => "000000000000000000000000000000"
		),
		7 => (
			0 => "000000000000000000000000000000",
			1 => "000000000000000000000000000000",
			2 => "000000000000000000000000000000",
			3 => "000000000000000000000000000000",
			4 => "000000000000000000000000000000",
			5 => "000000110000000110000001100000",
			6 => "000000111100111111100111100000",
			7 => "000000111111111111111111100000",
			8 => "000000011111111111111111000000",
			9 => "000000011111111111111111000000",
			10 => "000000001111111111111110000000",
			11 => "000000001111111111111110000000",
			12 => "000000011111111111111110000000",
			13 => "000000111111111111111111000000",
			14 => "000001111111111111111111100000",
			15 => "000001111111111111111111110000",
			16 => "000000111111111111111111110000",
			17 => "000000001111111111111111100000",
			18 => "000000001111111111111110000000",
			19 => "000000000111111111111100000000",
			20 => "000000000111111111111100000000",
			21 => "000000000111111111111100000000",
			22 => "000000000111111111111000000000",
			23 => "000000000011100000000000000000",
			24 => "000000000000000000000000000000",
			25 => "000000000000000000000000000000",
			26 => "000000000000000000000000000000",
			27 => "000000000000000000000000000000",
			28 => "000000000000000000000000000000",
			29 => "000000000000000000000000000000"
		),
		8 => (
			0 => "000000000000000000000000000000",
			1 => "000000000000000000000000000000",
			2 => "000000000000000000000000000000",
			3 => "000000000000000000000000000000",
			4 => "000000000000001100000000000000",
			5 => "000000000000011110000000000000",
			6 => "000000000000011110000000000000",
			7 => "000000110000111111000011000000",
			8 => "000001111100111111001111100000",
			9 => "000001111111111111111111100000",
			10 => "000000111111111111111111000000",
			11 => "000000111111111111111111000000",
			12 => "000011111111111111111111110000",
			13 => "000111111111111111111111111000",
			14 => "000111111111111111111111111000",
			15 => "000011111111111111111111110000",
			16 => "000001111111111111111111100000",
			17 => "000000111111111111111111000000",
			18 => "000001111111111111111111100000",
			19 => "000011111111111111111111110000",
			20 => "000011111111111111111111110000",
			21 => "000001111111111111111111100000",
			22 => "000000001111111111111100000000",
			23 => "000000001111111110111100000000",
			24 => "000000001111001100011000000000",
			25 => "000000000110000000000000000000",
			26 => "000000000000000000000000000000",
			27 => "000000000000000000000000000000",
			28 => "000000000000000000000000000000",
			29 => "000000000000000000000000000000"
		),
		9 => (
			0 => "000000000000000000000000000000",
			1 => "000000000000000000000000000000",
			2 => "000000000000000000000000000000",
			3 => "000000000000000000000000000000",
			4 => "000000000000000000000000000000",
			5 => "000000000000111011100000000000",
			6 => "000000000011111111111000000000",
			7 => "000000000111111111111100000000",
			8 => "000000001111111111111110000000",
			9 => "000000011111111111111111000000",
			10 => "000000011111111111111111000000",
			11 => "000000111111111111111111100000",
			12 => "000001111111111111111111100000",
			13 => "000011111111111111111111110000",
			14 => "000011111111111111111111111000",
			15 => "000111111111111111111111111000",
			16 => "000111111111111111111111111100",
			17 => "000111111111111111111111111100",
			18 => "000011011111111111111111111100",
			19 => "000000011111111111111111111000",
			20 => "000000011111111111111111100000",
			21 => "000000111111111111111111100000",
			22 => "000000111111111111111111100000",
			23 => "000000111110011111000111000000",
			24 => "000000011100000000000000000000",
			25 => "000000000000000000000000000000",
			26 => "000000000000000000000000000000",
			27 => "000000000000000000000000000000",
			28 => "000000000000000000000000000000",
			29 => "000000000000000000000000000000"
		),
		10 => (
			0 => "000000000000000000000000000000",
			1 => "000000000000000000000000000000",
			2 => "000000000000000000000000000000",
			3 => "000000000000000000000000000000",
			4 => "000000000000011111000000000000",
			5 => "000000000000111111100000000000",
			6 => "000000000001111111110000000000",
			7 => "000000000001111111110000000000",
			8 => "000000000011111111111000000000",
			9 => "000000000011111111111000000000",
			10 => "000000000111111111111100000000",
			11 => "000000011111111111111111000000",
			12 => "000000111111111111111111100000",
			13 => "000001111111111111111111110000",
			14 => "000001111111111111111111110000",
			15 => "000001111111111111111111110000",
			16 => "000000111111111111111111100000",
			17 => "000001111111111111111111100000",
			18 => "000011111111111111111111110000",
			19 => "000011111111111111111111111000",
			20 => "000011111111111111111111111000",
			21 => "000001111111111111111111111000",
			22 => "000000111111001110011111110000",
			23 => "000000111111000000001111000000",
			24 => "000000011110000000001110000000",
			25 => "000000001110000000001100000000",
			26 => "000000000110000000000000000000",
			27 => "000000000000000000000000000000",
			28 => "000000000000000000000000000000",
			29 => "000000000000000000000000000000"
		),
		11 => (
			0 => "000000000000000000000000000000",
			1 => "000000000000000000000000000000",
			2 => "000000000000000000000000000000",
			3 => "000000000000000000000000000000",
			4 => "000000000000000000000000000000",
			5 => "000000000000000111000000000000",
			6 => "000000000000001111100000000000",
			7 => "000000000000001111100000000000",
			8 => "000000000000001111100000000000",
			9 => "000000000000011111000000000000",
			10 => "000000000000011100000000000000",
			11 => "000000000000011110000000000000",
			12 => "000000000000111111000000000000",
			13 => "000000000011111111110000000000",
			14 => "000000000111111111111000000000",
			15 => "000000000111111111111000000000",
			16 => "000000000111111111111000000000",
			17 => "000000000011111111110000000000",
			18 => "000000000011111111110000000000",
			19 => "000000000111111111111000000000",
			20 => "000000000011111111110000000000",
			21 => "000000000011111111110000000000",
			22 => "000000000011111111110000000000",
			23 => "000000000001101101100000000000",
			24 => "000000000000000000000000000000",
			25 => "000000000000000000000000000000",
			26 => "000000000000000000000000000000",
			27 => "000000000000000000000000000000",
			28 => "000000000000000000000000000000",
			29 => "000000000000000000000000000000"
		),
		12 => (
			0 => "000000000000000000000000000000",
			1 => "000000000000000000000000000000",
			2 => "000000000000000000000000000000",
			3 => "000000000000000000000000000000",
			4 => "000000000000000000000000000000",
			5 => "000000001100011110001100000000",
			6 => "000000111111111111111111000000",
			7 => "000001111111111111111111100000",
			8 => "000001111111111111111111100000",
			9 => "000000001111111111111100000000",
			10 => "000000000111111111111000000000",
			11 => "000000000111111111111000000000",
			12 => "000001100111111111111001100000",
			13 => "000011110111111111111011110000",
			14 => "000111111111111111111111111000",
			15 => "000111111111111111111111111000",
			16 => "000111111111111111111111111000",
			17 => "000011100011111111110001110000",
			18 => "000000000111111111111000000000",
			19 => "000000000111111111111000000000",
			20 => "000000000111111111111000000000",
			21 => "000000000011000001110000000000",
			22 => "000000000011100001111000000000",
			23 => "000000000111100000110000000000",
			24 => "000000000011000000000000000000",
			25 => "000000000000000000000000000000",
			26 => "000000000000000000000000000000",
			27 => "000000000000000000000000000000",
			28 => "000000000000000000000000000000",
			29 => "000000000000000000000000000000"
		),
		13 => (
			0 => "000000000000000000000000000000",
			1 => "000000000000000000000000000000",
			2 => "000000000000000000000000000000",
			3 => "000000000000110001100000000000",
			4 => "000000000001111011110000000000",
			5 => "000000000001111111110000000000",
			6 => "001110000001111111110000001110",
			7 => "001111110011111111111001111110",
			8 => "000111111111111111111111111100",
			9 => "000011111111111111111111111000",
			10 => "000001111111111111111111110000",
			11 => "000000111111111111111111100000",
			12 => "000000011111111111111111000000",
			13 => "000000111111111111111111100000",
			14 => "000000111111111111111111100000",
			15 => "000001111111111111111111110000",
			16 => "000111111111111111111111111100",
			17 => "001111111111111111111111111110",
			18 => "000111111111111111111111111100",
			19 => "000000111111111111111111100000",
			20 => "000000011111111111111111000000",
			21 => "000000001111111111111110000000",
			22 => "000000011111111111111111000000",
			23 => "000000111111111111111111100000",
			24 => "000000111100111111100111100000",
			25 => "000000000000111111100000000000",
			26 => "000000000000011011000000000000",
			27 => "000000000000000000000000000000",
			28 => "000000000000000000000000000000",
			29 => "000000000000000000000000000000"
		),
		14 => (
			0 => "000000000000000000000000000000",
			1 => "000000000000000000000000000000",
			2 => "000000000000000000000000000000",
			3 => "000000000000000000000000000000",
			4 => "000000000000000000000000000000",
			5 => "000000011000000000000110000000",
			6 => "000000011110011110011110000000",
			7 => "000000011111111111111110000000",
			8 => "000000011111111111111110000000",
			9 => "000000011111111111111110000000",
			10 => "000000011111111111111110000000",
			11 => "000001111111111111111100000000",
			12 => "000011111111111111111101100000",
			13 => "000111111111111111111001110000",
			14 => "000111111111111111110011111000",
			15 => "001111111111111111111111111000",
			16 => "001111001111111111111111111100",
			17 => "001111000111111111111100111100",
			18 => "001111000111111111111000111100",
			19 => "000111000111111111111000111100",
			20 => "000111000011101101110000111000",
			21 => "000011000011100101111000111000",
			22 => "000000000111100001111100110000",
			23 => "000000001111100000111100000000",
			24 => "000000001111000000000000000000",
			25 => "000000000000000000000000000000",
			26 => "000000000000000000000000000000",
			27 => "000000000000000000000000000000",
			28 => "000000000000000000000000000000",
			29 => "000000000000000000000000000000"
		),
		15 => (
			0 => "000000000000000000000000000000",
			1 => "000000000000000000000000000000",
			2 => "000000000000111111100000000000",
			3 => "000000000011111111111000000000",
			4 => "000000000111111111111100000000",
			5 => "000000000111111111111100000000",
			6 => "000000001111111111111110000000",
			7 => "000000001111111111111110000000",
			8 => "000000001111111111111110000000",
			9 => "000000001111111111111110000000",
			10 => "000000011111111111111111000000",
			11 => "000000011111111111111111000000",
			12 => "000000011111111111111111000000",
			13 => "000000001111111111111110000000",
			14 => "000000000111111111111100000000",
			15 => "000000000011111111111000000000",
			16 => "000000000111111111111000000000",
			17 => "000000001111111111111000000000",
			18 => "000000011111111111111100000000",
			19 => "000000011111111111111100000000",
			20 => "000000001111111111111110000000",
			21 => "000000000011111111111110000000",
			22 => "000000000011111111101100000000",
			23 => "000000000011111111000000000000",
			24 => "000000000001111000000000000000",
			25 => "000000000001111000000000000000",
			26 => "000000000000110000000000000000",
			27 => "000000000000000000000000000000",
			28 => "000000000000000000000000000000",
			29 => "000000000000000000000000000000"
	));

	-- colors
	--white: 255, 255, 255
	--grey: 158 * 3
	--light red: 255, 73, 79
	--red: 255, 0, 0
	--dark red: 182, 0, 0

	-- TYPES
	type Position is record
		x, y : std_logic_vector(3 downto 0);
	end record;

	type Offset is record
		x, y : std_logic_vector(4 downto 0);
	end record;

	type PxPos is record
		x : std_logic_vector(8 downto 0);
		y : std_logic_vector(8 downto 0);
	end record;

	type Direction is (DownDir, LeftDir, RightDir, UpDir);

	type BaseElem is (Empty, Path, RedBG, LightRedBG, WhiteBG, GreyBG, DarkRedBG, BasicTower, PoisonTower, SlowTower);
	type GridElem is record
		base : BaseElem;	-- base element
		level : std_logic_vector(1 downto 0);	-- level of tower, 0-2
		dir : Direction;	-- direction tower is facing
		anim : std_logic;	-- tower animation position, 0-1
	end record;
	type GridType is array(255 downto 0) of GridElem;

	type EnemyDest is record
		pos : PxPos;
		dir : Direction;
	end record;
	type EnemyStatus is (Dead, Normal, Slow, Poison, SlowPoison);
	type Enemy is record
		hp : std_logic_vector(14 downto 0);
		pos : PxPos;
		dir : Direction;
		status : EnemyStatus;
		anim : std_logic;
		nextI : std_logic_vector(5 downto 0);
		deathCntr : std_logic_vector(23 downto 0);
	end record;
	type EnemyArr is array(NUM_ENEMIES - 1 downto 0) of Enemy;

	type ShotVelocity is record
		x, y : std_logic_vector(6 downto 0);
	end record;
	type UpgradeType is (BasicCreate, RangeUp, DamageUp, SpeedUp, SlowUp, PoisonUp);
	type ModType is (BasicMod, SlowMod, PoisonMod);
	type Tower is record
		gridI : std_logic_vector(7 downto 0);
		rng : std_logic_vector(11 downto 0);	-- actually radius^2 for easier comparison
		damage : std_logic_vector(14 downto 0);
		speed : std_logic_vector(1 downto 0);
		shotCntr : std_logic_vector(20 downto 0);	-- 50MHz / 2^21 / MAX_TOWERS (32) = .75Hz; value is -1 when not shooting
		shotVelo : ShotVelocity;
		shotPos : PxPos;
		modifier : ModType;
	end record;
	type TowerArr is array(MAX_TOWERS - 1 downto 0) of Tower;

	-- FUNCTIONS
	function get_base_elem(base : BaseElem) return GridElem;

	-- convert position to grid index
	function pos_to_i(pos : Position) return std_logic_vector;
	function i_to_pos(i : std_logic_vector(7 downto 0)) return Position;

	function get_addr(	base : std_logic_vector(17 downto 0);
						x : std_logic_vector(4 downto 0);
						y : std_logic_vector(4 downto 0)) return std_logic_vector;
	
	
	function get_start_hp(lvl : std_logic_vector(7 downto 0)) return std_logic_vector;
	function get_gold_per_enemy(lvl : std_logic_vector(7 downto 0)) return std_logic_vector;

	-- alias for conv_std_logic_vector to save keystrokes
	function tov(i : integer; width : integer) return std_logic_vector;

	function can_place_twr(elem : BaseElem) return boolean;
	function is_tower_elem(elem : BaseElem) return boolean;

	function square_vec(n : signed(6 downto 0)) return unsigned;
--	function square_lt5(n : integer) return integer;

	function chk_font_x(DrawX : std_logic_vector(9 downto 0); startX : integer) return boolean;
	function chk_font_y(DrawY : std_logic_vector(9 downto 0); startY : integer) return boolean;
end Constants;

package body Constants is
	function get_base_elem(base : BaseElem) return GridElem is
	begin
		return (base => base,
				level => "00",
				dir => DownDir,
				anim => '0'
		);
	end get_base_elem;

	function pos_to_i(pos : Position) return std_logic_vector is
	begin
		return pos.y & pos.x;	-- same as pos.y * 16 + pos.x
	end pos_to_i;

	function i_to_pos(i : std_logic_vector(7 downto 0)) return Position is
		variable ret : Position;
	begin
		ret.x := i(3 downto 0);
		ret.y := i(7 downto 4);
		return ret;
	end i_to_pos;

	function get_addr(	base : std_logic_vector(17 downto 0);
						x : std_logic_vector(4 downto 0);
						y : std_logic_vector(4 downto 0)) return std_logic_vector is
	begin
		return base + y * conv_std_logic_vector(30, 13) + ("0000000000000" & x);
	end get_addr;

	function tov(i : integer; width : integer) return std_logic_vector is
	begin
		return conv_std_logic_vector(i, width);
	end tov;

	function can_place_twr(elem : BaseElem) return boolean is
	begin
		return (elem /= Path and elem /= BasicTower and elem /= PoisonTower and elem /= SlowTower);
	end can_place_twr;

	function square_vec(n : signed(6 downto 0)) return unsigned is
	begin
		case n is
			when conv_signed(-64, 7) =>
				return "XXXXXXXXXXXX";
			when conv_signed(-63, 7) =>
				return "XXXXXXXXXXXX";
			when conv_signed(-62, 7) =>
				return "XXXXXXXXXXXX";
			when conv_signed(-61, 7) =>
				return "XXXXXXXXXXXX";
			when conv_signed(-60, 7) =>
				return "XXXXXXXXXXXX";
			when conv_signed(-59, 7) =>
				return "XXXXXXXXXXXX";
			when conv_signed(-58, 7) =>
				return "XXXXXXXXXXXX";
			when conv_signed(-57, 7) =>
				return conv_unsigned(3249, 12);
			when conv_signed(-56, 7) =>
				return conv_unsigned(3136, 12);
			when conv_signed(-55, 7) =>
				return conv_unsigned(3025, 12);
			when conv_signed(-54, 7) =>
				return conv_unsigned(2916, 12);
			when conv_signed(-53, 7) =>
				return conv_unsigned(2809, 12);
			when conv_signed(-52, 7) =>
				return conv_unsigned(2704, 12);
			when conv_signed(-51, 7) =>
				return conv_unsigned(2601, 12);
			when conv_signed(-50, 7) =>
				return conv_unsigned(2500, 12);
			when conv_signed(-49, 7) =>
				return conv_unsigned(2401, 12);
			when conv_signed(-48, 7) =>
				return conv_unsigned(2304, 12);
			when conv_signed(-47, 7) =>
				return conv_unsigned(2209, 12);
			when conv_signed(-46, 7) =>
				return conv_unsigned(2116, 12);
			when conv_signed(-45, 7) =>
				return conv_unsigned(2025, 12);
			when conv_signed(-44, 7) =>
				return conv_unsigned(1936, 12);
			when conv_signed(-43, 7) =>
				return conv_unsigned(1849, 12);
			when conv_signed(-42, 7) =>
				return conv_unsigned(1764, 12);
			when conv_signed(-41, 7) =>
				return conv_unsigned(1681, 12);
			when conv_signed(-40, 7) =>
				return conv_unsigned(1600, 12);
			when conv_signed(-39, 7) =>
				return conv_unsigned(1521, 12);
			when conv_signed(-38, 7) =>
				return conv_unsigned(1444, 12);
			when conv_signed(-37, 7) =>
				return conv_unsigned(1369, 12);
			when conv_signed(-36, 7) =>
				return conv_unsigned(1296, 12);
			when conv_signed(-35, 7) =>
				return conv_unsigned(1225, 12);
			when conv_signed(-34, 7) =>
				return conv_unsigned(1156, 12);
			when conv_signed(-33, 7) =>
				return conv_unsigned(1089, 12);
			when conv_signed(-32, 7) =>
				return conv_unsigned(1024, 12);
			when conv_signed(-31, 7) =>
				return conv_unsigned(961, 12);
			when conv_signed(-30, 7) =>
				return conv_unsigned(900, 12);
			when conv_signed(-29, 7) =>
				return conv_unsigned(841, 12);
			when conv_signed(-28, 7) =>
				return conv_unsigned(784, 12);
			when conv_signed(-27, 7) =>
				return conv_unsigned(729, 12);
			when conv_signed(-26, 7) =>
				return conv_unsigned(676, 12);
			when conv_signed(-25, 7) =>
				return conv_unsigned(625, 12);
			when conv_signed(-24, 7) =>
				return conv_unsigned(576, 12);
			when conv_signed(-23, 7) =>
				return conv_unsigned(529, 12);
			when conv_signed(-22, 7) =>
				return conv_unsigned(484, 12);
			when conv_signed(-21, 7) =>
				return conv_unsigned(441, 12);
			when conv_signed(-20, 7) =>
				return conv_unsigned(400, 12);
			when conv_signed(-19, 7) =>
				return conv_unsigned(361, 12);
			when conv_signed(-18, 7) =>
				return conv_unsigned(324, 12);
			when conv_signed(-17, 7) =>
				return conv_unsigned(289, 12);
			when conv_signed(-16, 7) =>
				return conv_unsigned(256, 12);
			when conv_signed(-15, 7) =>
				return conv_unsigned(225, 12);
			when conv_signed(-14, 7) =>
				return conv_unsigned(196, 12);
			when conv_signed(-13, 7) =>
				return conv_unsigned(169, 12);
			when conv_signed(-12, 7) =>
				return conv_unsigned(144, 12);
			when conv_signed(-11, 7) =>
				return conv_unsigned(121, 12);
			when conv_signed(-10, 7) =>
				return conv_unsigned(100, 12);
			when conv_signed(-9, 7) =>
				return conv_unsigned(81, 12);
			when conv_signed(-8, 7) =>
				return conv_unsigned(64, 12);
			when conv_signed(-7, 7) =>
				return conv_unsigned(49, 12);
			when conv_signed(-6, 7) =>
				return conv_unsigned(36, 12);
			when conv_signed(-5, 7) =>
				return conv_unsigned(25, 12);
			when conv_signed(-4, 7) =>
				return conv_unsigned(16, 12);
			when conv_signed(-3, 7) =>
				return conv_unsigned(9, 12);
			when conv_signed(-2, 7) =>
				return conv_unsigned(4, 12);
			when conv_signed(-1, 7) =>
				return conv_unsigned(1, 12);
			when conv_signed(0, 7) =>
				return conv_unsigned(0, 12);
			when conv_signed(1, 7) =>
				return conv_unsigned(1, 12);
			when conv_signed(2, 7) =>
				return conv_unsigned(4, 12);
			when conv_signed(3, 7) =>
				return conv_unsigned(9, 12);
			when conv_signed(4, 7) =>
				return conv_unsigned(16, 12);
			when conv_signed(5, 7) =>
				return conv_unsigned(25, 12);
			when conv_signed(6, 7) =>
				return conv_unsigned(36, 12);
			when conv_signed(7, 7) =>
				return conv_unsigned(49, 12);
			when conv_signed(8, 7) =>
				return conv_unsigned(64, 12);
			when conv_signed(9, 7) =>
				return conv_unsigned(81, 12);
			when conv_signed(10, 7) =>
				return conv_unsigned(100, 12);
			when conv_signed(11, 7) =>
				return conv_unsigned(121, 12);
			when conv_signed(12, 7) =>
				return conv_unsigned(144, 12);
			when conv_signed(13, 7) =>
				return conv_unsigned(169, 12);
			when conv_signed(14, 7) =>
				return conv_unsigned(196, 12);
			when conv_signed(15, 7) =>
				return conv_unsigned(225, 12);
			when conv_signed(16, 7) =>
				return conv_unsigned(256, 12);
			when conv_signed(17, 7) =>
				return conv_unsigned(289, 12);
			when conv_signed(18, 7) =>
				return conv_unsigned(324, 12);
			when conv_signed(19, 7) =>
				return conv_unsigned(361, 12);
			when conv_signed(20, 7) =>
				return conv_unsigned(400, 12);
			when conv_signed(21, 7) =>
				return conv_unsigned(441, 12);
			when conv_signed(22, 7) =>
				return conv_unsigned(484, 12);
			when conv_signed(23, 7) =>
				return conv_unsigned(529, 12);
			when conv_signed(24, 7) =>
				return conv_unsigned(576, 12);
			when conv_signed(25, 7) =>
				return conv_unsigned(625, 12);
			when conv_signed(26, 7) =>
				return conv_unsigned(676, 12);
			when conv_signed(27, 7) =>
				return conv_unsigned(729, 12);
			when conv_signed(28, 7) =>
				return conv_unsigned(784, 12);
			when conv_signed(29, 7) =>
				return conv_unsigned(841, 12);
			when conv_signed(30, 7) =>
				return conv_unsigned(900, 12);
			when conv_signed(31, 7) =>
				return conv_unsigned(961, 12);
			when conv_signed(32, 7) =>
				return conv_unsigned(1024, 12);
			when conv_signed(33, 7) =>
				return conv_unsigned(1089, 12);
			when conv_signed(34, 7) =>
				return conv_unsigned(1156, 12);
			when conv_signed(35, 7) =>
				return conv_unsigned(1225, 12);
			when conv_signed(36, 7) =>
				return conv_unsigned(1296, 12);
			when conv_signed(37, 7) =>
				return conv_unsigned(1369, 12);
			when conv_signed(38, 7) =>
				return conv_unsigned(1444, 12);
			when conv_signed(39, 7) =>
				return conv_unsigned(1521, 12);
			when conv_signed(40, 7) =>
				return conv_unsigned(1600, 12);
			when conv_signed(41, 7) =>
				return conv_unsigned(1681, 12);
			when conv_signed(42, 7) =>
				return conv_unsigned(1764, 12);
			when conv_signed(43, 7) =>
				return conv_unsigned(1849, 12);
			when conv_signed(44, 7) =>
				return conv_unsigned(1936, 12);
			when conv_signed(45, 7) =>
				return conv_unsigned(2025, 12);
			when conv_signed(46, 7) =>
				return conv_unsigned(2116, 12);
			when conv_signed(47, 7) =>
				return conv_unsigned(2209, 12);
			when conv_signed(48, 7) =>
				return conv_unsigned(2304, 12);
			when conv_signed(49, 7) =>
				return conv_unsigned(2401, 12);
			when conv_signed(50, 7) =>
				return conv_unsigned(2500, 12);
			when conv_signed(51, 7) =>
				return conv_unsigned(2601, 12);
			when conv_signed(52, 7) =>
				return conv_unsigned(2704, 12);
			when conv_signed(53, 7) =>
				return conv_unsigned(2809, 12);
			when conv_signed(54, 7) =>
				return conv_unsigned(2916, 12);
			when conv_signed(55, 7) =>
				return conv_unsigned(3025, 12);
			when conv_signed(56, 7) =>
				return conv_unsigned(3136, 12);
			when conv_signed(57, 7) =>
				return conv_unsigned(3249, 12);
			when conv_signed(58, 7) =>
				return "XXXXXXXXXXXX";
			when conv_signed(59, 7) =>
				return "XXXXXXXXXXXX";
			when conv_signed(60, 7) =>
				return "XXXXXXXXXXXX";
			when conv_signed(61, 7) =>
				return "XXXXXXXXXXXX";
			when conv_signed(62, 7) =>
				return "XXXXXXXXXXXX";
			when conv_signed(63, 7) =>
				return "XXXXXXXXXXXX";
		end case;
	end square_vec;

--	function square_lt5(n : integer) return integer is
--	begin
--		case n is
--			when 0 =>
--				return 0;
--			when 1 =>
--				return 1 ;
--			when -1 =>
--				return 1 ;
--			when 2 =>
--				return 4 ;
--			when -2 =>
--				return 4 ;
--			when 3 =>
--				return 9 ;
--			when -3 =>
--				return 9 ;
--			when 4 =>
--				return 16 ;
--			when -4 =>
--				return 16 ;
--			when 5 =>
--				return 25 ;
--			when -5 =>
--				return 25 ;
--			when others =>
--				return 26 ;
--		end case;
--	end square_lt5;

	function is_tower_elem(elem : BaseElem) return boolean is
	begin
		return (elem = BasicTower or elem = PoisonTower or elem = SlowTower);
	end is_tower_elem;

	function chk_font_x(DrawX : std_logic_vector(9 downto 0); startX : integer) return boolean is
	begin
		return DrawX >= tov(startX, 10) and DrawX < tov(startX + 8, 10);
	end chk_font_x;

	function chk_font_y(DrawY : std_logic_vector(9 downto 0); startY : integer) return boolean is
	begin
		return DrawY >= tov(startY, 10) and DrawY < tov(startY + 16, 10);
	end chk_font_y;

	function get_start_hp(lvl : std_logic_vector(7 downto 0)) return std_logic_vector is
	begin
		-- generated by tmp.py
		case lvl is
			when tov(0, 8) =>
				return tov(2, 15);
			when tov(1, 8) =>
				return tov(2, 15);
			when tov(2, 8) =>
				return tov(5, 15);
			when tov(3, 8) =>
				return tov(9, 15);
			when tov(4, 8) =>
				return tov(14, 15);
			when tov(5, 8) =>
				return tov(22, 15);
			when tov(6, 8) =>
				return tov(30, 15);
			when tov(7, 8) =>
				return tov(41, 15);
			when tov(8, 8) =>
				return tov(53, 15);
			when tov(9, 8) =>
				return tov(66, 15);
			when tov(10, 8) =>
				return tov(82, 15);
			when tov(11, 8) =>
				return tov(98, 15);
			when tov(12, 8) =>
				return tov(117, 15);
			when tov(13, 8) =>
				return tov(137, 15);
			when tov(14, 8) =>
				return tov(158, 15);
			when tov(15, 8) =>
				return tov(181, 15);
			when tov(16, 8) =>
				return tov(206, 15);
			when tov(17, 8) =>
				return tov(233, 15);
			when tov(18, 8) =>
				return tov(261, 15);
			when tov(19, 8) =>
				return tov(290, 15);
			when tov(20, 8) =>
				return tov(321, 15);
			when tov(21, 8) =>
				return tov(354, 15);
			when tov(22, 8) =>
				return tov(389, 15);
			when tov(23, 8) =>
				return tov(425, 15);
			when tov(24, 8) =>
				return tov(462, 15);
			when tov(25, 8) =>
				return tov(501, 15);
			when tov(26, 8) =>
				return tov(542, 15);
			when tov(27, 8) =>
				return tov(584, 15);
			when tov(28, 8) =>
				return tov(628, 15);
			when tov(29, 8) =>
				return tov(674, 15);
			when tov(30, 8) =>
				return tov(721, 15);
			when tov(31, 8) =>
				return tov(770, 15);
			when tov(32, 8) =>
				return tov(820, 15);
			when tov(33, 8) =>
				return tov(872, 15);
			when tov(34, 8) =>
				return tov(926, 15);
			when tov(35, 8) =>
				return tov(981, 15);
			when tov(36, 8) =>
				return tov(1037, 15);
			when tov(37, 8) =>
				return tov(1095, 15);
			when tov(38, 8) =>
				return tov(1155, 15);
			when tov(39, 8) =>
				return tov(1217, 15);
			when tov(40, 8) =>
				return tov(1280, 15);
			when tov(41, 8) =>
				return tov(1344, 15);
			when tov(42, 8) =>
				return tov(1410, 15);
			when tov(43, 8) =>
				return tov(1478, 15);
			when tov(44, 8) =>
				return tov(1547, 15);
			when tov(45, 8) =>
				return tov(1618, 15);
			when tov(46, 8) =>
				return tov(1691, 15);
			when tov(47, 8) =>
				return tov(1765, 15);
			when tov(48, 8) =>
				return tov(1840, 15);
			when tov(49, 8) =>
				return tov(1917, 15);
			when tov(50, 8) =>
				return tov(1996, 15);
			when tov(51, 8) =>
				return tov(2076, 15);
			when tov(52, 8) =>
				return tov(2158, 15);
			when tov(53, 8) =>
				return tov(2241, 15);
			when tov(54, 8) =>
				return tov(2326, 15);
			when tov(55, 8) =>
				return tov(2413, 15);
			when tov(56, 8) =>
				return tov(2501, 15);
			when tov(57, 8) =>
				return tov(2590, 15);
			when tov(58, 8) =>
				return tov(2681, 15);
			when tov(59, 8) =>
				return tov(2774, 15);
			when tov(60, 8) =>
				return tov(2868, 15);
			when tov(61, 8) =>
				return tov(2963, 15);
			when tov(62, 8) =>
				return tov(3060, 15);
			when tov(63, 8) =>
				return tov(3159, 15);
			when tov(64, 8) =>
				return tov(3259, 15);
			when tov(65, 8) =>
				return tov(3361, 15);
			when tov(66, 8) =>
				return tov(3464, 15);
			when tov(67, 8) =>
				return tov(3569, 15);
			when tov(68, 8) =>
				return tov(3675, 15);
			when tov(69, 8) =>
				return tov(3782, 15);
			when tov(70, 8) =>
				return tov(3892, 15);
			when tov(71, 8) =>
				return tov(4002, 15);
			when tov(72, 8) =>
				return tov(4114, 15);
			when tov(73, 8) =>
				return tov(4228, 15);
			when tov(74, 8) =>
				return tov(4343, 15);
			when tov(75, 8) =>
				return tov(4459, 15);
			when tov(76, 8) =>
				return tov(4577, 15);
			when tov(77, 8) =>
				return tov(4696, 15);
			when tov(78, 8) =>
				return tov(4817, 15);
			when tov(79, 8) =>
				return tov(4939, 15);
			when tov(80, 8) =>
				return tov(5063, 15);
			when tov(81, 8) =>
				return tov(5188, 15);
			when tov(82, 8) =>
				return tov(5315, 15);
			when tov(83, 8) =>
				return tov(5442, 15);
			when tov(84, 8) =>
				return tov(5572, 15);
			when tov(85, 8) =>
				return tov(5702, 15);
			when tov(86, 8) =>
				return tov(5834, 15);
			when tov(87, 8) =>
				return tov(5968, 15);
			when tov(88, 8) =>
				return tov(6103, 15);
			when tov(89, 8) =>
				return tov(6239, 15);
			when tov(90, 8) =>
				return tov(6376, 15);
			when tov(91, 8) =>
				return tov(6515, 15);
			when tov(92, 8) =>
				return tov(6655, 15);
			when tov(93, 8) =>
				return tov(6797, 15);
			when tov(94, 8) =>
				return tov(6939, 15);
			when tov(95, 8) =>
				return tov(7083, 15);
			when tov(96, 8) =>
				return tov(7229, 15);
			when tov(97, 8) =>
				return tov(7376, 15);
			when tov(98, 8) =>
				return tov(7523, 15);
			when tov(99, 8) =>
				return tov(7673, 15);
			when tov(100, 8) =>
				return tov(7823, 15);
			when tov(101, 8) =>
				return tov(7975, 15);
			when tov(102, 8) =>
				return tov(8128, 15);
			when tov(103, 8) =>
				return tov(8282, 15);
			when tov(104, 8) =>
				return tov(8437, 15);
			when tov(105, 8) =>
				return tov(8594, 15);
			when tov(106, 8) =>
				return tov(8752, 15);
			when tov(107, 8) =>
				return tov(8910, 15);
			when tov(108, 8) =>
				return tov(9070, 15);
			when tov(109, 8) =>
				return tov(9232, 15);
			when tov(110, 8) =>
				return tov(9394, 15);
			when tov(111, 8) =>
				return tov(9558, 15);
			when tov(112, 8) =>
				return tov(9722, 15);
			when tov(113, 8) =>
				return tov(9888, 15);
			when tov(114, 8) =>
				return tov(10055, 15);
			when tov(115, 8) =>
				return tov(10223, 15);
			when tov(116, 8) =>
				return tov(10391, 15);
			when tov(117, 8) =>
				return tov(10561, 15);
			when tov(118, 8) =>
				return tov(10732, 15);
			when tov(119, 8) =>
				return tov(10904, 15);
			when tov(120, 8) =>
				return tov(11077, 15);
			when tov(121, 8) =>
				return tov(11251, 15);
			when tov(122, 8) =>
				return tov(11426, 15);
			when tov(123, 8) =>
				return tov(11602, 15);
			when tov(124, 8) =>
				return tov(11779, 15);
			when tov(125, 8) =>
				return tov(11957, 15);
			when tov(126, 8) =>
				return tov(12135, 15);
			when tov(127, 8) =>
				return tov(12315, 15);
			when tov(128, 8) =>
				return tov(12495, 15);
			when tov(129, 8) =>
				return tov(12677, 15);
			when tov(130, 8) =>
				return tov(12859, 15);
			when tov(131, 8) =>
				return tov(13042, 15);
			when tov(132, 8) =>
				return tov(13225, 15);
			when tov(133, 8) =>
				return tov(13410, 15);
			when tov(134, 8) =>
				return tov(13595, 15);
			when tov(135, 8) =>
				return tov(13781, 15);
			when tov(136, 8) =>
				return tov(13968, 15);
			when tov(137, 8) =>
				return tov(14155, 15);
			when tov(138, 8) =>
				return tov(14343, 15);
			when tov(139, 8) =>
				return tov(14532, 15);
			when tov(140, 8) =>
				return tov(14721, 15);
			when tov(141, 8) =>
				return tov(14911, 15);
			when tov(142, 8) =>
				return tov(15102, 15);
			when tov(143, 8) =>
				return tov(15293, 15);
			when tov(144, 8) =>
				return tov(15485, 15);
			when tov(145, 8) =>
				return tov(15677, 15);
			when tov(146, 8) =>
				return tov(15870, 15);
			when tov(147, 8) =>
				return tov(16063, 15);
			when tov(148, 8) =>
				return tov(16257, 15);
			when tov(149, 8) =>
				return tov(16451, 15);
			when tov(150, 8) =>
				return tov(16646, 15);
			when tov(151, 8) =>
				return tov(16841, 15);
			when tov(152, 8) =>
				return tov(17036, 15);
			when tov(153, 8) =>
				return tov(17232, 15);
			when tov(154, 8) =>
				return tov(17428, 15);
			when tov(155, 8) =>
				return tov(17624, 15);
			when tov(156, 8) =>
				return tov(17821, 15);
			when tov(157, 8) =>
				return tov(18018, 15);
			when tov(158, 8) =>
				return tov(18215, 15);
			when tov(159, 8) =>
				return tov(18412, 15);
			when tov(160, 8) =>
				return tov(18609, 15);
			when tov(161, 8) =>
				return tov(18807, 15);
			when tov(162, 8) =>
				return tov(19004, 15);
			when tov(163, 8) =>
				return tov(19202, 15);
			when tov(164, 8) =>
				return tov(19400, 15);
			when tov(165, 8) =>
				return tov(19598, 15);
			when tov(166, 8) =>
				return tov(19796, 15);
			when tov(167, 8) =>
				return tov(19993, 15);
			when tov(168, 8) =>
				return tov(20191, 15);
			when tov(169, 8) =>
				return tov(20389, 15);
			when tov(170, 8) =>
				return tov(20586, 15);
			when tov(171, 8) =>
				return tov(20784, 15);
			when tov(172, 8) =>
				return tov(20981, 15);
			when tov(173, 8) =>
				return tov(21178, 15);
			when tov(174, 8) =>
				return tov(21374, 15);
			when tov(175, 8) =>
				return tov(21571, 15);
			when tov(176, 8) =>
				return tov(21767, 15);
			when tov(177, 8) =>
				return tov(21963, 15);
			when tov(178, 8) =>
				return tov(22158, 15);
			when tov(179, 8) =>
				return tov(22353, 15);
			when tov(180, 8) =>
				return tov(22547, 15);
			when tov(181, 8) =>
				return tov(22741, 15);
			when tov(182, 8) =>
				return tov(22935, 15);
			when tov(183, 8) =>
				return tov(23128, 15);
			when tov(184, 8) =>
				return tov(23320, 15);
			when tov(185, 8) =>
				return tov(23512, 15);
			when tov(186, 8) =>
				return tov(23703, 15);
			when tov(187, 8) =>
				return tov(23893, 15);
			when tov(188, 8) =>
				return tov(24083, 15);
			when tov(189, 8) =>
				return tov(24272, 15);
			when tov(190, 8) =>
				return tov(24460, 15);
			when tov(191, 8) =>
				return tov(24647, 15);
			when tov(192, 8) =>
				return tov(24833, 15);
			when tov(193, 8) =>
				return tov(25019, 15);
			when tov(194, 8) =>
				return tov(25203, 15);
			when tov(195, 8) =>
				return tov(25387, 15);
			when tov(196, 8) =>
				return tov(25569, 15);
			when tov(197, 8) =>
				return tov(25750, 15);
			when tov(198, 8) =>
				return tov(25930, 15);
			when tov(199, 8) =>
				return tov(26109, 15);
			when tov(200, 8) =>
				return tov(26287, 15);
			when tov(201, 8) =>
				return tov(26464, 15);
			when tov(202, 8) =>
				return tov(26639, 15);
			when tov(203, 8) =>
				return tov(26813, 15);
			when tov(204, 8) =>
				return tov(26985, 15);
			when tov(205, 8) =>
				return tov(27156, 15);
			when tov(206, 8) =>
				return tov(27326, 15);
			when tov(207, 8) =>
				return tov(27494, 15);
			when tov(208, 8) =>
				return tov(27660, 15);
			when tov(209, 8) =>
				return tov(27825, 15);
			when tov(210, 8) =>
				return tov(27988, 15);
			when tov(211, 8) =>
				return tov(28150, 15);
			when tov(212, 8) =>
				return tov(28309, 15);
			when tov(213, 8) =>
				return tov(28467, 15);
			when tov(214, 8) =>
				return tov(28623, 15);
			when tov(215, 8) =>
				return tov(28778, 15);
			when tov(216, 8) =>
				return tov(28930, 15);
			when tov(217, 8) =>
				return tov(29080, 15);
			when tov(218, 8) =>
				return tov(29228, 15);
			when tov(219, 8) =>
				return tov(29374, 15);
			when tov(220, 8) =>
				return tov(29518, 15);
			when tov(221, 8) =>
				return tov(29660, 15);
			when tov(222, 8) =>
				return tov(29799, 15);
			when tov(223, 8) =>
				return tov(29937, 15);
			when tov(224, 8) =>
				return tov(30071, 15);
			when tov(225, 8) =>
				return tov(30204, 15);
			when tov(226, 8) =>
				return tov(30334, 15);
			when tov(227, 8) =>
				return tov(30461, 15);
			when tov(228, 8) =>
				return tov(30586, 15);
			when tov(229, 8) =>
				return tov(30708, 15);
			when tov(230, 8) =>
				return tov(30827, 15);
			when tov(231, 8) =>
				return tov(30944, 15);
			when tov(232, 8) =>
				return tov(31058, 15);
			when tov(233, 8) =>
				return tov(31169, 15);
			when tov(234, 8) =>
				return tov(31277, 15);
			when tov(235, 8) =>
				return tov(31383, 15);
			when tov(236, 8) =>
				return tov(31485, 15);
			when tov(237, 8) =>
				return tov(31584, 15);
			when tov(238, 8) =>
				return tov(31680, 15);
			when tov(239, 8) =>
				return tov(31772, 15);
			when tov(240, 8) =>
				return tov(31862, 15);
			when tov(241, 8) =>
				return tov(31948, 15);
			when tov(242, 8) =>
				return tov(32030, 15);
			when tov(243, 8) =>
				return tov(32110, 15);
			when tov(244, 8) =>
				return tov(32185, 15);
			when tov(245, 8) =>
				return tov(32257, 15);
			when tov(246, 8) =>
				return tov(32326, 15);
			when tov(247, 8) =>
				return tov(32391, 15);
			when tov(248, 8) =>
				return tov(32451, 15);
			when tov(249, 8) =>
				return tov(32509, 15);
			when tov(250, 8) =>
				return tov(32562, 15);
			when tov(251, 8) =>
				return tov(32611, 15);
			when tov(252, 8) =>
				return tov(32656, 15);
			when tov(253, 8) =>
				return tov(32697, 15);
			when tov(254, 8) =>
				return tov(32734, 15);
			when tov(255, 8) =>
				return tov(32766, 15);
		end case;
	end get_start_hp;

	function get_gold_per_enemy(lvl : std_logic_vector(7 downto 0)) return std_logic_vector is
	begin
		return ("000000" & lvl(7 downto 2)) + conv_std_logic_vector(3, 12); -- 3 + lvl / 4
	end get_gold_per_enemy;

--	function is_in_block(DrawX, DrawY : std_logic_vector(9 downto 0);
--							startX : std_logic_vector(9 downto 0);
--							startY : std_logic_vector(8 downto 0)) return boolean is
--	begin
--		if (DrawX >= startX and DrawX < startX + tov(8, 10) and DrawY >= "0" & startY and 
--	function in_range(off : PxPos) return boolean is
--		case off.x = 

--	function get_dist(pos1 : PxPos; pos2 : PxPos) return std_logic_vector(19 downto 0) is
--		return (pos1.x - pos2.x) * (pos1.x - pos2.x) + "00" & ((pos1.y - pos2.y) * (pos1.y - pos2.y));
--	end get_dist;
end Constants;
