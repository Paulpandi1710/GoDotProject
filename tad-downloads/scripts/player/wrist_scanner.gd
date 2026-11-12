extends Node3D
class_name WristScanner

# ==============================================================================
# WRIST SCANNER ENGINE (3-TIER ADAPTIVE INSPECTOR)
# Uses the unified warehouse metaphor: Variables are Lockers, Data Types are Sizes.
# ==============================================================================

@export var scan_ray: RayCast3D
var display_label: Label3D
var analogy_label: Label3D
var current_scanned_object: Node = null

# Warehouse Metaphor Database[cite: 1]
const METAPHOR_DB = {
	"int": {
		"title": "[ int ] Data Type",
		"size": "4 Bytes Allocation",
		"analogy": "Warehouse Locker: Fits ONLY whole numbers (1, 2, 45). No decimals allowed."
	},
	"float": {
		"title": "[ float ] Data Type",
		"size": "4 Bytes Allocation",
		"analogy": "Precision Locker: Stores numbers with decimal points (3.14, 0.05)."
	},
	"char": {
		"title": "[ char ] Data Type",
		"size": "1 Byte Allocation",
		"analogy": "Compact Slot: Stores a single letter, symbol, or character ('A', '#')."
	},
	"if": {
		"title": "[ if ] Decision Gate",
		"size": "Flow Control",
		"analogy": "Checkpoint Gate: Directs the conveyor belt down Route A or Route B."
	},
	"for": {
		"title": "[ for ] Iteration Gate",
		"size": "Loop Control",
		"analogy": "Conveyor Belt: Repeats a cycle a specific number of times until full."
	}
}

func _ready():
	_build_holographic_display()

func _build_holographic_display():
	display_label = Label3D.new()
	display_label.font_size = 48
	display_label.outline_size = 12
	display_label.modulate = Color(0.2, 1.0, 0.4)
	display_label.outline_modulate = Color.BLACK
	display_label.position = Vector3(0, 0.25, 0)
	add_child(display_label)
	
	analogy_label = Label3D.new()
	analogy_label.font_size = 32
	analogy_label.outline_size = 8
	analogy_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	analogy_label.width = 400.0
	analogy_label.modulate = Color(0.9, 0.9, 0.9)
	analogy_label.position = Vector3(0, 0.05, 0)
	add_child(analogy_label)
	
	_show_idle()

func _process(_delta):
	if scan_ray and scan_ray.is_colliding():
		var collider = scan_ray.get_collider()
		if collider != current_scanned_object:
			current_scanned_object = collider
			_inspect_object(collider)
	elif current_scanned_object != null:
		current_scanned_object = null
		_show_idle()

func _inspect_object(obj: Node):
	var token_key = ""
	if obj is HardwareCartridge:
		token_key = obj.token_name.to_lower()
	elif obj is FlowchartNode:
		token_key = obj.label_text.to_lower()
		
	if METAPHOR_DB.has(token_key):
		var data = METAPHOR_DB[token_key]
		display_label.text = "%s\n%s" % [data["title"], data["size"]]
		analogy_label.text = data["analogy"]
	else:
		display_label.text = "HARDWARE CARTRIDGE"
		analogy_label.text = "Modular C-programming hardware unit."

func _show_idle():
	display_label.text = "SYSTEM SCANNER ACTIVE"
	analogy_label.text = "Aim scanner at any hardware cartridge or node for diagnostics."
