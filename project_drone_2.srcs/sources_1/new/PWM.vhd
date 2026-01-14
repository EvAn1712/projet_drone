library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================
-- PWM IP
-- Inputs:
--   - clk   : 50 MHz system clock (Basys3)
--   - reset : asynchronous active-high reset
-- Outputs:
--   - pwm_fst : PWM signal for fast speed  (95% duty cycle)
--   - pwm_std : PWM signal for standard    (50% duty cycle)
--   - pwm_slw : PWM signal for slow speed  (15% duty cycle)
--
-- Principle:
--  1) Create a 200 us "tick" by dividing the 50 MHz clock:
--       200 us / 20 ns = 10,000 clock cycles
--  2) Use this tick to increment a PWM counter (pwmcnt) from 0 to 99.
--     => Period = 100 * 200 us = 20 ms => 50 Hz PWM frequency.
--  3) Generate each PWM output by comparing pwmcnt to a threshold:
--       pwm_fst = 1 when pwmcnt < 95  => 95% duty
--       pwm_std = 1 when pwmcnt < 50  => 50% duty
--       pwm_slw = 1 when pwmcnt < 15  => 15% duty
-- ============================================================

entity PWM is
  Port ( 
    clk : in std_logic;
    reset : in std_logic;
    pwm_fst : out std_logic;
    pwm_std : out std_logic;
    pwm_slw : out std_logic
  );
end PWM;

architecture Behavioral of PWM is

    -- Number of 50 MHz clock cycles corresponding to 200 us:
    -- 50 MHz => 20 ns period, so 200 us / 20 ns = 10,000 cycles.
    constant TICKS_200US : integer := 10000;

    -- Counter for clock division (counts 0..9999).
    -- 14 bits are enough because 2^14 = 16384 > 10000.
    signal tick_cnt : unsigned (13 downto 0) := (others => '0');

    -- 'tick' is a one-clock pulse asserted every 200 us.
    signal tick : std_logic := '0';

    -- PWM counter incremented on each tick:
    -- counts 0..99 => 100 steps => 20 ms PWM period.
    -- 7 bits are enough because 2^7 = 128 > 99.
    signal pwmcnt : unsigned (6 downto 0) := (others => '0');

begin

    -- ------------------------------------------------------------
    -- Tick generator: divides the 50 MHz clock to create a 200 us pulse.
    -- tick = '1' for one clock cycle every time tick_cnt reaches 9999.
    -- ------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            tick_cnt <= (others => '0');
            tick <= '0';
        elsif rising_edge(clk) then
            if tick_cnt = TICKS_200US - 1 then
                tick_cnt <= (others => '0');
                tick <= '1';
            else
                tick_cnt <= tick_cnt + 1;
                tick <= '0';
            end if;
        end if;
    end process;

    -- ------------------------------------------------------------
    -- PWM counter: increments only when tick='1'.
    -- When reaching 99, it wraps back to 0 to restart the PWM period.
    -- ------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            pwmcnt <= (others => '0');
        elsif rising_edge(clk) then
            if tick = '1' then
                if pwmcnt = 99 then
                    pwmcnt <= (others => '0');
                else
                    pwmcnt <= pwmcnt + 1;
                end if;
            end if;
        end if;
    end process;

    -- ------------------------------------------------------------
    -- PWM outputs: comparison between pwmcnt and duty thresholds.
    -- The output is high for N counts out of 100 (0..99).
    -- ------------------------------------------------------------
    pwm_fst <= '1' when pwmcnt < 95 else '0';  -- 95% duty cycle
    pwm_std <= '1' when pwmcnt < 50 else '0';  -- 50% duty cycle
    pwm_slw <= '1' when pwmcnt < 15 else '0';  -- 15% duty cycle

end Behavioral;
