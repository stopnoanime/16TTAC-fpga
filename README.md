# 16TTAC-fpga
16TTAC-fpga is a VHDL implementation of the 16TTAC CPU.
You can learn more about the 16TTAC [here](https://github.com/stopnoanime/16TTAC-sim).

## Writing code for this CPU
You can use [16TTAC-web](https://github.com/stopnoanime/16TTAC-web) to write assembley code that can be used with this CPU.
After compiling your code, you should download the generated `ram-init.hex` file, and move it to the repo root folder.

## Simulating
You need have make, GHDL and GTKWave installed. Then you can just run:
```
make TESTBENCH=top
```
to simulate this CPU. `ram-init.hex` will be used to initialize the memory.

## Synthesizing
This project is made to run on the [Tang Primer](https://tang.sipeed.com/en/hardware-overview/lichee-tang/) board.
The repo includes the necessary TD IDE project file. You can adjust the pin mapping in the `project.adc` file.

To initialize the memory, you need to convert the `ram-init.hex` file to two `.mif` files.
You can use the included python3 script `hex_to_mif.py` to do so, just run `make ram-init`

