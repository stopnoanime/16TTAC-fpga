#!/usr/bin/env python3

def write_to_mif(file_name, depth, values):
    with open(file_name, 'w') as mif_file:
        mif_file.write(f"DEPTH = {depth};\n")
        mif_file.write(f"WIDTH = 16;\n")
        mif_file.write(f"ADDRESS_RADIX = HEX;\n")
        mif_file.write(f"DATA_RADIX = HEX;\n")
        mif_file.write(f"CONTENT BEGIN\n")

        for i, hex_value in enumerate(values):
            mif_file.write(f"{i:04X} : {hex_value.upper()};\n")

        if len(values) < depth:
            mif_file.write(f"[{len(values):04X}..{depth-1:04X}] : 0000;\n")

        # Write the MIF file footer
        mif_file.write("END;\n")


def hex_to_mif(input_file, output_file_1, output_file_2):
    depth = 32768

    # Read the .hex file
    with open(input_file, 'r') as hex_file:
        hex_lines = [line.strip() for line in hex_file.readlines()]

    write_to_mif(output_file_1, depth, hex_lines[:depth])
    write_to_mif(output_file_2, depth, hex_lines[depth:])


hex_to_mif('ram-init.hex', 'low-init.mif', 'high-init.mif')