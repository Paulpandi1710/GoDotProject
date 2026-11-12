extends Node
class_name CompilerBackend
# ==============================================================================
# OFFLINE COMPILER & TEST RUNNER PIPELINE
# ==============================================================================
signal compilation_succeeded(output_message: String)
signal compilation_failed(error_message: String)

func compile_and_test(tokens: Array, test_inputs: Array, expected_outputs: Array):
	# Without this guard, an empty tokens array produced valid-but-
	# meaningless C ("int main() { ; return 0; }"), and since test_inputs
	# was also empty, the pass/fail loop below never executed even once —
	# so it fell through to "ALL TEST CASES PASSED" despite nothing
	# actually being compiled from real cartridges.
	if tokens.is_empty():
		compilation_failed.emit("COMPILE ERROR: no cartridges on the track. Nothing to compile.")
		return

	# 1. Synthesize C Source Code
	var code_body = ""
	
	# Pre-declare variables commonly used in the curriculum so gcc doesn't complain about undeclared variables
	var variables_decl = "int count = 0, x = 0, y = 0, temp = 0, result = 0, i = 0;"
	
	if tokens.size() > 0:
		var t0 = tokens[0]
		if t0 == "if" or t0 == "while":
			var action_idx = -1
			for idx in range(1, tokens.size()):
				if tokens[idx] == "return" or tokens[idx] == "break":
					action_idx = idx
					break
			
			var condition = ""
			var body_stmt = ""
			if action_idx != -1:
				condition = " ".join(tokens.slice(1, action_idx))
				body_stmt = " ".join(tokens.slice(action_idx)) + ";"
			else:
				condition = " ".join(tokens.slice(1))
				body_stmt = ""
			
			code_body = t0 + " (" + condition + ") { " + body_stmt + " }"
		elif t0 == "else":
			code_body = "else {}"
		elif t0 == "for":
			tokens.remove_at(0)
			code_body = " ".join(tokens) + ";"
		else:
			code_body = " ".join(tokens) + ";"
	
	var full_c_source = """
#include <stdio.h>
int main() {
	%s
	%s
	return 0;
}
""" % [variables_decl, code_body]

	# 2. Write temp source file
	var temp_c_path = ProjectSettings.globalize_path("user://temp_run.c")
	var temp_bin_path = ProjectSettings.globalize_path("user://temp_run.bin")

	var file = FileAccess.open("user://temp_run.c", FileAccess.WRITE)
	if not file:
		compilation_failed.emit("SYSTEM ERROR: Cannot write temporary file.")
		return
	file.store_string(full_c_source)
	file.close()

	# 3. Compile via native local compiler (gcc)
	var compile_output = []
	var exit_code = OS.execute("gcc", [temp_c_path, "-o", temp_bin_path], compile_output, true)

	if exit_code != 0:
		var err = compile_output[0] if compile_output.size() > 0 else "Syntax Compilation Error"
		compilation_failed.emit(err)
		return

	# 4. Evaluate Test Cases
	for i in range(test_inputs.size()):
		var run_output = []
		OS.execute(temp_bin_path, [str(test_inputs[i])], run_output, true)
		var actual = run_output[0].strip_edges() if run_output.size() > 0 else ""

		if actual != str(expected_outputs[i]):
			compilation_failed.emit("TEST FAILED: Case %d (Expected '%s', Got '%s')" % [i + 1, expected_outputs[i], actual])
			return

	# Even with real tokens, zero test_inputs means "compiled with no
	# runtime verification" — worth distinguishing from a fully verified
	# pass, since Unit 1 missions have no printf/scanf yet.
	if test_inputs.is_empty():
		compilation_succeeded.emit("COMPILED SUCCESSFULLY. (No test cases defined for this mission.)")
	else:
		compilation_succeeded.emit("ALL TEST CASES PASSED. FACILITY INTEGRITY RESTORED.")
