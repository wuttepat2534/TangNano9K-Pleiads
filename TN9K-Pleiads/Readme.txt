Pleiads Arcade for the Tang Nano 9K FPGA Dev Board.

Notes:
Controls are PS2 keyboard, F3=Coin F1=P1Start F2=P2Start LeftArrow=Move Left RightArrow=Move Right SpaceBar=Fire DownArrow=Shield
Consult the Schematics Folder for Information regarding peripheral connections.

Build:
* Obtain correct roms file for pleiads, see make pleiads proms script in tools folder for rom filenames.
* Unzip rom files to tools folder.
* Run the make pleiads proms script in the tools folder.
* Place the generated prom files inside the proms folder.
* Open the TN9K-Pleiads project file using GoWin and compile.
* Program Tang Nano 9K Board.
