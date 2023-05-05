# Mini Platformer

Carlos Montemayor
18-224/624 Spring 2023 Final Tapeout Project

## Overview

My project is a small game written in systemverilog meant to interface with a 4x16 Character LCD. It would start on reset,
with the player and platform starting in a predefined position, and randomly
choose to move the platform every fraction of a second, causing the player to need to "jump" to avoid the platform.
The game ends when the player hits the edge of a platform, and the game will need to be reset.

## How it Works

The game works by emitting a series of instructions as a startup procedure on reset, which include setting up 
the display controller that the game displays on, and drawing the initial state with the player position and 
the initial platform. The game then enters a loop of logging whether the user jumps, undrawing the leftmost section
of the platform, undrawing the player, shifting every line over by 1, determining the new player position
based on any logged jump presses, determining the new platform position, then drawing the new player and platform in
their determined positions. The game then waits for the rest of the fraction of a second until resuming this loop.

## Inputs/Outputs

There is only one input, not counting the reset line, which is the jump input. This input determines
whether the player jumps on any particular iteration of the game.
The outputs are directly the data outputs for the particular display controller I chose,
where one output represent the Register Select bit on the display, selecting whether to address memory or send commands,
then the next output is for the Read/Write bit, which determines whether or not you are reading from memory
or writing to memory, then there are 8 bus bits that serve either as a data or address bus, depending on the 
command you've specified with the first two bits, and then an enable bit that lets the display know when a valid input
is coming on its inputs.

The target clock frequency is 500khz, but it can go any slower than that, just not faster.

## Hardware Peripherals

There are a few hardware peripherals required. Firstly, two buttons, one for reset and one for jumping. Next one needs a 10kOhm resistor, a 10KOhm Potentiometer, a 5V power source and a grounded sink, as well as a NHD-0416BZ-FL-YBW 16x4 Character LCD to 
display the game on.

## Design Testing / Bringup

This project is tested by hooking it up to the display using the appropriate pins and hitting the reset button.

