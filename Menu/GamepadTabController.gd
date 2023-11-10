extends TabContainer



func _ready():
	set_physics_process(true)

func _physics_process(delta):
	if !is_visible_in_tree():
		return
	if Input.is_action_just_pressed("ui_next_tab"):
		current_tab = (current_tab + get_tab_count() + 1) % get_tab_count()
	if Input.is_action_just_pressed("ui_prev_tab"):
		current_tab = (current_tab + get_tab_count() - 1) % get_tab_count()
