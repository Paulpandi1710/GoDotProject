extends Node
class_name FlowchartValidator

# ==============================================================================
# FLOWCHART VALIDATION PIPELINE
# ==============================================================================

static func validate_graph(all_nodes: Array, all_cables: Array) -> Dictionary:
	var start_nodes = []
	var end_nodes = []
	
	for node in all_nodes:
		if node is FlowchartNode:
			if node.node_type == FlowchartNode.NodeType.START_END:
				if node.label_text.to_lower() == "start":
					start_nodes.append(node)
				elif node.label_text.to_lower() == "end":
					end_nodes.append(node)
					
	if start_nodes.size() == 0:
		return {"is_valid": false, "message": "SYNTAX ERROR: Missing 'Start' node."}
	if start_nodes.size() > 1:
		return {"is_valid": false, "message": "SYNTAX ERROR: Multiple 'Start' nodes detected."}
	if end_nodes.size() == 0:
		return {"is_valid": false, "message": "SYNTAX ERROR: Missing 'End' node."}

	var visited_nodes = []
	var nodes_to_check = [start_nodes[0]]
	var reached_end = false
	
	while nodes_to_check.size() > 0:
		var curr = nodes_to_check.pop_front()
		if curr in visited_nodes:
			continue
		visited_nodes.append(curr)
		
		if curr.node_type == FlowchartNode.NodeType.START_END and curr.label_text.to_lower() == "end":
			reached_end = true
			continue
			
		var outgoing = []
		for cable in all_cables:
			if cable is FlowCable and cable.start_port != null:
				if cable.start_port.get_parent() == curr:
					outgoing.append(cable)
					
		if curr.node_type == FlowchartNode.NodeType.DECISION:
			if outgoing.size() != 2:
				return {"is_valid": false, "message": "LOGIC ERROR: Decision diamond must have 2 branches."}
		else:
			if outgoing.size() == 0:
				return {"is_valid": false, "message": "LOGIC ERROR: Path dead-end. Missing wire."}
				
		for cable in outgoing:
			if cable.is_plugged_in and cable.target_port != null:
				var next_node = cable.target_port.get_parent()
				if next_node is FlowchartNode:
					nodes_to_check.append(next_node)
					
	if not reached_end:
		return {"is_valid": false, "message": "LOGIC ERROR: Flowchart never reaches 'End'."}
		
	return {"is_valid": true, "message": "VALIDATION PASSED"}
