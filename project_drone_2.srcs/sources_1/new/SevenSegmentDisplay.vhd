--------------------------------------------------------------------
-- Description: 7-segment display controller for Basys3 board
--              Displays wheel modes on 4 digits
--
-- Inputs:
--   clk        : board clock
--   reset      : asynchronous active-high reset
--   mode_left  : 2-bit speed mode for left motor
--   mode_right : 2-bit speed mode for right motor
--
-- Outputs (Basys3 7-seg interface):
--   seg : 7 cathodes (active LOW) for segments a..g
--   an  : 4 anodes   (active LOW) to select one digit among 4
--
-- Multiplexing principle:
--   Only one digit is activated at a time (an = "1110", "1101", "1011", "0111").
--   The currently selected digit value is converted to a 7-seg pattern on seg.
--
-- Display mapping:
--   mode "00" -> display "0"
--   mode "01" -> display "1"
--   mode "10" -> display "2"
--   mode "11" -> display "3"
-- Tens digits are forced to "0" (so we effectively show 0..3 on each motor).
--------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SevenSegmentDisplay is
    Port (
        clk : in std_logic;
        reset : in std_logic;
        mode_right : in std_logic_vector(1 downto 0);
        mode_left : in std_logic_vector(1 downto 0);
        seg : out std_logic_vector(6 downto 0);
        an : out std_logic_vector(3 downto 0)
    );
end SevenSegmentDisplay;

architecture Behavioral of SevenSegmentDisplay is
    -- Refresh counter for multiplexing.
    -- With REFRESH_COUNT = 50000:
    --   if clk = 50 MHz => 50000 cycles = 1 ms per digit -> full cycle = 4 ms
    -- (This matches the typical 4 ms refresh used in the project.)
    constant REFRESH_COUNT : integer := 50000; -- 25000;
    signal refresh_counter : unsigned(15 downto 0) := (others => '0');

    -- digit_select selects which of the 4 digits is currently active (0..3).
    signal digit_select : unsigned(1 downto 0) := (others => '0');
    
    -- BCD digits to display (4-bit each).
    -- digit0/digit1 correspond to left wheel (ones/tens)
    -- digit2/digit3 correspond to right wheel (ones/tens)
    signal digit0 : std_logic_vector(3 downto 0);  -- Right digit of left wheel
    signal digit1 : std_logic_vector(3 downto 0);  -- Left digit of left wheel
    signal digit2 : std_logic_vector(3 downto 0);  -- Right digit of right wheel
    signal digit3 : std_logic_vector(3 downto 0);  -- Left digit of right wheel
    
    -- current_digit is the BCD value routed to the converter for the active digit.
    signal current_digit : std_logic_vector(3 downto 0);
    
    -- Function to convert BCD to 7-segment (active low).
    -- Returned vector is seg(6 downto 0) where '0' lights a segment.
    function bcd_to_7seg(bcd : std_logic_vector(3 downto 0)) return std_logic_vector is
        variable seg_out : std_logic_vector(6 downto 0);
    begin
        case bcd is
            when "0000" => seg_out := "1000000"; -- 0
            when "0001" => seg_out := "1111001"; -- 1
            when "0010" => seg_out := "0100100"; -- 2
            when "0011" => seg_out := "0110000"; -- 3
            when "0100" => seg_out := "0011001"; -- 4
            when "0101" => seg_out := "0010010"; -- 5
            when "0110" => seg_out := "0000010"; -- 6
            when "0111" => seg_out := "1111000"; -- 7
            when "1000" => seg_out := "0000000"; -- 8
            when "1001" => seg_out := "0010000"; -- 9
            when others => seg_out := "1111111"; -- blank
        end case;
        return seg_out;
    end function;
    
begin

    -- Convert each motor "mode" (2 bits) to a displayed digit
    --  We display:
    --      0 for stop, 1 for slow, 2 for standard, 3 for fast
    --    Tens digits are kept at 0.

    digit0 <= "0001" when mode_left = "01" else
              "0010" when mode_left = "10" else
              "0011" when mode_left = "11" else
              "0000";  -- Default: display 0
    digit1 <= "0000";  -- Always 0 for tens digit
    
    digit2 <= "0001" when mode_right = "01" else
              "0010" when mode_right = "10" else
              "0011" when mode_right = "11" else
              "0000";  -- Default: display 0
    digit3 <= "0000";  -- Always 0 for tens digit
    
    -- Refresh counter: advances digit_select periodically
    -- This implements time-multiplexing of the 4 digits.

    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset: restart refresh timing and select digit 0
            refresh_counter <= (others => '0');
            digit_select <= (others => '0');
        elsif rising_edge(clk) then
            if refresh_counter = REFRESH_COUNT - 1 then
                refresh_counter <= (others => '0');
                digit_select <= digit_select + 1; -- cycles 00->01->10->11
            else
                refresh_counter <= refresh_counter + 1;
            end if;
        end if;
    end process;
    
    -- Select which digit is active by driving anodes (active LOW),
    -- and route the corresponding digit value to current_digit.

    process(digit_select, digit0, digit1, digit2, digit3)
    begin
        case digit_select is
            when "00" =>
                an <= "1110";  -- Activate digit 0 (rightmost)
                current_digit <= digit0;
            when "01" =>
                an <= "1101";  -- Activate digit 1
                current_digit <= digit1;
            when "10" =>
                an <= "1011";  -- Activate digit 2
                current_digit <= digit2;
            when "11" =>
                an <= "0111";  -- Activate digit 3 (leftmost)
                current_digit <= digit3;
            when others =>
                an <= "1111";  -- None selected (safe)
                current_digit <= "1111";
        end case;
    end process;
    
    -- Segment output:
    -- Convert the currently selected BCD digit to the 7-seg pattern.
    
    seg <= bcd_to_7seg(current_digit);
    
end Behavioral;
