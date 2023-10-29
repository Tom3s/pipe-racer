extends HBoxContainer
class_name Rebinder

var actionName: String = ""
var actionIdentifier: String = ""

var devices: Array[int] = [1]

var rebindJoyButton: Button
var joyIcon: TextureRect

var rebindKBButton: Button
var kbIcon: TextureRect

func _init(name: String = "accelerate", identifier: String = "p1_accelerate"):
	actionName = name
	actionIdentifier = identifier

func _ready():
	set_process_unhandled_input(false)
	# _init()
	var label = Label.new()
	label.text = actionName.capitalize()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(label)

	rebindJoyButton = Button.new()
	rebindJoyButton.text = "Rebind Joy"
	rebindJoyButton.size_flags_horizontal = Control.SIZE_SHRINK_END
	rebindJoyButton.toggle_mode = true
	rebindJoyButton.alignment = HORIZONTAL_ALIGNMENT_CENTER

	rebindJoyButton.toggled.connect(rebindJoy)
	add_child(rebindJoyButton)

	joyIcon = TextureRect.new()
	setJoyIcon()
	joyIcon.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	joyIcon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	joyIcon.custom_minimum_size = Vector2(35, 0)
	add_child(joyIcon)

	rebindKBButton = Button.new()
	rebindKBButton.text = "Rebind KB"
	rebindKBButton.size_flags_horizontal = Control.SIZE_SHRINK_END
	rebindKBButton.toggle_mode = true
	rebindKBButton.alignment = HORIZONTAL_ALIGNMENT_CENTER

	rebindKBButton.toggled.connect(rebindKB)
	add_child(rebindKBButton)

	kbIcon = TextureRect.new()
	setKBIcon()
	kbIcon.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	kbIcon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	kbIcon.custom_minimum_size = Vector2(35, 0)
	add_child(kbIcon)

func _unhandled_input(event):
	if rebindJoyButton.button_pressed:
		if event is InputEventJoypadButton:
			print("Joy Button: ", event.button_index)
			rebindJoyButton.text = "Rebind Joy"
			rebindJoyButton.button_pressed = false
			clearJoypadBindings()
			InputMap.action_add_event(actionIdentifier, event)
			joyIcon.texture = load(RebindMenu.CONTROLLER_BUTTON_ICONS.get(event.button_index, RebindMenu.INVALID_JOY_ICON))
			print("Rebinded Joy Action: ", actionName)
			set_process_unhandled_input(false)
		elif event is InputEventJoypadMotion:
			if abs(event.get_axis_value()) < 0.5:
				return
			print("Joy Axis: ", event.axis)
			rebindJoyButton.text = "Rebind Joy"
			rebindJoyButton.button_pressed = false
			clearJoypadBindings()
			InputMap.action_add_event(actionIdentifier, event)
			joyIcon.texture = load(RebindMenu.CONTROLLER_AXIS_ICONS.get(event.axis, RebindMenu.INVALID_JOY_ICON))
			print("Rebinded Joy Action: ", actionName)
			set_process_unhandled_input(false)
	elif rebindKBButton.button_pressed:
		if event is InputEventKey:
			print("KB Key: ", event.physical_keycode)
			rebindKBButton.text = "Rebind KB"
			rebindKBButton.button_pressed = false
			clearKBBindings()
			InputMap.action_add_event(actionIdentifier, event)
			var texture = load("res://Sprites/KBPrompts/" + str(event.physical_keycode) + ".png")
			if texture:
				kbIcon.texture = texture
			else:
				kbIcon.texture = load(RebindMenu.INVALID_KEY_ICON)
			print("Rebinded KB Action: ", actionName)
			set_process_input(false)

func setJoyIcon():
	for event in InputMap.action_get_events(actionIdentifier):
		if event is InputEventJoypadButton:
			joyIcon.texture = load(RebindMenu.CONTROLLER_BUTTON_ICONS[event.button_index])
		elif event is InputEventJoypadMotion:
			joyIcon.texture = load(RebindMenu.CONTROLLER_AXIS_ICONS[event.axis])
		else:
			joyIcon.texture = load(RebindMenu.CONTROLLER_BUTTON_ICONS[0])

func clearJoypadBindings():
	for event in InputMap.action_get_events(actionIdentifier):
		if event is InputEventJoypadButton:
			InputMap.action_erase_event(actionIdentifier, event)
		elif event is InputEventJoypadMotion:
			InputMap.action_erase_event(actionIdentifier, event)

func rebindJoy(toggledState: bool):
	rebindJoyButton.custom_minimum_size = rebindJoyButton.size
	if toggledState:
		rebindJoyButton.text = "..."
		print("Rebinding Joy Action: ", actionName)
		set_process_unhandled_input(true)
	else:
		rebindJoyButton.text = "Rebind Joy"

func setKBIcon():
	for event in InputMap.action_get_events(actionIdentifier):
		if event is InputEventKey:
			var texture = load("res://Sprites/KBPrompts/" + str(event.physical_keycode) + ".png")
			if texture:
				kbIcon.texture = texture
			else:
				kbIcon.texture = load(RebindMenu.INVALID_KEY_ICON)
			return
		else:
			kbIcon.texture = load(RebindMenu.INVALID_KEY_ICON)

func clearKBBindings():
	for event in InputMap.action_get_events(actionIdentifier):
		if event is InputEventKey:
			InputMap.action_erase_event(actionIdentifier, event)

func rebindKB(toggledState: bool):
	rebindKBButton.custom_minimum_size = rebindKBButton.size
	if toggledState:
		rebindKBButton.text = "..."
		print("Rebinding KB Action: ", actionName)
		set_process_unhandled_input(true)
	else:
		rebindKBButton.text = "Rebind KB"

func setJoyVisible(visible: bool):
	rebindJoyButton.visible = visible
	joyIcon.visible = visible

func setKBVisible(visible: bool):
	rebindKBButton.visible = visible
	kbIcon.visible = visible

func reset():
	clearJoypadBindings()
	if RebindMenu.isAxisAction(actionName):
		var inputEvent = InputEventJoypadMotion.new()
		inputEvent.axis = RebindMenu.controllerDefaultBindings[actionName][0]
		var axisDirection = RebindMenu.controllerDefaultBindings[actionName][1]
		if axisDirection != 0:
			inputEvent.axis_value = axisDirection
		InputMap.action_add_event(actionIdentifier, inputEvent)
	else:
		var inputEvent = InputEventJoypadButton.new()
		inputEvent.button_index = RebindMenu.controllerDefaultBindings[actionName][0]
		InputMap.action_add_event(actionIdentifier, inputEvent)
	setJoyIcon()

	clearKBBindings()
	var inputEvent = InputEventKey.new()
	if actionIdentifier[1] == '1':
		inputEvent.physical_keycode = RebindMenu.defaultKeyboard1Bindings[actionName]
	else:
		inputEvent.physical_keycode = RebindMenu.defaultKeyboard2Bindings.get(actionName, 0)
	InputMap.action_add_event(actionIdentifier, inputEvent)
	setKBIcon()