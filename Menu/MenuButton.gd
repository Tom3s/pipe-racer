extends Button

var label: Label

var labelOriginalPosition: Vector2
var labelOriginalColor: Color

var menuSFXPlayer: MenuSFX

var selected: bool = false

func _ready():
	label = get_child(0)
	labelOriginalPosition = label.position
	labelOriginalColor = label.get_theme_color("font_shadow_color")
	menuSFXPlayer = get_tree().root.get_node("MainMenu/MenuSFX")
	mouse_entered.connect(grab_focus)
	mouse_exited.connect(release_focus)
	if menuSFXPlayer != null:
		mouse_entered.connect(menuSFXPlayer.playMenuHover)
		mouse_exited.connect(menuSFXPlayer.playMenuUnhover)
		focus_entered.connect(menuSFXPlayer.playMenuHover)
	set_physics_process(true)

var inAnimation: bool = false

func _physics_process(_delta):

	if inAnimation:
		return

	if (is_hovered() || has_focus()) && !selected:
		label.position = lerp(label.position, labelOriginalPosition + Vector2(0, -8), .2)
		# label.get_theme_color("font_shadow_color") = lerp(label.get_theme_color("font_shadow_color", "Label"), Color(0, 0, 0, 1), .2)
		# var shadowColor: Color = label.get_theme_color("font_shadow_color")
		# label.theme.font_shadow_color = lerp(label.theme.font_shadow_color, Color(0, 0, 0, 1), .2)
		label.add_theme_color_override("font_shadow_color", lerp(label.get_theme_color("font_shadow_color"), Color(0, 0, 0, 1), .2))
		label.add_theme_color_override("font_color", lerp(label.get_theme_color("font_color"), Color.WHITE, .2))
		
	elif (is_hovered() || has_focus()) && selected:
		label.position = lerp(label.position, labelOriginalPosition + Vector2(0, -8), .2)
		# label.get_theme_color("font_shadow_color") = lerp(label.get_theme_color("font_shadow_color", "Label"), Color(0, 0, 0, 1), .2)
		# var shadowColor: Color = label.get_theme_color("font_shadow_color")
		# label.theme.font_shadow_color = lerp(label.theme.font_shadow_color, Color(0, 0, 0, 1), .2)
		label.add_theme_color_override("font_shadow_color", lerp(label.get_theme_color("font_shadow_color"), Color(0, 0, 0, 1), .2))
		label.add_theme_color_override("font_color", lerp(label.get_theme_color("font_color"), Color(.3, .3, .3, 1), .2))
	elif !(is_hovered() || has_focus()) && selected:
		label.position = lerp(label.position, labelOriginalPosition, .2)
		# label.theme.font_shadow_color = lerp(label.theme.font_shadow_color, labelOriginalColor, .2)
		label.add_theme_color_override("font_shadow_color", lerp(label.get_theme_color("font_shadow_color"), Color.WHITE, .2))
		label.add_theme_color_override("font_color", lerp(label.get_theme_color("font_color"), Color(.3, .3, .3, 1), .2))

	else:
		label.position = lerp(label.position, labelOriginalPosition, .2)
		# label.theme.font_shadow_color = lerp(label.theme.font_shadow_color, labelOriginalColor, .2)
		label.add_theme_color_override("font_shadow_color", lerp(label.get_theme_color("font_shadow_color"), labelOriginalColor, .2))
		label.add_theme_color_override("font_color", lerp(label.get_theme_color("font_color"), Color.WHITE, .2))

