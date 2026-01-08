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
use ieee.std_logic_1164.all;
entity BPStartStop_tb is
end BPStartStop_tb;

architecture test of BPStartStop_tb is
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal button : std_logic := '0';
    signal move : std_logic;
begin
    UUT: entity work.BPStartStop
        port map (
            clk => clk,
            reset => reset,
            button => button,
            move => move
        );

clk <= not clk after 10 ns;
process
begin
    -- Reset initiale
    reset <= '1';
    wait for 50 ns;
    reset <= '0';

    -- Appui bouton
    wait for 200 ns;
    button <= '1';
    wait for 100 ns;
    button <= '0';

    -- Deuxieme Appui
    wait for 300 ns;
    button <= '1';
    wait for 100 ns;
    button <= '0';

    wait;
end process;
end test;


