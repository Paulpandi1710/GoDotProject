extends Node3D
class_name CTerminal

signal prime_found(prime_number: int, layer_index: int)
signal infinite_loop_detected

func compile_code(code_type: String):
	print("[COMPILER] Executing C-Logic...")
	if code_type == "prime_loop":
		_execute_prime_sequence()
	elif code_type == "infinite_loop":
		_execute_infinite_loop()

func _execute_prime_sequence():
	var primes_located = 0
	var current_num = 2
	
	# The While Loop: This loops until all laser grids are bypassed
	while primes_located < 7:
		if _is_prime(current_num):
			primes_located += 1
			prime_found.emit(current_num, primes_located)
			
			# Physically yield Godot's thread to watch the machine react in real-time
			await get_tree().create_timer(1.0).timeout 
			
		current_num += 1

func _is_prime(n: int) -> bool:
	if n <= 1: return false
	for i in range(2, int(sqrt(n)) + 1):
		if n % i == 0: 
			return false
	return true

func _execute_infinite_loop():
	print("[ERROR] while(true) deployed with no break condition!")
	infinite_loop_detected.emit()
