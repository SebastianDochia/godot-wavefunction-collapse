# godot-wavefunction-collapse
A simple demo implementation of wavefunction collapse using GDScript

The algorithm creates a 2D array based on MAP_SIZE_X and MAP_SIZE_Y.
It then computes the entropy for each point in the array.
Starting with the lowest entropy, each point in the array is collapsed one by one.
The generation rules are set in the create_tiles method.

This is by no means an optimal solution and can easily be refined further.
