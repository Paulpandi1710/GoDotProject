class_name MetaphorDatabase
extends RefCounted

## Single source of truth for the fixed warehouse metaphor (Part 7 of the
## design doc). WristScanner and HardwareCartridge's first-exposure popup
## both read from this — one place to add new tokens as missions grow.

const DB = {
	"int": {
		"title": "[ int ] Data Type",
		"analogy": "Warehouse Locker: fits ONLY whole numbers (1, 2, 45). No decimals allowed."
	},
	"float": {
		"title": "[ float ] Data Type",
		"analogy": "Precision Locker: stores numbers with decimal points (3.14, 0.05)."
	},
	"char": {
		"title": "[ char ] Data Type",
		"analogy": "Compact Slot: stores a single letter, symbol, or character ('A', '#')."
	},
	"=": {
		"title": "[ = ] Assignment",
		"analogy": "Loading Dock: places the item on the right into the locker on the left."
	},
	"if": {
		"title": "[ if ] Decision Gate",
		"analogy": "Checkpoint Gate: directs the conveyor belt down Route A or Route B."
	},
	"for": {
		"title": "[ for ] Iteration Gate",
		"analogy": "Conveyor Belt: repeats a cycle a specific number of times until full."
	},
}

static func get_entry(token_key: String) -> Dictionary:
	return DB.get(token_key.to_lower(), {})
