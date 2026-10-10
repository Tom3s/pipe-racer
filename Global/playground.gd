@tool
extends EditorScript

func _run():
	print(Color(0.0, 0.694, 0.749).to_html())
	var col: Color = Color.from_string(Color(0.0, 0.694, 0.749).to_html(), Color.WHITE)

	print(var_to_str(col))