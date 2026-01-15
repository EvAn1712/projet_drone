--------------------------------------------------------------------
-- SevenSegment_tb
--
-- Goal:
--   - Instantiate the SevenSegmentDisplay IP (UUT)
--   - Generate a clock
--   - Release reset
--   - Apply several (mode_left, mode_right) combinations
--   - Observe anode multiplexing (an) and segment patterns (seg)
--
-- Checks in waveform:
--   1) 'an' cycles through "1110","1101","1011","0111" (one digit active at a time)
--   2) 'seg' changes accordingly to display 0/1/2/3 depending on the selected digit
--   3) Changing mode inputs updates the displayed digits on the next refresh cycles
--------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SevenSegment_tb is
end SevenSegment_tb;

architecture sim of SevenSegment_tb is
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal mode_right : std_logic_vector(1 downto 0) := "00";
    signal mode_left : std_logic_vector(1 downto 0) := "00";
    signal seg : std_logic_vector(6 downto 0);
    signal an : std_logic_vector(3 downto 0);
       
    -- 50 MHz clock period (20 ns)
    constant clk_period : time := 20 ns;
    
begin

    -- UUT instantiation
    UUT : entity work.SevenSegmentDisplay
        port map(
            clk => clk,
            reset => reset,
            mode_right => mode_right,
            mode_left => mode_left,
            seg => seg,
            an => an
        );
        
    -- Clock generator
    clk_proc :process
    begin
        while now < 100 ms loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;       

    -- Stimulus process:
    -- Each test is held for 4 ms, which corresponds to one full refresh cycle
    -- (4 digits * 1 ms per digit with REFRESH_COUNT=50000 at 50 MHz).
    stim_proc: process
    begin
        -- Reset phase
        wait for 100 ns;
        reset <= '0';

        -- Test 1 : Stop/Stop  -> 0 / 0
        mode_left  <= "00";
        mode_right <= "00";
        wait for 4 ms;

        -- Test 2 : Slow/Slow  -> 1 / 1
        mode_left  <= "01";
        mode_right <= "01";
        wait for 4 ms;

        -- Test 3 : Std/Std    -> 2 / 2
        mode_left  <= "10";
        mode_right <= "10";
        wait for 4 ms;

        -- Test 4 : Fast/Fast  -> 3 / 3
        mode_left  <= "11";
        mode_right <= "11";
        wait for 4 ms;

        -- Test 5 : Slow/Fast (turn Left)  -> 1 / 3
        mode_left  <= "01";
        mode_right <= "11";
        wait for 4 ms;

        -- Test 6 : Fast/Slow (turn Right) -> 3 / 1
        mode_left  <= "11";
        mode_right <= "01";
        wait for 4 ms;

    end process;
      
end sim;
