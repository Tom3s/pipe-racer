extends Node
class_name MogyiLogger


static var log_to_file: bool = false
static var push_to_debug: bool = OS.is_debug_build()
# var start_time: int

enum Severity {
	MESSAGE,
	WARNING,
	ERROR,
	SUCCESS,
	FAIL,
}

func _ready() -> void:
	# nvm this is handled by godot and normal print
	self.log(self, "Logger started successfully!")

static func log(
	caller: Node, 
	message: String, 
	severity: Severity = 0, 
	write_to_disk: bool = log_to_file
) -> void:

	var unix_time: float = Time.get_unix_time_from_system()

	# add timestamp
	var timestamp_str: String = "%s.%d" % [
		Time.get_time_string_from_unix_time(unix_time),
		(fmod(unix_time * 1000, 1000.0))
	]

	# add severity
	var severity_str: String = Severity.keys()[severity].capitalize()

	# add script name
	var caller_script_str: String
	if caller != null:
		caller_script_str = caller.get_script().resource_path.get_file()
	else:
		# TODO: resolve static func calls
		caller_script_str = "static call"

	var final_message: String = "[%s][%s][%s] %s" % [
		timestamp_str,
		severity_str,
		caller_script_str,
		message
	]

	print(final_message)
	if push_to_debug:
		if severity == Severity.WARNING:
			push_warning("[%s] %s" % [caller_script_str, message])
		elif severity == Severity.ERROR:
			push_error("[%s] %s" % [caller_script_str, message])
			
		