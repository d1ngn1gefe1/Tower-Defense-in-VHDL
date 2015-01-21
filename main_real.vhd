library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

library work;
use work.Constants.all;

entity main_real is
	Port (	clk : in std_logic;
			reset : in std_logic;
			
			psClk : in std_logic;
			psData : in std_logic;

			data : in std_logic_vector(15 downto 0);	-- SRAM data bus

			addr : out std_logic_vector(17 downto 0);	-- SRAM addr bus
			ce, ub, lb, oe, we : out std_logic;	-- SRAM stuff

			hs        : out std_logic;  -- Horizontal sync pulse.  Active low
			vs        : out std_logic;  -- Vertical sync pulse.  Active low
			pixel_clk : out std_logic;  -- 25 MHz pixel clock output
			blank     : out std_logic;  -- Blanking interval indicator.  Active low.
			sync      : out std_logic;  -- Composite Sync signal.  Active low.  We don't use it in this lab,

			h0 : out std_logic_vector(6 downto 0);
			h1 : out std_logic_vector(6 downto 0);
			h2 : out std_logic_vector(6 downto 0);
			h3 : out std_logic_vector(6 downto 0);

			R, G, B: out std_logic_vector(9 downto 0);

			AUD_MCLK :             		OUT std_logic; -- Codec master clock OUTPUT
			AUD_BCLK :             		IN std_logic; -- Digital Audio bit clock
			AUD_DACDAT :           		OUT std_logic; -- DAC data line
			AUD_DACLRCK :				IN std_logic; -- DAC data left/right select
			I2C_SDAT :             		OUT std_logic; -- serial interface data line
			I2C_SCLK :             		OUT std_logic);  -- serial interface clock
end main_real;

architecture Behavioral of main_real is
	component font_rom is
		port(
				clk: in std_logic;
				addr: in std_logic_vector(10 downto 0);
				data: out std_logic_vector(7 downto 0)
			);
	end component;

	component HexDriver is
		port ( In0 : in std_logic_vector(3 downto 0);
			   Out0 : out std_logic_vector(6 downto 0));
	end component;

	component Color_Mapper is
		Port (	pxlClk : in std_logic;
				reset : in std_logic;
				
				data : in std_logic_vector(15 downto 0);	-- SRAM data bus
				fontData : in std_logic_vector(7 downto 0);

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
			
				fontAddr : out std_logic_vector(10 downto 0);
				addr : out std_logic_vector(17 downto 0);	-- SRAM addr bus
				ce, ub, lb, oe, we : out std_logic;	-- SRAM stuff

				R   : out std_logic_vector(9 downto 0);
				G	: out std_logic_vector(9 downto 0);
				B	: out std_logic_vector(9 downto 0));
	end component;

	component vga_controller is 
	  Port ( clk       : in  std_logic;  -- 50 MHz clock
			 reset     : in  std_logic;  -- reset signal
			 hs        : out std_logic;  -- Horizontal sync pulse.  Active low
			 vs        : out std_logic;  -- Vertical sync pulse.  Active low
			 pixel_clk : out std_logic;  -- 25 MHz pixel clock output
			 blank     : out std_logic;  -- Blanking interval indicator.  Active low.
			 sync      : out std_logic;  -- Composite Sync signal.  Active low.  We don't use it in this lab,
										 --   but the video DAC on the DE2 board requires an input for it.
			 DrawX     : out std_logic_vector(9 downto 0);  -- horizontal coordinate
			 DrawY     : out std_logic_vector(9 downto 0));	-- vertical coordinate
	end component;

	component Keyboard is
		Port ( 	clk : in std_logic;
				psClk : in std_logic;
				psData : in std_logic;
				reset : in std_logic;
				keyCode : buffer std_logic_vector(7 downto 0);
				keyDown : out std_logic;
				keyUp : out std_logic);
	end component;

	component Controller is
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
	end component;

	component Enemies is 
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
	end component;

	component Grid is
		Port (	reset : in std_logic;
				clk : in std_logic;

				place : in std_logic;	-- control sig to place new item
				newItem : in GridElem;

				changeMod : in std_logic;	-- changes base elem; modifies grid at cursorI
				newMod : in BaseElem;

				changeDir : in std_logic;	-- these control sigs modify grid at cmdI
				newDir : in Direction;
				changeAnim : in std_logic;	-- toggle animation
				incLvl : in std_logic;
				cmdI : in std_logic_vector(7 downto 0);

				moveCursor : in std_logic;	-- control sig to move cursor
				moveDir : in Direction;

				grid : out GridType;
				curI : out std_logic_vector(7 downto 0);

				cursorI : out std_logic_vector(7 downto 0);
				curBaseElem : out BaseElem);
	end component;

	component Towers is 
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
	end component;

	component Bin2BCD is
		generic (   binW : integer;
					bcdW : integer);
		Port (	bin : in std_logic_vector(binW - 1 downto 0);
				bcd : out std_logic_vector(bcdW - 1 downto 0));
	end component;

	component audio_interface IS
	PORT(	attack :                   IN std_logic;
			clk, Reset_n :      	IN std_logic; 
			AUD_MCLK :             		OUT std_logic; -- Codec master clock OUTPUT
			AUD_BCLK :             		IN std_logic; -- Digital Audio bit clock
			AUD_DACDAT :           		OUT std_logic; -- DAC data line
			AUD_DACLRCK :				IN std_logic; -- DAC data left/right select
			I2C_SDAT :             		OUT std_logic; -- serial interface data line
			I2C_SCLK :             		OUT std_logic  -- serial interface clock
		);
	END component;

	signal gridData : GridType;
	signal cursorI : std_logic_vector(7 downto 0);
	signal resetH : std_logic;
	signal vgaClk : std_logic;

	signal keyCode : std_logic_vector(7 downto 0);
	signal keyDown : std_logic;

	signal DrawX, DrawY : std_logic_vector(9 downto 0);

	signal placeItem : std_logic;	-- control sig to place new item
	signal newItem : GridElem;

	signal killAll : std_logic;
	signal startLvl : std_logic;

	signal escaped : std_logic;

	signal moveCursor : std_logic;	-- control sig to move cursor
	signal moveDir : Direction;

	signal enemArr : EnemyArr;

	signal level : std_logic_vector(7 downto 0);
	signal levelBCD : std_logic_vector(11 downto 0);
	signal livesBCD : std_logic_vector(7 downto 0);
	signal gold : std_logic_vector(15 downto 0);
	signal goldBCD : std_logic_vector(19 downto 0);

	signal attackI : std_logic_vector(4 downto 0);
	signal damage : std_logic_vector(14 downto 0);
	signal statusMod : EnemyStatus;

	signal twrArr : TowerArr;

	signal killed : std_logic_vector(3 downto 0);
	signal lives : std_logic_vector(4 downto 0);
	signal placeTwr : std_logic;
	signal upgrade : UpgradeType;
	signal changeMod : std_logic;
	signal newMod : BaseElem;
	signal changeDir : std_logic;
	signal newDir : Direction;
	signal changeAnim : std_logic;
	signal incLvl : std_logic;
	signal cmdI : std_logic_vector(7 downto 0);
	signal curI : std_logic_vector(7 downto 0);
	signal curBaseElem : BaseElem;

	signal fontAddr : std_logic_vector(10 downto 0);
	signal fontData : std_logic_vector(7 downto 0);

	signal curDamage : std_logic_vector(14 downto 0);
	signal curRng : std_logic_vector(11 downto 0);
	signal curSpeed : std_logic_vector(1 downto 0);

	signal curDamageBCD : std_logic_vector(19 downto 0);
	signal curRngBCD : std_logic_vector(15 downto 0);

	signal numTwrs : std_logic_vector(5 downto 0);

	signal attack : std_logic;

	signal poke : std_logic_vector(15 downto 0);
begin
	resetH <= not reset;
	pixel_clk <= vgaClk;

	attack <= '1' when damage /= tov(0, 15) else '0';

	myColorMapper : Color_Mapper
	Port map (	pxlClk => vgaClk,
				reset => resetH,
				
				data => data,
				fontData => fontData,

				DrawX => DrawX,
				DrawY => DrawY,

				grid => gridData,
				curI => curI,
				cursorI => cursorI,

				enemArr => enemArr,
				twrArr => twrArr,
				curBaseElem => curBaseElem,

				goldBCD => goldBCD,
				level => level,
				levelBCD => levelBCD,
				livesBCD => livesBCD,
				
				curDamageBCD => curDamageBCD,
				curRngBCD => curRngBCD,
				curSpeed => curSpeed,

				fontAddr => fontAddr,
				addr => addr,
				ce => ce,
				ub => ub,
				lb => lb,
				oe => oe,
				we => we,

				R => R,
				G => G,
				B => B);

	myVga : vga_controller
	Port map(clk => clk,
			 reset => resetH,
			 hs => hs,
			 vs => vs,
			 pixel_clk => vgaClk,
			 blank => blank,
			 sync => sync,
			 DrawX => DrawX,
			 DrawY => DrawY);

	myKeyboard : Keyboard
	Port map( 	clk => clk,
				psClk => psClk,
				psData => psData,
				reset => resetH,
				keyCode => keyCode,
				keyDown => keyDown,
				keyUp => open);

	myCtrl : Controller
	port map(	clk => clk,
				reset => resetH,

				keyCode => keyCode,
				keyDown => keyDown,

				curBaseElem => curBaseElem,

				escaped => escaped,
				killed => killed,

				curDamage => curDamage,
				curRng => curRng,
				curSpeed => curSpeed,
				numTwrs => numTwrs,

				gold => gold,
				level => level,
				lives => lives,

				killAll => killAll,
				startLvl => startLvl,

				placeTwr => placeTwr,
				upgrade => upgrade,

				placeItem => placeItem,
				newItem => newItem,

				moveCursor => moveCursor,
				moveDir => moveDir,
			
				changeMod => changeMod,
				newMod => newMod,
				incLvl => incLvl);

	myEnems : Enemies
	port map (	clk => clk,
				reset => resetH,
				level => level,

				startLvl => startLvl,
				killAll => killAll,

				attackI => attackI,
				damage => damage,
				statusMod => statusMod,

				escaped => escaped,
				killed => killed,
				enemArr => enemArr,

				poke => open);

	myGrid : Grid
	port map(	reset => resetH,
				clk => clk,

				place => placeItem,
				newItem => newItem,

				changeMod => changeMod,
				newMod => newMod,

				changeDir => changeDir,
				newDir => newDir,
				changeAnim => changeAnim,
				incLvl => incLvl,
				cmdI => cmdI,

				moveCursor => moveCursor,
				moveDir => moveDir,

				grid => gridData,
				curI => curI,

				cursorI => cursorI,
				curBaseElem => curBaseElem);

	myTowers : Towers
	port map(	clk => clk,
				reset => resetH,

				enemArr => enemArr,

				-- control signals to place/upgrade tower at cursor
				placeTwr => placeTwr,
				upgrade => upgrade,
				cursorI => cursorI,

				-- control signals that go straight to grid
				changeDir => changeDir,
				newDir => newDir,
				changeAnim => changeAnim,
				cmdI => cmdI,

				-- control signals that go straight to enemies
				attackI => attackI,
				damage => damage,
				statusMod => statusMod,

				twrArr => twrArr,

				curDamage => curDamage,
				curRng => curRng,
				curSpeed => curSpeed,
			
				numTwrs => numTwrs);

	myFonts : font_rom
	port map(	clk => clk,
				addr => fontAddr,
				data => fontData);

	myBin2BCDGold : Bin2BCD
	generic map(	binW => 16, bcdW => 20)
	port map(	bin => gold,
				bcd => goldBCD);

	myBin2BCDLvl : Bin2BCD
	generic map(	binW => 8, bcdW => 12)
	port map(	bin => level + tov(1, 8),
				bcd => levelBCD);

	myBin2BCDLives : Bin2BCD
	generic map(	binW => 5, bcdW => 8)
	port map(	bin => lives,
				bcd => livesBCD);

	myBin2BCDDamage : Bin2BCD
	generic map(	binW => 15, bcdW => 20)
	port map(	bin => curDamage,
				bcd => curDamageBCD);

	myBin2BCDRange : Bin2BCD
	generic map(	binW => 12, bcdW => 16)
	port map(	bin => curRng,
				bcd => curRngBCD);

	hex0 : HexDriver
	port map( In0 => poke(3 downto 0),
			   Out0 => h0);
	hex1 : HexDriver
	port map( In0 => poke(7 downto 4),
			   Out0 => h1);
	hex2 : HexDriver
	port map( In0 => poke(11 downto 8),
			   Out0 => h2);
	hex3 : HexDriver
	port map( In0 => poke(15 downto 12),
			   Out0 => h3);

	myAudio : audio_interface
	port map(	attack => attack,
				clk => clk,
				Reset_n => reset,
				AUD_MCLK => AUD_MCLK,
				AUD_BCLK => AUD_BCLK,
				AUD_DACDAT => AUD_DACDAT,
				AUD_DACLRCK => AUD_DACLRCK,
				I2C_SDAT => I2C_SDAT,
				I2C_SCLK => I2C_SCLK);
end Behavioral;
