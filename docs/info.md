<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## What is it?

This project is designed to allow various tests of Tiny Tapeout timing, using the High Speed cell library.

It includes two 16-bit shift registers and a 16x16 multiplier.

## How it works

### Input

On clock:

- In 0 shifts into shift register A
- In 1 shifts into shift register B

### Latch

There are two 16-bit latches that are loaded from shift register.  These are the inputs to the multiplier.

Inputs 2-4 control the latch:

- In 4 selects whether in 2 or in 3 controls the latch gate
- If in 4 is low, the latch gate is controlled by in 2
- If in 4 is high, the latch gate is controlled by in 3, inverted.

This setup may allow the difference between a short positive pulse and a short negative pulse through the TT mux to be explored.

### Multiplier

The latched inputs are multiplied to give a 32-bit result

### Ouputs

The bidir outputs and regular outputs form a 16-bit output, however in 7 controls the output enable for the bidir outputs (active high).

Various outputs can be selected:

- If rst_n is low, both the bidir and regular outputs are set to the inputs.
- If in 5 is high, the outputs are set to the latched multiplier inputs, with the input selected by in 6.
- If in 5 is low, the outputs are set to the multiplication result, with the top half selected when in 6 is high.

## How to test

Clock in inputs, set the latch, see the results.

Explore the timing using the other inputs.

## External hardware

None required
