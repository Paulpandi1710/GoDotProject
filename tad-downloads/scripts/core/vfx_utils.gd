class_name VFXUtils
extends RefCounted

# ==============================================================================
# SHARED VFX UTILITY (AAA "JUICE" LAYER)
# ------------------------------------------------------------------------------
# Centralizes one-shot particle bursts so engine_0_core.gd and logic_beam.gd
# don't each hand-roll their own GPUParticles3D setup. Keeps VFX consistent
# and makes future tuning (pooling, quality tiers) a one-file change.
# ==============================================================================

## Spawns a self-cleaning one-shot energy burst at `pos`, parented to `parent`.
## Returns the GPUParticles3D in case the caller wants to tag/track it.
static func spawn_energy_burst(
	parent: Node3D,
	pos: Vector3,
	color: Color,
	amount: int = 32,
	lifetime: float = 1.1
) -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.one_shot = true
	particles.emitting = false
	particles.amount = amount
	particles.lifetime = lifetime
	particles.explosiveness = 0.9
	particles.randomness = 0.35

	var mesh := SphereMesh.new()
	mesh.radius = 0.06
	mesh.height = 0.12

	var mat := StandardMaterial3D.new()
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 3.0
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = mat
	particles.draw_pass_1 = mesh

	var process_mat := ParticleProcessMaterial.new()
	process_mat.direction = Vector3(0, 1, 0)
	process_mat.spread = 180.0
	process_mat.initial_velocity_min = 2.0
	process_mat.initial_velocity_max = 5.5
	process_mat.gravity = Vector3(0, -1.5, 0)
	process_mat.scale_min = 0.4
	process_mat.scale_max = 1.4
	process_mat.color = color
	particles.process_material = process_mat

	parent.add_child(particles)
	particles.global_position = pos
	particles.emitting = true

	# Self-cleanup: don't leave dead emitters littering the scene tree.
	var cleanup_timer := parent.get_tree().create_timer(lifetime + 0.25)
	cleanup_timer.timeout.connect(func():
		if is_instance_valid(particles):
			particles.queue_free()
	)

	return particles
