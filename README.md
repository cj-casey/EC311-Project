## EC311-Project
### By Team Combinational Magic, Aymeric Blaizot, Thomas Young, Tom Barrete, Connor Casey
# Tilt
A maze solving game using tilt controls. The user will have to navigate an ever changing maze and reach the flag to increase score in the alloted time.

## Features

### Accelerometer Motion Controls (Connor)
  We plan to use the ADXL362 accelerometer on board the FPGA to control motion of the ball. This will require both an SPI Master and SPI Interface, but also a denoiser and decoder for the accelerometer.

### Random Maze Generation (Thomas Y.)
  We plan to use generate random mazes for the user to solve.

### Collision Detection (Tom B.)
  We want the user to avoid colliding with the walls or going through them, so will use collision checking

### Random Maze Generation and Display (Aymeric)
  The vertical and horiztonal lines of the maze are modulated by two differently clocked linear-feedback shift registers (LFSR) and sampled every second to change the maze every second. The generation of the lines 

### Timer and Score counter (Aymeric)
The player has set number of seconds to reach the flag that depends on the number lines of the maze.

### Hard Mode (Aymeric)
A switch on the Nexys board makes collision with any wall reset to the begining of the maze.

### How to Run
Add all files in either Final_with_multiple_modes of the Final folder as design sources. Add the Nexys4DDR_Master_lines.xdc as a constraints file. Run synthesis, implemementation, and generate bitstream. Connect Nexys 4 to VGA. 

