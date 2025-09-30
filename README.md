Instructions – Interactive Visual Work

All rights reserved © Yosef Mashiah. Developed in collaboration with ChatGPT.

1. Screen Layout

The screen is divided into squares of cellSize (default 90 pixels).

Shapes are drawn across the entire screen, in horizontal and vertical layers.

Available shapes:

3 white lines

Blue triangle

Red X

Yellow circle

Green triangle (always visible)

2. MIDI Interaction – Speed Control

MIDI Channel: 0

CC (Control Change) numbers:

CC	Shape	Function
70	3 white lines	Adjusts movement speed
71	Blue triangle	Adjusts movement speed
72	Yellow circle	Adjusts movement speed
73	Red X	Adjusts movement speed
76	Green triangle	Adjusts movement speed
77	Green triangle	Adjusts size (Scale)

MIDI value range: 0–127

Mapping: Low values = slower, high values = faster

3. MIDI Interaction – Size Control

Shape 5 (Green triangle): CC77 changes size from 1x to 4x

Shapes 1–4: Note On

Velocity < 30 → Scale = 1 (default size)

Velocity 30–127 → Scale mapped linearly (1–4x)

4. Activating/Showing Shapes

Shapes 1–4 appear on Note Off events:

Note (Pitch)	Shape Activated
36	Red X
37	Blue triangle
38	Yellow circle
39	3 white lines

Shape 5 (Green triangle) is always visible.

5. Movement Layers

Horizontal Layer: Shapes move left or right according to xDirections.

Vertical Layer: Shapes move up or down according to yDirections.

Movement speed is controlled by the corresponding MIDI input.

6. Shape Description

3 white lines: Three vertical lines across the cell width

Blue triangle: Simple triangle

Red X: Two crossing lines

Yellow circle: Simple ellipse

Green triangle: Triangle (size and rotation adjustable)

7. Usage Tips

Multiple shapes can be activated at once with different speeds.

Start with basic shapes to explore the interaction between movement layers.

Notes:

Inactive shapes are not visible on the screen.

Shape 5 is always visible regardless of MIDI control.

All rights reserved © Yosef Mashiah. Developed in collaboration with ChatGPT.