---------------------------------------------------------------------
-- BPStartStop
--
-- Goal:
--   Implement a start/stop toggle controlled by one push button.
--
-- Inputs:
--   - clk    : system clock (50 MHz on Basys3, but any clock works)
--   - reset  : asynchronous active-high reset
--   - button : push button signal (1 when pressed, 0 otherwise)
--
-- Output:
--   - move   : state of the drone
--             move = 1 => drone moving
--             move = 0 => drone stopped
--
-- Principle:
--   - Detect a rising edge on 'button' using a previous sampled value (bp_prev).
--   - On each rising edge, toggle the internal state 'state'.
--   - Asynchronous reset forces state to '0' (stopped).
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BPStartStop is
    Port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        button : in  std_logic;
        move   : out std_logic
    );
end BPStartStop;

architecture Behavioral of BPStartStop is

    -- bp_prev stores the button value from the previous clock cycle.
    -- It is used to detect a rising edge (0 -> 1 transition).
    signal bp_prev : std_logic := '0';

    -- state is the internal "move" state:
    --  '0' = stopped, '1' = moving
    signal state : std_logic := '0';

begin

    -- ------------------------------------------------------------
    -- Main sequential process:
    -- - Asynchronous reset: immediate stop regardless of clk
    -- - On rising clock edge:
    --     if button rises from 0 to 1 => toggle 'state'
    --     update bp_prev <= current button
    -- ------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            -- Safe state: drone stopped
            state   <= '0';
            bp_prev <= '0';

        elsif rising_edge(clk) then

            -- Rising edge detection:
            -- button='1' and bp_prev='0' means a new press event
            if (button = '1' and bp_prev = '0') then
                -- Toggle start/stop state
                state <= not state;
            end if;

            -- Memorize current button value for next cycle
            bp_prev <= button;
        end if;
    end process;

    -- Output mapping: move follows the internal state
    move <= state;

end Behavioral;
