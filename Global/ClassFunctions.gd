extends Node
class_name ClassFunctions

static func getClassName(node: Node) -> String:
	var script = node.get_script()
	if script == null:
		return node.get_class()
	return script.resource_path.get_file().replace(".gd", "")