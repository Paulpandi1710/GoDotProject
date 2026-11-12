extends Node
class_name VFXManager
# Generates runtime GPU Particles so we don't need external texture assets.

static func create_steam_emitter() -> GPUParticles3D:
	var particles = GPUParticles3D.new()
	var mat = ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 0.3
	mat.gravity = Vector3(0, 1.2, 0)
	mat.scale_min = 0.5
	mat.scale_max = 1.5
	
	var pass_mat = StandardMaterial3D.new()
	pass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pass_mat.albedo_color = Color(1.0, 1.0, 1.0, 0.35)
	pass_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	pass_mat.billboard_keep_scale = true
	
	var quad = QuadMesh.new()
	quad.size = Vector2(0.2, 0.2)
	quad.material = pass_mat
	
	particles.process_material = mat
	particles.draw_pass_1 = quad
	particles.amount = 16
	particles.lifetime = 2.5
	return particles

static func create_success_burst() -> GPUParticles3D:
	var particles = GPUParticles3D.new()
	var mat = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 180
	mat.initial_velocity_min = 3.0
	mat.initial_velocity_max = 6.0
	mat.gravity = Vector3(0, -3.0, 0)
	
	var pass_mat = StandardMaterial3D.new()
	pass_mat.emission_enabled = true
	pass_mat.emission = Color(1.0, 0.85, 0.2)
	pass_mat.emission_energy_multiplier = 2.0
	pass_mat.albedo_color = Color(1.0, 0.85, 0.2)
	pass_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	
	var quad = QuadMesh.new()
	quad.size = Vector2(0.06, 0.06)
	quad.material = pass_mat
	
	particles.process_material = mat
	particles.draw_pass_1 = quad
	particles.amount = 45
	particles.lifetime = 1.0
	particles.explosiveness = 0.95
	particles.one_shot = true
	return particles

static func create_error_puff() -> GPUParticles3D:
	var particles = GPUParticles3D.new()
	var mat = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 50
	mat.initial_velocity_min = 1.5
	mat.initial_velocity_max = 3.0
	mat.gravity = Vector3(0, 0.2, 0)
	mat.scale_min = 1.0
	mat.scale_max = 2.5
	
	var pass_mat = StandardMaterial3D.new()
	pass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pass_mat.albedo_color = Color(0.9, 0.1, 0.1, 0.7)
	pass_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	
	var quad = QuadMesh.new()
	quad.size = Vector2(0.25, 0.25)
	quad.material = pass_mat
	
	particles.process_material = mat
	particles.draw_pass_1 = quad
	particles.amount = 25
	particles.lifetime = 1.2
	particles.explosiveness = 0.85
	particles.one_shot = true
	return particles
