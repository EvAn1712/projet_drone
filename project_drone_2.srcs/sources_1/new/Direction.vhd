----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/17/2025 10:00:50 AM
-- Design Name: 
-- Module Name: Direction - Behavioral
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Direction is
    Port (
        clk : in std_logic;
        reset : in std_logic;

        refPwmFst : in std_logic;
        refPwmStd : in std_logic;
        refPwmSlw : in std_logic;

        sensorLeft : in std_logic;
        sensorRight : in std_logic;

        state_move : in std_logic;

        motorLeft : out std_logic;
        motorRight : out std_logic
    );
end Direction;

architecture Behavioral of Direction is
begin
    process(sensorLeft, sensorRight, state_move, refPwmFst, refPwmStd, refPwmSlw)
    begin
        if state_move = '0' then 
            motorLeft <= '0';
            motorRight <= '0';
        else
            if sensorLeft = '0' and sensorRight = '0' then
                motorLeft <= refPwmFst;
                motorRight <= refPwmFst;

            elsif sensorLeft = '1' and sensorRight = '0' then
                motorLeft <= refPwmSlw;
                motorRight <= refPwmFst;

            elsif sensorLeft = '0' and sensorRight = '1' then
                motorLeft <= refPwmFst;
                motorRight <= refPwmSlw;

            else
                motorLeft <= refPwmStd;
                motorRight <= refPwmStd;
            end if;
        end if;
    end process;
end Behavioral;
