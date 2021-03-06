-- audio_interface
-- 
-- This entity implements A/D and D/A capability on the Altera DE2
-- WM8731 Audio Codec. Setup of the codec requires the use of I2C
-- to set parameters located in I2C registers. Setup options can
-- be found in the SCI_REG_ROM and SCI_DAT_ROM. This entity is
-- capable of sampling at 48 kHz with 16 bit samples, one sample
-- for the left channel and one sample for the right channel.
-- 
-- Version 1.0
--
-- Designer: Koushik Roy
-- April 23, 2010

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY audio_interface IS
	PORT
	(
		attack :                   IN std_logic;
		clk, Reset_n :      	IN std_logic; 
		AUD_MCLK :             		OUT std_logic; -- Codec master clock OUTPUT
		AUD_BCLK :             		IN std_logic; -- Digital Audio bit clock
		AUD_DACDAT :           		OUT std_logic; -- DAC data line
		AUD_DACLRCK : IN std_logic; -- DAC data left/right select
		I2C_SDAT :             		OUT std_logic; -- serial interface data line
		I2C_SCLK :             		OUT std_logic  -- serial interface clock
	);
END audio_interface;

ARCHITECTURE Behavorial OF audio_interface IS

TYPE I2C_state is (initialize, start, b0, b1, b2, b3, b4, b5, b6, b7, b_ack, 
					a0, a1, a2, a3, a4, a5, a6, a7, a_ack,
					d0, d1, d2, d3, d4, d5, d6, d7, d_ack,
					b_stop0, b_stop1, b_end);
					
TYPE DAC_state is (initial, sync, shift, refill, reload);

signal Bcount : integer range 0 to 31;
signal word_count : integer range 0 to 12;
signal LRDATA : std_logic_vector(31 downto 0); -- stores L&R data
signal state, next_state : I2C_state;
signal SCI_ADDR, SCI_WORD1, SCI_WORD2 : std_logic_vector(7 downto 0);

signal i2c_counter : std_logic_vector(9 downto 0);
signal SCLK_int, sck0, sck1, count_en, word_reset : std_logic;
signal SCLK_inhibit : std_logic;

signal dack0, dack1, bck0, bck1, flag : std_logic;

signal reset : std_logic;

CONSTANT word_limit : integer := 8;

type rom_type is array (0 to word_limit) of std_logic_vector(7 downto 0);

constant SCI_REG_ROM : rom_type := (
	x"12", -- Deactivate, R9
	x"01", -- Mute L/R, Load Simul, R0
	x"05", -- Headphone volume - R2
	x"08", -- DAC Unmute, R4
	x"0A", -- DAC Stuff, R5
	x"0C", -- More DAC stuff, R6
	x"0E", -- Format, R7
	x"10", -- Normal Mode, R8
	x"12"  -- Reactivate, R9
);

constant SCI_DAT_ROM : rom_type := (
	"00000000", -- Deactivate - R9
	"00011111", -- ADC L/R Volume - R0 Old: "00011111"
	"11110101", -- Headphone volume - R2 Old: "11111001" "11110001"
	"11010000", -- Select DAC - R4
	"00000101", -- Turn off de-emphasis,  Off with HPF, unmute; DAC Old: "00010110" - R5
	"01100000", -- Device power on, ADC/DAC power on - R6
	"01000011", -- Master, 16-bits, DSP mode; Old: "00001011" - R7
	"00000000", -- Normal, 8kHz - R8 old : "00001100"
	"00000001"  -- Reactivate - R9
);
	
	signal LDATA, RDATA : std_logic_vector(15 downto 0); -- parallel external data inputs
	signal music_clk : std_logic;
	signal music_state : std_logic_vector(7 downto 0);
	signal key : std_logic_vector(3 downto 0);
	signal myRand : std_logic_vector(15 downto 0);
	
	constant SOL2 : std_logic_vector(15 downto 0):="1111100100100000";  --784Hz
	constant LA2 : std_logic_vector(15 downto 0) := "1101110111110010"; --880Hz
	constant SI2 : std_logic_vector(15 downto 0) := "1100010110110000"; --988Hz
	constant DO3 : std_logic_vector(15 downto 0) := "1011101010001100"; --1046Hz
	constant RE3 : std_logic_vector(15 downto 0) := "1010011000111010"; --1175Hz
	constant MI3 : std_logic_vector(15 downto 0) := "1001001011110110"; --1318Hz
	constant FA3 : std_logic_vector(15 downto 0) := "1000101111001110"; --1397Hz
	constant SOL3 : std_logic_vector(15 downto 0):= "0111110010010000"; --1568Hz
	constant LA3 : std_logic_vector(15 downto 0) := "0110111011111010"; --1760Hz
	constant SI3 : std_logic_vector(15 downto 0) := "0110001011011000"; --1976Hz
	constant CS3 : std_logic_vector(15 downto 0) := "1011000000011110"; --1109Hz
	constant FS3 : std_logic_vector(15 downto 0) := "1000001111111000"; --1480Hz
	
BEGIN

	reset <= not(reset_n);

	RNG : process(clk, reset)
	begin
		if (reset = '1') then
			myRand <= "0101010101010101";
		elsif (rising_edge(clk)) then
			myRand(0) <= myRand(10) xor myRand(12) xor myRand(13) xor myRand(15);
			myRand(15 downto 1) <= myRand(14 downto 0);
		end if;
	end process;
	
	SONG : process(music_state, attack)
	begin
		if (attack = '1') then key <= "1101";
--START
		elsif (music_state = "00000000") then key <= "1100";
		elsif (music_state = "00000001") then key <= "1100";
		elsif (music_state = "00000010") then key <= "1100";
		elsif (music_state = "00000011") then key <= "1100";
--1
		elsif (music_state = "00000100") then key <= "0100";
		elsif (music_state = "00000101") then key <= "0001";
		elsif (music_state = "00000110") then key <= "0100";
		elsif (music_state = "00000111") then key <= "1000";
--2		
		elsif (music_state = "00001000") then key <= "1000";
		elsif (music_state = "00001001") then key <= "0111";
		elsif (music_state = "00001010") then key <= "0111";
		elsif (music_state = "00001011") then key <= "1011";
--3		
		elsif (music_state = "00001100") then key <= "0101";
		elsif (music_state = "00001101") then key <= "1010";
		elsif (music_state = "00001110") then key <= "0010";
		elsif (music_state = "00001111") then key <= "0001";
--4		
		elsif (music_state = "00010000") then key <= "0000";
		elsif (music_state = "00010001") then key <= "0001";
		elsif (music_state = "00010010") then key <= "0001";
		elsif (music_state = "00010011") then key <= "0010";
--5		
		elsif (music_state = "00010100") then key <= "1010";
		elsif (music_state = "00010101") then key <= "0001";
		elsif (music_state = "00010110") then key <= "1010";
		elsif (music_state = "00010111") then key <= "1011";
--6		
		elsif (music_state = "00011000") then key <= "1011";
		elsif (music_state = "00011001") then key <= "0101";
		elsif (music_state = "00011010") then key <= "0101";
		elsif (music_state = "00011011") then key <= "1010";
--7		
		elsif (music_state = "00011100") then key <= "0100";
		elsif (music_state = "00011101") then key <= "0001";
		elsif (music_state = "00011110") then key <= "1011";
		elsif (music_state = "00011111") then key <= "0101";
--8
		elsif (music_state = "00100000") then key <= "0100";
		elsif (music_state = "00100001") then key <= "1010";
		elsif (music_state = "00100010") then key <= "0010";
		elsif (music_state = "00100011") then key <= "0001";
		
--9
		elsif (music_state = "00100100") then key <= "0100";
		elsif (music_state = "00100101") then key <= "0001";
		elsif (music_state = "00100110") then key <= "0100";
		elsif (music_state = "00100111") then key <= "1000";
--10		
		elsif (music_state = "00101000") then key <= "1000";
		elsif (music_state = "00101001") then key <= "0111";
		elsif (music_state = "00101010") then key <= "0111";
		elsif (music_state = "00101011") then key <= "1011";
--11
		elsif (music_state = "00101100") then key <= "0101";
		elsif (music_state = "00101101") then key <= "1010";
		elsif (music_state = "00101110") then key <= "0010";
		elsif (music_state = "00101111") then key <= "0001";
--12	
		elsif (music_state = "00110000") then key <= "0000";
		elsif (music_state = "00110001") then key <= "0001";
		elsif (music_state = "00110010") then key <= "0001";
		elsif (music_state = "00110011") then key <= "0010";
--13	
		elsif (music_state = "00110100") then key <= "1010";
		elsif (music_state = "00110101") then key <= "0001";
		elsif (music_state = "00110110") then key <= "1010";
		elsif (music_state = "00110111") then key <= "1011";
--14	
		elsif (music_state = "00111000") then key <= "1011";
		elsif (music_state = "00111001") then key <= "0101";
		elsif (music_state = "00111010") then key <= "0101";
		elsif (music_state = "00111011") then key <= "1010";
--15	
		elsif (music_state = "00111100") then key <= "0100";
		elsif (music_state = "00111101") then key <= "0001";
		elsif (music_state = "00111110") then key <= "0010";
		elsif (music_state = "00111111") then key <= "1010";
--16
		elsif (music_state = "01000000") then key <= "0100";
		elsif (music_state = "01000001") then key <= "0100";
		elsif (music_state = "01000010") then key <= "0100";
		elsif (music_state = "01000011") then key <= "0100";
--17
		elsif (music_state = "01000100") then key <= "1011";
		elsif (music_state = "01000101") then key <= "1011";
		elsif (music_state = "01000110") then key <= "1011";
		elsif (music_state = "01000111") then key <= "1011";
--18	
		elsif (music_state = "01001000") then key <= "1000";
		elsif (music_state = "01001001") then key <= "1000";
		elsif (music_state = "01001010") then key <= "1000";
		elsif (music_state = "01001011") then key <= "1000";
--19	
		elsif (music_state = "01001100") then key <= "0111";
		elsif (music_state = "01001101") then key <= "1000";
		elsif (music_state = "01001110") then key <= "0111";
		elsif (music_state = "01001111") then key <= "1011";
--20
		elsif (music_state = "01010000") then key <= "0101";
		elsif (music_state = "01010001") then key <= "0101";
		elsif (music_state = "01010010") then key <= "0101";
		elsif (music_state = "01010011") then key <= "0101";
--21		
		elsif (music_state = "01010100") then key <= "1010";
		elsif (music_state = "01010101") then key <= "1010";
		elsif (music_state = "01010110") then key <= "1010";
		elsif (music_state = "01010111") then key <= "1010";
--22
		elsif (music_state = "01011000") then key <= "0101";
		elsif (music_state = "01011001") then key <= "0101";
		elsif (music_state = "01011010") then key <= "0101";
		elsif (music_state = "01011011") then key <= "0101";
--23
		elsif (music_state = "01011100") then key <= "1011";
		elsif (music_state = "01011101") then key <= "0111";
		elsif (music_state = "01011110") then key <= "1011";
		elsif (music_state = "01011111") then key <= "0101";
--24
		elsif (music_state = "01100000") then key <= "0100";
		elsif (music_state = "01100001") then key <= "0100";
		elsif (music_state = "01100010") then key <= "0100";
		elsif (music_state = "01100011") then key <= "0100";
--25
		elsif (music_state = "01100100") then key <= "1011";
		elsif (music_state = "01100101") then key <= "1011";
		elsif (music_state = "01100110") then key <= "1011";
		elsif (music_state = "01100111") then key <= "1011";
--26
		elsif (music_state = "01101000") then key <= "1000";
		elsif (music_state = "01101001") then key <= "1000";
		elsif (music_state = "01101010") then key <= "1000";
		elsif (music_state = "01101011") then key <= "1000";
--27
		elsif (music_state = "01101100") then key <= "0111";
		elsif (music_state = "01101101") then key <= "1011";
		elsif (music_state = "01101110") then key <= "0111";
		elsif (music_state = "01101111") then key <= "1000";
--28
		elsif (music_state = "01110000") then key <= "1001";
		elsif (music_state = "01110001") then key <= "1001";
		elsif (music_state = "01110010") then key <= "1001";
		elsif (music_state = "01110011") then key <= "1001";
--29
		elsif (music_state = "01110100") then key <= "1000";
		elsif (music_state = "01110101") then key <= "1000";
		elsif (music_state = "01110110") then key <= "0111";
		elsif (music_state = "01110111") then key <= "1011";
--30
		elsif (music_state = "01111000") then key <= "0111";
		elsif (music_state = "01111001") then key <= "0111";
		elsif (music_state = "01111010") then key <= "0111";
		elsif (music_state = "01111011") then key <= "0111";
--31
		elsif (music_state = "01111100") then key <= "1011";
		elsif (music_state = "01111101") then key <= "0111";
		elsif (music_state = "01111110") then key <= "1011";
		elsif (music_state = "01111111") then key <= "0101";
--32
		elsif (music_state = "10000000") then key <= "0100";
		elsif (music_state = "10000001") then key <= "0100";
		elsif (music_state = "10000010") then key <= "0100";
		elsif (music_state = "10000011") then key <= "0100";
--end
		elsif (music_state = "10000100") then key <= "1100";
		elsif (music_state = "10000101") then key <= "1100";
		elsif (music_state = "10000110") then key <= "1100";
		elsif (music_state = "10000111") then key <= "1100"; 

		end if;
	end process;
	
	SONG_STATE : process(music_clk, reset)
	begin
		if(reset = '1') then
			music_state <= "00000000";
		elsif(rising_edge(music_clk)) then
			if (music_state >= "10000111") then
				music_state <= "00000000";
			else
				music_state <= music_state + 1;
			end if;
		end if;
	end process;
	
	CLOCK_DIVIDER : process(clk) -- period: 0.25s / clk: 50,000,000 Hz
		variable counter : std_logic_vector(23 downto 0);
	begin
		if(rising_edge(Clk)) then
			counter := counter + 1;
			if (counter > "101111101011110000100000") then
				counter := "000000000000000000000000";
			elsif (counter > "010111110101111000010000") 
				then music_clk <= '0';
			elsif (counter < "010111110101111000010000") 
				then music_clk <= '1';
			end if;
		end if;
	end process;
	
	OUTPUT_DATA : process(clk, key)
		variable counter : std_logic_vector(15 downto 0);
	begin
		if(rising_edge(Clk)) then
			counter := counter + 1;
			if (key = "0000") then
				if (counter > SOL2) then counter := "0000000000000000";
				elsif (counter > '0' & SOL2(15 downto 1)) then LDATA <= "0000100000000000"; RDATA <= "0000100000000000";
				elsif (counter < '0' & SOL2(15 downto 1)) then LDATA <= "0000000000000000"; RDATA <= "0000000000000000";
				end if;
			elsif (key = "0001") then
				if (counter > LA2) then counter := "0000000000000000";
				elsif (counter > '0' & LA2(15 downto 1)) then LDATA <= "0000100000000000"; RDATA <= "0000100000000000";
				elsif (counter < '0' & LA2(15 downto 1)) then LDATA <= "0000000000000000"; RDATA <= "0000000000000000";
				end if;
			elsif (key = "0010") then
				if (counter > SI2) then counter := "0000000000000000";
				elsif (counter > '0' & SI2(15 downto 1)) then LDATA <= "0000100000000000"; RDATA <= "0000100000000000";
				elsif (counter < '0' & SI2(15 downto 1)) then LDATA <= "0000000000000000"; RDATA <= "0000000000000000";
				end if;
			elsif (key = "0011") then
				if (counter > DO3) then counter := "0000000000000000";
				elsif (counter > '0' & DO3(15 downto 1)) then LDATA <= "0000100000000000"; RDATA <= "0000100000000000";
				elsif (counter < '0' & DO3(15 downto 1)) then LDATA <= "0000000000000000"; RDATA <= "0000000000000000";
				end if;
			elsif (key = "0100") then
				if (counter > RE3) then counter := "0000000000000000";
				elsif (counter > '0' & RE3(15 downto 1)) then LDATA <= "0000100000000000"; RDATA <= "0000100000000000";
				elsif (counter < '0' & RE3(15 downto 1)) then LDATA <= "0000000000000000"; RDATA <= "0000000000000000";
				end if;
			elsif (key = "0101") then
				if (counter > MI3) then counter := "0000000000000000";
				elsif (counter > '0' & MI3(15 downto 1)) then LDATA <= "0000100000000000"; RDATA <= "0000100000000000";
				elsif (counter < '0' & MI3(15 downto 1)) then LDATA <= "0000000000000000"; RDATA <= "0000000000000000";
				end if;
			elsif (key = "0110") then
				if (counter > FA3) then counter := "0000000000000000";
				elsif (counter > '0' & FA3(15 downto 1)) then LDATA <= "0000100000000000"; RDATA <= "0000100000000000";
				elsif (counter < '0' & FA3(15 downto 1)) then LDATA <= "0000000000000000"; RDATA <= "0000000000000000";
				end if;
			elsif (key = "0111") then
				if (counter > SOL3) then counter := "0000000000000000";
				elsif (counter > '0' & SOL3(15 downto 1)) then LDATA <= "0000100000000000"; RDATA <= "0000100000000000";
				elsif (counter < '0' & SOL3(15 downto 1)) then LDATA <= "0000000000000000"; RDATA <= "0000000000000000";
				end if;
			elsif (key = "1000") then
				if (counter > LA3) then counter := "0000000000000000";
				elsif (counter > '0' & LA3(15 downto 1)) then LDATA <= "0000100000000000"; RDATA <= "0000100000000000";
				elsif (counter < '0' & LA3(15 downto 1)) then LDATA <= "0000000000000000"; RDATA <= "0000000000000000";
				end if;
			elsif (key = "1001") then
				if (counter > SI3) then counter := "0000000000000000";
				elsif (counter > '0' & SI3(15 downto 1)) then LDATA <= "0000100000000000"; RDATA <= "0000100000000000";
				elsif (counter < '0' & SI3(15 downto 1)) then LDATA <= "0000000000000000"; RDATA <= "0000000000000000";
				end if;
			elsif (key = "1010") then
				if (counter > CS3) then counter := "0000000000000000";
				elsif (counter > '0' & CS3(15 downto 1)) then LDATA <= "0000100000000000"; RDATA <= "0000100000000000";
				elsif (counter < '0' & CS3(15 downto 1)) then LDATA <= "0000000000000000"; RDATA <= "0000000000000000";
				end if;
			elsif (key = "1011") then
				if (counter > FS3) then counter := "0000000000000000";
				elsif (counter > '0' & FS3(15 downto 1)) then LDATA <= "0000100000000000"; RDATA <= "0000100000000000";
				elsif (counter < '0' & FS3(15 downto 1)) then LDATA <= "0000000000000000"; RDATA <= "0000000000000000";
				end if;
			elsif (key = "1100") then -- no sound
				if (counter > DO3) then counter := "0000000000000000";
				elsif (counter > '0' & DO3(15 downto 1)) then LDATA <= "0000000000000000"; RDATA <= "0000000000000000";
				elsif (counter < '0' & DO3(15 downto 1)) then LDATA <= "0000000000000000"; RDATA <= "0000000000000000";
				end if;
			elsif (key = "1101") then -- attack
				--LDATA <= '0' & myRand(14 downto 0);
				--RDATA <= '0' & myRand(14 downto 0);
				LDATA <= '0' & counter(14 downto 0);
				RDATA <= '0' & counter(14 downto 0);
			end if;
		end if;
	end process;
	
	SCI_ADDR <= "00110100"; -- Device address
	
	-- Load new L/R channel data on the rising edge of DACLRCK.
	-- Decrease sample count
	DACData_reg : process(Clk, Reset, LDATA, RDATA, dack0, dack1, Bcount)
	begin
		if (Reset = '1') then
			LRDATA <= CONV_STD_LOGIC_VECTOR(0, 32);
			Bcount <= 31;
		elsif(rising_edge(Clk)) then
			if (dack0 = '1' and dack1 = '0') then -- Rising edge
				LRDATA <= LDATA & RDATA;
				Bcount <= 31;
			elsif (bck0 = '0' and bck1 = '1') then -- BCLK falling edge
					Bcount <= Bcount - 1;
			end if;
		end if;
	end process;
	
	-- Clock dividing counter
	I2C_Count : process(Clk, Reset)
	begin
		if (Reset = '1') then
			i2c_counter <= CONV_STD_LOGIC_VECTOR(0, 10);
		elsif (rising_edge(Clk)) then
			i2c_counter <= i2c_counter + '1';
		end if;
	end process;
	

	-- Sample SCLK
	SCLK_sample : process(Clk, Reset, SCLK_int)
	begin
		if (Reset = '1') then
			sck0 <= '0';
			sck1 <= '0';
		elsif(rising_edge(Clk)) then
			sck1 <= sck0;
			sck0 <= SCLK_int;
		end if;
	end process;
	
	-- Sample DALRCK
	DALRCK_sample : process(Clk, Reset, AUD_DACLRCK)
	begin
		if (Reset = '1') then
				dack0 <= '0';
				dack1 <= '0';
		elsif(rising_edge(Clk)) then
			dack1 <= dack0;
			dack0 <= AUD_DACLRCK;
		end if;
	end process;
	
	-- Sample BCLK
	BCLK_sample : process(Clk, Reset, AUD_BCLK)
	begin
		if (Reset = '1') then
			bck0 <= '0';
			bck1 <= '0';
		elsif(rising_edge(Clk)) then
			bck1 <= bck0;
			bck0 <= AUD_BCLK;
		end if;
	end process;
	
	-- Track number of actual transmitted configuration data frames.
	word_counter : process(SCLK_int, Count_EN, Reset, word_reset)
	begin
		if (Reset = '1' or word_reset = '1') then
			word_count <= 0;
		elsif(falling_edge(SCLK_int)) then
			if (Count_EN = '1') then
				word_count <= word_count + 1;
			else
				word_count <= word_count;
			end if;
		end if;
	end process;
	
	state_machine : process(Clk, Reset)
	begin
		if (Reset = '1') then
			state <= initialize;
		elsif(rising_edge(Clk)) then
			state <= next_state;
		end if;
	end process;
	
	-- Go through the I2C process, one step at a time. The state machine
	-- progresses through states on the falling edge of SCLK.
	next_state_i2c : process(Clk, state, SCLK_int, sck0, sck1, word_count)
	begin
		word_reset <= '0';
		case state is
			when initialize =>
				if (SCLK_INT = '1') then
					next_state <= start;
				else
					next_state <= initialize;
				end if;
			when start =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= b0; -- Start condition
				else
					next_state <= start;
				end if;
			when b0 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= b1;
				else
					next_state <= b0;
				end if;
			when b1 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= b2;
				else
					next_state <= b1;
				end if;
			when b2 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= b3;
				else
					next_state <= b2;
				end if;
			when b3 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= b4;
				else
					next_state <= b3;
				end if;
			when b4 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= b5;
				else
					next_state <= b4;
				end if;
			when b5 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= b6;
				else
					next_state <= b5;
				end if;
			when b6 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= b7;
				else
					next_state <= b6;
				end if;
			when b7 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= b_ack;
				else
					next_state <= b7;
				end if;
			when b_ack =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= a0; -- First ack.
				else
					next_state <= b_ack;
				end if;
			when a0 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= a1;
				else
					next_state <= a0;
				end if;
			when a1 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= a2;
				else
					next_state <= a1;
				end if;
			when a2 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= a3;
				else
					next_state <= a2;
				end if;
			when a3 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= a4;
				else
					next_state <= a3;
				end if;
			when a4 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= a5;
				else
					next_state <= a4;
				end if;
			when a5 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= a6;
				else
					next_state <= a5;
				end if;
			when a6 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= a7;
				else
					next_state <= a6;
				end if;
			when a7 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= a_ack;
				else
					next_state <= a7;
				end if;
			when a_ack =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= d0; -- Second ack
				else
					next_state <= a_ack;
				end if;
			when d0 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= d1;
				else
					next_state <= d0;
				end if;
			when d1 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= d2;
				else
					next_state <= d1;
				end if;
			when d2 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= d3;
				else
					next_state <= d2;
				end if;
			when d3 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= d4;
				else
					next_state <= d3;
				end if;
			when d4 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= d5;
				else
					next_state <= d4;
				end if;
			when d5 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= d6;
				else
					next_state <= d5;
				end if;
			when d6 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= d7;
				else
					next_state <= d6;
				end if;
			when d7 =>
				if (sck0 = '0' and sck1 = '1') then
					next_state <= d_ack; -- Last ack
				else
					next_state <= d7;
				end if;
			when d_ack =>
				-- Check to see if we've transmitted the correct number
				-- of words. If so, done. If not, transmit more.
				if (sck0 = '0' and sck1 = '1') then
					if (word_count = word_limit+1) then
						next_state <= b_stop0;
					else
						next_state <= initialize;
					end if;
				else
					next_state <= d_ack;
				end if;
			when b_stop0 =>
				-- If we're done, generate a stop condition
				if (SCLK_INT = '1') then
					next_state <= b_stop1;
				else
					next_state <= b_stop0;
				end if;
			when b_stop1 =>
				next_state <= b_end;
			when b_end =>
				next_state <= b_end;
				word_reset <= '1';
		end case;
	end process;
	
	outputs_i2c : process(state, SCI_ADDR, word_count)
	begin
		count_en <= '0';
		sclk_inhibit <= '0';
		case state is
			when initialize =>
				I2C_SDAT <= '1'; -- SDAT starts high
			when start =>
				I2C_SDAT <= '0'; -- SDAT falling edge
			when b0 =>
				I2C_SDAT <= SCI_ADDR(7);
			when b1 =>
				I2C_SDAT <= SCI_ADDR(6);
			when b2 =>
				I2C_SDAT <= SCI_ADDR(5);
			when b3 =>
				I2C_SDAT <= SCI_ADDR(4);
			when b4 =>
				I2C_SDAT <= SCI_ADDR(3);
			when b5 =>
				I2C_SDAT <= SCI_ADDR(2);
			when b6 =>
				I2C_SDAT <= SCI_ADDR(1);
			when b7 =>
				I2C_SDAT <= SCI_ADDR(0);
			when b_ack =>
				I2C_SDAT <= 'Z';
			when a0 =>
				I2C_SDAT <= SCI_REG_ROM(word_count)(7);
			when a1 =>
				I2C_SDAT <= SCI_REG_ROM(word_count)(6);
			when a2 =>
				I2C_SDAT <= SCI_REG_ROM(word_count)(5);
			when a3 =>
				I2C_SDAT <= SCI_REG_ROM(word_count)(4);
			when a4 =>
				I2C_SDAT <= SCI_REG_ROM(word_count)(3);
			when a5 =>
				I2C_SDAT <= SCI_REG_ROM(word_count)(2);
			when a6 =>
				I2C_SDAT <= SCI_REG_ROM(word_count)(1);
			when a7 =>
				I2C_SDAT <= SCI_REG_ROM(word_count)(0);
			when a_ack =>
				I2C_SDAT <= 'Z';
			when d0 =>
				I2C_SDAT <= SCI_DAT_ROM(word_count)(7);
			when d1 =>
				I2C_SDAT <= SCI_DAT_ROM(word_count)(6);
			when d2 =>
				I2C_SDAT <= SCI_DAT_ROM(word_count)(5);
			when d3 =>
				I2C_SDAT <= SCI_DAT_ROM(word_count)(4);
			when d4 =>
				I2C_SDAT <= SCI_DAT_ROM(word_count)(3);
			when d5 =>
				I2C_SDAT <= SCI_DAT_ROM(word_count)(2);
			when d6 =>
				I2C_SDAT <= SCI_DAT_ROM(word_count)(1);
			when d7 =>
				I2C_SDAT <= SCI_DAT_ROM(word_count)(0);
			when d_ack =>
				I2C_SDAT <= 'Z';
				count_en <= '1';
			when b_stop0 =>
				-- Keep SDAT at low until SCLK goes high
				I2C_SDAT <= '0';
			when b_stop1 =>
				-- SCLK is high, so SDAT has a rising edge
				I2C_SDAT <= '1';
				sclk_inhibit <= '1';
			when b_end =>
				I2C_SDAT <= '1';
				sclk_inhibit <= '1';
		end case;
	end process;

	SCLK_int <= I2C_counter(9) or SCLK_inhibit; -- SCLK = CLK / 512 = 97.65 kHz ~= 100 kHz
	--SCLK_int <= I2C_counter(3) or SCLK_inhibit; -- For simulation only
	AUD_MCLK <= I2C_counter(2); -- MCLK = CLK / 4
	I2C_SCLK <= SCLK_int;

	AUD_DACDAT <= LRDATA(Bcount);
end Behavorial; 
