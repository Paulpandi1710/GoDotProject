class_name CollisionLayers
extends RefCounted

## Central place for this project's physics collision layer values, so
## every script that filters by layer agrees on the same numbers.
## Godot layers are 1-based; layer N = collision_layer bit value 2^(N-1).

const NONE: int = 0
const WORLD: int = 1   # Grabbable rigid bodies: cartridges, flowchart nodes, cable plugs
const PORT: int = 2    # CablePort Area3D detection layer
