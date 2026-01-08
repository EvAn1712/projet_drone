----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/04/2025 03:58:49 PM
-- Design Name: 
-- Module Name: BPStartStop - Behavioral
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
use ieee.numeric_std.all;

entity BPStartStop is
    Port ( 
        clk : in std_logic;
        reset : in std_logic;
        button : in std_logic;
        move : out std_logic
    );
end BPStartStop;

architecture Behavioral of BPStartStop is
    signal bp_prev : std_logic := '0';
    signal state : std_logic :='0';
begin

process(clk, reset)
    begin
    if reset = '1' then
        state <= '0';
        bp_prev <= '0';
        
    elsif rising_edge(clk) then

        if (button = '1' and bp_prev = '0') then
            state <= not state;
        end if;

        bp_prev <= button;
    end if;
end process;

move <= state;
end Behavioral;

