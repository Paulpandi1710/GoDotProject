extends Node3D

var belt_mesh: MeshInstance3D
var belt_material: ShaderMaterial

var is_running: bool = false
var scroll_speed: float = 2.0
var scroll_offset: float = 0.0

func _ready() -> void:
	_build_belt()

func _build_belt() -> void:
	belt_mesh = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(10.0, 0.2, 2.0)
	belt_mesh.mesh = box
	add_child(belt_mesh)
	
	# Code-generated Shader for smooth infinite scrolling!
	var shader := Shader.new()
	shader.code = """
    shader_type spatial;
    uniform vec3 base_color : source_color = vec3(0.1, 0.12, 0.1);
    uniform vec3 stripe_color : source_color = vec3(0.9, 0.6, 0.1);
    uniform float scroll = 0.0;
    
    void fragment() {
        // Creates a repeating striped pattern along the X axis
        float pattern = fract(UV.x * 6.0 - scroll);
        if (pattern > 0.5) {
            ALBEDO = stripe_color;
            ROUGHNESS = 0.3;
        } else {
            ALBEDO = base_color;
            ROUGHNESS = 0.8;
        }
    }
    """
	belt_material = ShaderMaterial.new()
	belt_material.shader = shader
	belt_mesh.set_surface_override_material(0, belt_material)

	# Side rails so it looks like heavy machinery
	var rail_mat := StandardMaterial3D.new()
	rail_mat.albedo_color = Color(0.2, 0.25, 0.3)
	rail_mat.metallic = 0.8
	rail_mat.roughness = 0.4
	
	for z in [-1.05, 1.05]:
		var rail := MeshInstance3D.new()
		var rbox := BoxMesh.new()
		rbox.size = Vector3(10.2, 0.5, 0.1)
		rail.mesh = rbox
		rail.position = Vector3(0, 0.1, z)
		rail.set_surface_override_material(0, rail_mat)
		add_child(rail)

func _process(delta: float) -> void:
	# Continuously push the UV texture forward without moving the physical mesh
	if is_running:
		scroll_offset += scroll_speed * delta
		belt_material.set_shader_parameter("scroll", scroll_offset)

# Clean triggers for Engine2Main to use!
func start_belt() -> void:
	is_running = true

func stop_belt() -> void:
	is_running = false
