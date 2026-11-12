class_name AssetUtils
extends RefCounted

# ==============================================================================
# ASSET UTILITIES — RUNTIME BOUNDING BOX MEASUREMENT
# ------------------------------------------------------------------------------
# WHY THIS EXISTS:
# The original room-builder assumed every Quaternius module was a clean 2m or
# 4m cube with a centered pivot ("i * 4.0", "i * 2.0", crate collision hardcoded
# to Vector3(2,2,2)). Real modular kits almost never work that way — tile
# footprints vary between packs, and pivots are frequently at a corner or edge
# rather than the visual center. Guessing those numbers is exactly what caused
# the floor/wall pieces to overlap and fan out, and the crate label to float
# at the wrong height.
#
# The correct fix is to MEASURE each glTF scene once at load time by walking
# its MeshInstance3D children and unioning their transformed AABBs, then lay
# everything out from that real size instead of a guessed constant.
# ==============================================================================

## Returns the combined AABB of every MeshInstance3D under `root`, expressed
## in root's local space. Does NOT require root to be inside the SceneTree.
static func compute_bounds(root: Node3D) -> AABB:
	var bounds := AABB()
	var initialized := false

	var stack: Array = [[root, Transform3D.IDENTITY]]
	while stack.size() > 0:
		var entry: Array = stack.pop_back()
		var node: Node = entry[0]
		var parent_xform: Transform3D = entry[1]

		var local_xform := parent_xform
		if node is Node3D:
			local_xform = parent_xform * node.transform

		if node is MeshInstance3D and node.mesh:
			var world_aabb: AABB = local_xform * node.mesh.get_aabb()
			if initialized:
				bounds = bounds.merge(world_aabb)
			else:
				bounds = world_aabb
				initialized = true

		for child in node.get_children():
			stack.append([child, local_xform])

	return bounds

## Re-parents `node` so its own origin sits at the center of its visual AABB
## instead of wherever the source asset's pivot happened to be. Useful for
## modular kit pieces exported with a corner pivot, which otherwise throws
## off rotation and grid-snapping math.
static func recenter_pivot(node: Node3D) -> Vector3:
	var bounds := compute_bounds(node)
	var offset := bounds.get_center()
	for child in node.get_children():
		if child is Node3D:
			child.position -= offset
	return offset
