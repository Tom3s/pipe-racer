@tool
extends EditorScript

func _run() -> void:
	print(OS.get_name())
	print(OS.get_processor_name())
	print(OS.get_environment("USER"))
	print(OS.get_environment("USERNAME"))

	var device_id: String = "%s%s%s%s" % [
		OS.get_name(),
		OS.get_processor_name(),
		OS.get_environment("USER"),
		OS.get_environment("USERNAME"),
	]

	var device_pass: String = device_id.md5_text()

	print(device_pass)