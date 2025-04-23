# godot-wavefunction-collapse
A simple demo implementation of wavefunction collapse/procedural generation using GDScript

The algorithm creates a 2D array based on MAP_SIZE_X and MAP_SIZE_Y.
It then computes the entropy for each point in the array.
Starting with the lowest entropy, each point in the array is collapsed one by one.
The generation rules are set in the create_tiles method.

This is by no means an optimal solution and can easily be refined further.

## How it works
1. **Tile catalogue** – `create_tiles()` lists every tile, its weight (spawn probability) and which neighbours are allowed.  
2. **Entropy grid** – each empty cell starts with full choice; Shannon entropy is recalculated after every collapse.  
3. **Collapse loop**  
   - Pick the cell with the lowest entropy (`get_min_entropy_position`).  
   - Select one legal tile, weighted by probability (`get_random_tile`).  
   - Propagate constraints, recompute entropy, repeat until the map is filled or a contradiction is found (then restart).

All the logic lives in **one script** (`WaveCollapse.gd`), so you can drop it onto any Node2D and hit *Play*.

## Running the demo
1. Clone / download the repo.  
2. Open in **Godot 4.x**.  
3. Run the default scene – the console prints the generated map and entropy grid.

Feel free to tweak:
- `MAP_SIZE_X / MAP_SIZE_Y` – grid dimensions  
- `create_tiles()` – weights & adjacency rules  
- `START_TILE` – optional pre-placed tiles

## Why use it?
- Simple → ~200 LOC, no external addons
- Deterministic structure with stochastic variety
- Good foundation for roguelike levels, puzzles, décor placement, etc.

---

MIT License – do whatever you want
