extends Resource
class_name MissionData

## One playable mission. cartridge_sequence is the exact ordered list of
## tokens the Assembly Desk expects for this mission's C statement —
## CompileLever reads this instead of hardcoding "int x = 5".

@export var mission_id: String = ""
@export var unit_number: int = 1
@export var title: String = ""
@export var problem_statement: String = ""

# NEW: ordered tokens this mission's C code should be built from, and the
# rack bins the Assembly Desk should spawn to supply them.
@export var cartridge_sequence: Array[String] = []
@export var cartridge_types: Array[int] = [] # matches HardwareCartridge.CartridgeType, index-aligned with cartridge_sequence
