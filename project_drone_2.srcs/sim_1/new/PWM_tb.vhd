----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/04/2025 04:05:56 PM
-- Design Name: 
-- Module Name: BPStartStop_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use IEEE.STD_LOGIC_1164.ALL;

entity PWM_tb is
end PWM_tb;

architecture sim of PWM_tb is

    signal clk     : std_logic := '0';
    signal reset   : std_logic := '1';
    signal pwm_fst : std_logic;
    signal pwm_std : std_logic;
    signal pwm_slw : std_logic;

    constant clk_period : time := 20 ns;

begin

    uut: entity work.PWM
        port map (
            clk => clk,
            reset => reset,
            pwm_fst => pwm_fst,
            pwm_std => pwm_std,
            pwm_slw => pwm_slw
        );

    clk_proc :process
    begin
        while now < 100 ms loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    stim_proc: process
    begin
        wait for 100 ns;
        reset <= '0';

        wait for 100 ms;

        report "PWM First Speed: " & std_logic'image(pwm_fst);
        report "PWM Standard Speed: " & std_logic'image(pwm_std);
        report "PWM Slow Speed: " & std_logic'image(pwm_slw);

        wait;
    end process;

end sim;