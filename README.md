# 16TTAC-fpga
16TTAC-fpga is a VHDL implementation of the 16TTAC CPU.
You can learn more about the 16TTAC [here](https://github.com/stopnoanime/16TTAC-sim).

## Simulating
If you have GHDL and GTKWave installed you can run:
```
make TESTBENCH=top
```
to simulate this CPU. `ram-init.hex` will be used to initialize the memory.

## Writing code for this CPU
You can use [16TTAC-web](https://github.com/stopnoanime/16TTAC-web) to write assembley code that can be used with this CPU.
After compiling your code, you can download the generated `.hex` file, and replace `ram-init.hex` with its contents.
