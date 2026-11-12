extends Node
class_name MissionManager

signal mission_started(mission: MissionData)
signal mission_completed(mission: MissionData)

var all_missions: Array[MissionData] = []
var current_mission_index: int = 0

# NEW: tracks which "half" of the current mission is done, since a mission
# now has two stages (flowchart, then cartridges) instead of one.
var flowchart_stage_passed: bool = false

func _ready():
	_build_unit1_missions()
	_build_unit2_missions()
	_build_unit3_missions()
	_build_unit4_missions()
	_build_unit5_missions()
	start_mission(0)

func _build_unit1_missions():
	var m0 = MissionData.new()
	m0.mission_id = "onboarding"
	m0.unit_number = 0
	m0.title = "Basic Training"
	m0.problem_statement = "PRACTICE: Welcome to the Kitchen!\n1. Connect START to END with a wire at the Blueprint Table, pull TRACE.\n2. Drop an 'int' token in the Cooking Pot.\n3. Pull COMPILE.\n4. Grab the dish and SERVE it."
	m0.cartridge_sequence = ["int"] as Array[String]
	m0.cartridge_types = [HardwareCartridge.CartridgeType.DATA_TYPE] as Array[int]
	all_missions.append(m0)

	var m1 = MissionData.new()
	m1.mission_id = "u1_decl"
	m1.unit_number = 1
	m1.title = "Declare a Variable"
	m1.problem_statement = "We need a locker to hold an integer. Declare a variable named 'count'."
	m1.cartridge_sequence = ["int", "count"] as Array[String]
	m1.cartridge_types = [HardwareCartridge.CartridgeType.DATA_TYPE, HardwareCartridge.CartridgeType.VARIABLE] as Array[int]
	all_missions.append(m1)

	var m2 = MissionData.new()
	m2.mission_id = "u1_assign"
	m2.unit_number = 1
	m2.title = "Assignment Operator"
	m2.problem_statement = "Set the value of variable 'x' to exactly 5."
	m2.cartridge_sequence = ["x", "=", "5"] as Array[String]
	m2.cartridge_types = [HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m2)

	var m3 = MissionData.new()
	m3.mission_id = "u1_math"
	m3.unit_number = 1
	m3.title = "Basic Math"
	m3.problem_statement = "Add 5 and 10 together and store it in 'result'."
	m3.cartridge_sequence = ["result", "=", "5", "+", "10"] as Array[String]
	m3.cartridge_types = [
		HardwareCartridge.CartridgeType.VARIABLE, 
		HardwareCartridge.CartridgeType.OPERATOR, 
		HardwareCartridge.CartridgeType.VALUE,
		HardwareCartridge.CartridgeType.OPERATOR,
		HardwareCartridge.CartridgeType.VALUE
	] as Array[int]
	all_missions.append(m3)

	var m4 = MissionData.new()
	m4.mission_id = "u1_increment"
	m4.unit_number = 1
	m4.title = "Incrementing"
	m4.problem_statement = "Quickly add 1 to 'count' using the increment operator."
	m4.cartridge_sequence = ["count", "++"] as Array[String]
	m4.cartridge_types = [HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR] as Array[int]
	all_missions.append(m4)

	var m5 = MissionData.new()
	m5.mission_id = "u1_swap_pt1"
	m5.unit_number = 1
	m5.title = "Swap Logic (Part 1)"
	m5.problem_statement = "We want to swap 'x' and 'y'. Start by saving 'x' securely into 'temp'."
	m5.cartridge_sequence = ["temp", "=", "x"] as Array[String]
	m5.cartridge_types = [HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VARIABLE] as Array[int]
	all_missions.append(m5)

	var m6 = MissionData.new()
	m6.mission_id = "u1_modulo"
	m6.unit_number = 1
	m6.title = "Modulo Operator"
	m6.problem_statement = "Find the remainder when 'x' is divided by 10 using modulo."
	m6.cartridge_sequence = ["x", "%", "10"] as Array[String]
	m6.cartridge_types = [HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m6)

	var m7 = MissionData.new()
	m7.mission_id = "u1_equality"
	m7.unit_number = 1
	m7.title = "Boolean Equality"
	m7.problem_statement = "Check if 'i' is exactly equal to 0."
	m7.cartridge_sequence = ["i", "==", "0"] as Array[String]
	m7.cartridge_types = [HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m7)

func start_mission(index: int):
	if index < 0 or index >= all_missions.size():
		return
	current_mission_index = index
	flowchart_stage_passed = false
	mission_started.emit(all_missions[index])

func get_current_mission() -> MissionData:
	if all_missions.is_empty():
		return null
	return all_missions[current_mission_index]

# NEW: called by TraceLever on a validation pass instead of completing
# the mission outright — the mission isn't done until the Assembly Desk
# stage also passes.
func mark_flowchart_passed():
	flowchart_stage_passed = true
	print("MISSION BRIDGE: flowchart stage complete. Head to the Assembly Desk.")

func _transition_to_next():
	current_mission_index += 1
	if current_mission_index < all_missions.size():
		start_mission(current_mission_index)
		get_tree().reload_current_scene()
	else:
		print("ALL MISSIONS COMPLETE!")

func complete_current_mission():
	var m = get_current_mission()
	if m:
		mission_completed.emit(m)
		print("MISSION COMPLETE: ", m.title)
		
		var timer = get_tree().create_timer(3.5)
		timer.timeout.connect(_transition_to_next)
func _build_unit2_missions():
	var m8 = MissionData.new()
	m8.mission_id = "u2_if_basic"
	m8.unit_number = 2
	m8.title = "Basic If Condition"
	m8.problem_statement = "Check if 'count' is equal to 5."
	m8.cartridge_sequence = ["if", "count", "==", "5"] as Array[String]
	m8.cartridge_types = [HardwareCartridge.CartridgeType.LOOP, HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m8)

	var m9 = MissionData.new()
	m9.mission_id = "u2_if_unequal"
	m9.unit_number = 2
	m9.title = "Not Equal To"
	m9.problem_statement = "Check if 'x' is NOT equal to 0."
	m9.cartridge_sequence = ["if", "x", "!=", "0"] as Array[String]
	m9.cartridge_types = [HardwareCartridge.CartridgeType.LOOP, HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m9)

	var m10 = MissionData.new()
	m10.mission_id = "u2_greater"
	m10.unit_number = 2
	m10.title = "Greater Than Check"
	m10.problem_statement = "Check if 'y' is greater than 10."
	m10.cartridge_sequence = ["if", "y", ">", "10"] as Array[String]
	m10.cartridge_types = [HardwareCartridge.CartridgeType.LOOP, HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m10)

	var m11 = MissionData.new()
	m11.mission_id = "u2_less_eq"
	m11.unit_number = 2
	m11.title = "Less or Equal"
	m11.problem_statement = "Check if 'i' is less than or equal to 'x'."
	m11.cartridge_sequence = ["if", "i", "<=", "x"] as Array[String]
	m11.cartridge_types = [HardwareCartridge.CartridgeType.LOOP, HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VARIABLE] as Array[int]
	all_missions.append(m11)

	var m12 = MissionData.new()
	m12.mission_id = "u2_else"
	m12.unit_number = 2
	m12.title = "Fallback Path"
	m12.problem_statement = "Provide an 'else' block fallback."
	m12.cartridge_sequence = ["else"] as Array[String]
	m12.cartridge_types = [HardwareCartridge.CartridgeType.LOOP] as Array[int]
	all_missions.append(m12)

	var m13 = MissionData.new()
	m13.mission_id = "u2_and"
	m13.unit_number = 2
	m13.title = "Logical AND"
	m13.problem_statement = "Check if 'x' is greater than 0 AND 'x' is less than 10."
	m13.cartridge_sequence = ["if", "x", ">", "0", "&&", "x", "<", "10"] as Array[String]
	m13.cartridge_types = [HardwareCartridge.CartridgeType.LOOP, HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m13)

	var m14 = MissionData.new()
	m14.mission_id = "u2_or"
	m14.unit_number = 2
	m14.title = "Logical OR"
	m14.problem_statement = "Check if 'y' is 0 OR 'y' is 1."
	m14.cartridge_sequence = ["if", "y", "==", "0", "||", "y", "==", "1"] as Array[String]
	m14.cartridge_types = [HardwareCartridge.CartridgeType.LOOP, HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m14)

func _build_unit3_missions():
	var m15 = MissionData.new()
	m15.mission_id = "u3_while_basic"
	m15.unit_number = 3
	m15.title = "Basic While Loop"
	m15.problem_statement = "Loop while 'i' is less than 10."
	m15.cartridge_sequence = ["while", "i", "<", "10"] as Array[String]
	m15.cartridge_types = [HardwareCartridge.CartridgeType.LOOP, HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m15)

	var m16 = MissionData.new()
	m16.mission_id = "u3_while_not"
	m16.unit_number = 3
	m16.title = "While Not Equal"
	m16.problem_statement = "Loop while 'count' is NOT equal to 0."
	m16.cartridge_sequence = ["while", "count", "!=", "0"] as Array[String]
	m16.cartridge_types = [HardwareCartridge.CartridgeType.LOOP, HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m16)

	var m17 = MissionData.new()
	m17.mission_id = "u3_infinite"
	m17.unit_number = 3
	m17.title = "Infinite Loop"
	m17.problem_statement = "Create an infinite loop (while 1)."
	m17.cartridge_sequence = ["while", "1"] as Array[String]
	m17.cartridge_types = [HardwareCartridge.CartridgeType.LOOP, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m17)

	var m18 = MissionData.new()
	m18.mission_id = "u3_for_init"
	m18.unit_number = 3
	m18.title = "For Loop Init"
	m18.problem_statement = "Initialize a loop: set 'i' to 0."
	m18.cartridge_sequence = ["for", "i", "=", "0"] as Array[String]
	m18.cartridge_types = [HardwareCartridge.CartridgeType.LOOP, HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m18)

	var m19 = MissionData.new()
	m19.mission_id = "u3_for_cond"
	m19.unit_number = 3
	m19.title = "For Loop Condition"
	m19.problem_statement = "Check that 'i' is less than 5."
	m19.cartridge_sequence = ["i", "<", "5"] as Array[String]
	m19.cartridge_types = [HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m19)

	var m20 = MissionData.new()
	m20.mission_id = "u3_for_inc"
	m20.unit_number = 3
	m20.title = "For Loop Update"
	m20.problem_statement = "Increment 'i' at the end of the loop."
	m20.cartridge_sequence = ["i", "++"] as Array[String]
	m20.cartridge_types = [HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR] as Array[int]
	all_missions.append(m20)

	var m21 = MissionData.new()
	m21.mission_id = "u3_break"
	m21.unit_number = 3
	m21.title = "Break Statement"
	m21.problem_statement = "Break out of the current loop."
	m21.cartridge_sequence = ["break"] as Array[String]
	m21.cartridge_types = [HardwareCartridge.CartridgeType.LOOP] as Array[int]
	all_missions.append(m21)

func _build_unit4_missions():
	var m22 = MissionData.new()
	m22.mission_id = "u4_logic_swap2"
	m22.unit_number = 4
	m22.title = "Variable Swap Part 2"
	m22.problem_statement = "Set 'x' to 'y'."
	m22.cartridge_sequence = ["x", "=", "y"] as Array[String]
	m22.cartridge_types = [HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VARIABLE] as Array[int]
	all_missions.append(m22)

	var m23 = MissionData.new()
	m23.mission_id = "u4_logic_swap3"
	m23.unit_number = 4
	m23.title = "Variable Swap Part 3"
	m23.problem_statement = "Complete the swap: set 'y' to 'temp'."
	m23.cartridge_sequence = ["y", "=", "temp"] as Array[String]
	m23.cartridge_types = [HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VARIABLE] as Array[int]
	all_missions.append(m23)

	var m24 = MissionData.new()
	m24.mission_id = "u4_math_mul"
	m24.unit_number = 4
	m24.title = "Multiplication"
	m24.problem_statement = "Multiply 'x' by 10 and save to 'result'."
	m24.cartridge_sequence = ["result", "=", "x", "*", "10"] as Array[String]
	m24.cartridge_types = [HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m24)

	var m25 = MissionData.new()
	m25.mission_id = "u4_math_sub"
	m25.unit_number = 4
	m25.title = "Subtraction"
	m25.problem_statement = "Subtract 1 from 'count'."
	m25.cartridge_sequence = ["count", "=", "count", "-", "1"] as Array[String]
	m25.cartridge_types = [HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m25)

	var m26 = MissionData.new()
	m26.mission_id = "u4_math_div"
	m26.unit_number = 4
	m26.title = "Division"
	m26.problem_statement = "Divide 'y' by 5 and save to 'temp'."
	m26.cartridge_sequence = ["temp", "=", "y", "/", "5"] as Array[String]
	m26.cartridge_types = [HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m26)

	var m27 = MissionData.new()
	m27.mission_id = "u4_modulo_check"
	m27.unit_number = 4
	m27.title = "Modulo Math"
	m27.problem_statement = "Check if 'x' is perfectly divisible by 5 (remainder 0)."
	m27.cartridge_sequence = ["if", "x", "%", "5", "==", "0"] as Array[String]
	m27.cartridge_types = [HardwareCartridge.CartridgeType.LOOP, HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m27)

	var m28 = MissionData.new()
	m28.mission_id = "u4_logical_not"
	m28.unit_number = 4
	m28.title = "Logical NOT"
	m28.problem_statement = "Check if 'result' is logically FALSE."
	m28.cartridge_sequence = ["if", "!", "result"] as Array[String]
	m28.cartridge_types = [HardwareCartridge.CartridgeType.LOOP, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VARIABLE] as Array[int]
	all_missions.append(m28)

func _build_unit5_missions():
	var m29 = MissionData.new()
	m29.mission_id = "u5_return_zero"
	m29.unit_number = 5
	m29.title = "Return Success Code"
	m29.problem_statement = "Return 0 to indicate success."
	m29.cartridge_sequence = ["return", "0"] as Array[String]
	m29.cartridge_types = [HardwareCartridge.CartridgeType.LOOP, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m29)

	var m30 = MissionData.new()
	m30.mission_id = "u5_return_var"
	m30.unit_number = 5
	m30.title = "Return Variable"
	m30.problem_statement = "Return the 'result' variable."
	m30.cartridge_sequence = ["return", "result"] as Array[String]
	m30.cartridge_types = [HardwareCartridge.CartridgeType.LOOP, HardwareCartridge.CartridgeType.VARIABLE] as Array[int]
	all_missions.append(m30)

	var m31 = MissionData.new()
	m31.mission_id = "u5_guard_clause"
	m31.unit_number = 5
	m31.title = "Guard Clause"
	m31.problem_statement = "If 'i' is less than 0, return 0 early."
	m31.cartridge_sequence = ["if", "i", "<", "0", "return", "0"] as Array[String]
	m31.cartridge_types = [HardwareCartridge.CartridgeType.LOOP, HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE, HardwareCartridge.CartridgeType.LOOP, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m31)

	var m32 = MissionData.new()
	m32.mission_id = "u5_while_break"
	m32.unit_number = 5
	m32.title = "Loop Escape"
	m32.problem_statement = "While 'x' is greater than 0, break."
	m32.cartridge_sequence = ["while", "x", ">", "0", "break"] as Array[String]
	m32.cartridge_types = [HardwareCartridge.CartridgeType.LOOP, HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE, HardwareCartridge.CartridgeType.LOOP] as Array[int]
	all_missions.append(m32)

	var m33 = MissionData.new()
	m33.mission_id = "u5_complex_if"
	m33.unit_number = 5
	m33.title = "Complex Condition"
	m33.problem_statement = "Check if 'temp' is 5 AND 'count' is greater than 1."
	m33.cartridge_sequence = ["if", "temp", "==", "5", "&&", "count", ">", "1"] as Array[String]
	m33.cartridge_types = [HardwareCartridge.CartridgeType.LOOP, HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VARIABLE, HardwareCartridge.CartridgeType.OPERATOR, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m33)

	var m34 = MissionData.new()
	m34.mission_id = "u5_final_boss"
	m34.unit_number = 5
	m34.title = "Final Step"
	m34.problem_statement = "Finally, return 1!"
	m34.cartridge_sequence = ["return", "1"] as Array[String]
	m34.cartridge_types = [HardwareCartridge.CartridgeType.LOOP, HardwareCartridge.CartridgeType.VALUE] as Array[int]
	all_missions.append(m34)
