extends HBoxContainer
class_name Rebinder

var actionName: String = ""
var actionIdentifier: String = ""

var devices: Array[int] = [1]:
	set(newValue):
		devices = newValue
		setDevices()

signal joyOverwritten(actionName: String, joypadBind: int, isAxis: bool)

var rebindJoyButton: Button
var joyIcon: TextureRect
var joyInputEvent: InputEvent
	# set(newValue):
	# 	joyInputEvent = newValue
	# 	if newValue is InputEventJoypadButton:
	# 		joyOverwritten.emit(actionName, newValue.button_index, false)
	# 	elif newValue is InputEventJoypadMotion:
	# 		joyOverwritten.emit(actionName, newValue.axis, true)


signal kbOverwritten(actionName: String, kbBind: int)

var rebindKBButton: Button
var kbIcon: TextureRect
var kbInputEvent: InputEventKey
	# set(newValue):
	# 	kbInputEvent = newValue
	# 	kbOverwritten.emit(actionName, newValue.physical_keycode)


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

	for event in InputMap.action_get_events(actionIdentifier):
		if event is InputEventJoypadButton || event is InputEventJoypadMotion:
			joyInputEvent = event
		elif event is InputEventKey:
			kbInputEvent = event

func _unhandled_input(event):
	if rebindJoyButton.button_pressed:
		if event is InputEventJoypadButton || (event is InputEventJoypadMotion && abs(event.get_axis_value()) > 0.5):
			joyInputEvent = event
			rebindJoyButton.text = "Rebind Joy"
			rebindJoyButton.button_pressed = false
			applyJoyInputEvent()
			set_process_unhandled_input(false)
		
	elif rebindKBButton.button_pressed:
		if event is InputEventKey:
			rebindKBButton.text = "Rebind KB"
			rebindKBButton.button_pressed = false
			kbInputEvent = event
			applyKBInputEvent()
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

func applyJoyInputEvent():
	clearJoypadBindings()
	for device in devices:
		if device == 0:
			continue
		var newInput = joyInputEvent.duplicate()
		newInput.device = device - 1
		InputMap.action_add_event(actionIdentifier, newInput)
	if joyInputEvent is InputEventJoypadButton:
		joyIcon.texture = load(RebindMenu.CONTROLLER_BUTTON_ICONS.get(joyInputEvent.button_index, RebindMenu.INVALID_JOY_ICON))
		joyOverwritten.emit(actionName, joyInputEvent.button_index, false)
	elif joyInputEvent is InputEventJoypadMotion:
		joyIcon.texture = load(RebindMenu.CONTROLLER_AXIS_ICONS.get(joyInputEvent.axis, RebindMenu.INVALID_JOY_ICON))
		joyOverwritten.emit(actionName, joyInputEvent.axis, true)

func applyKBInputEvent():
	clearKBBindings()
	InputMap.action_add_event(actionIdentifier, kbInputEvent)
	var texture = load("res://Sprites/KBPrompts/" + str(kbInputEvent.physical_keycode) + ".png")
	if texture:
		kbIcon.texture = texture
	else:
		kbIcon.texture = load(RebindMenu.INVALID_KEY_ICON)
	kbOverwritten.emit(actionName, kbInputEvent.physical_keycode)

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
	if visible && !rebindJoyButton.visible:
		resetJoypadBindings()
	elif visible:
		applyJoyInputEvent()

	rebindJoyButton.visible = visible
	joyIcon.visible = visible
	if !visible:
		clearJoypadBindings()

func setKBVisible(visible: bool):
	if visible && !rebindKBButton.visible:
		resetKBBindings()
	rebindKBButton.visible = visible
	kbIcon.visible = visible
	if !visible:
		clearKBBindings()

func reset():
	resetJoypadBindings()
	resetKBBindings()
	

func resetKBBindings():
	clearKBBindings()
	var inputEvent = InputEventKey.new()
	if actionIdentifier[1] == '1':
		inputEvent.physical_keycode = RebindMenu.defaultKeyboard1Bindings[actionName]
	else:
		inputEvent.physical_keycode = RebindMenu.defaultKeyboard2Bindings.get(actionName, 0)
	InputMap.action_add_event(actionIdentifier, inputEvent)
	setKBIcon()

func resetJoypadBindings():
	clearJoypadBindings()
	for device in devices:
		if device == 0:
			continue
		if RebindMenu.isAxisAction(actionName):
			var inputEvent = InputEventJoypadMotion.new()
			inputEvent.axis = RebindMenu.controllerDefaultBindings[actionName][0]
			var axisDirection = RebindMenu.controllerDefaultBindings[actionName][1]
			if axisDirection != 0:
				inputEvent.axis_value = axisDirection
			inputEvent.device = device - 1
			InputMap.action_add_event(actionIdentifier, inputEvent)
			joyInputEvent = inputEvent
		else:
			var inputEvent = InputEventJoypadButton.new()
			inputEvent.button_index = RebindMenu.controllerDefaultBindings[actionName][0]
			inputEvent.device = device - 1
			InputMap.action_add_event(actionIdentifier, inputEvent)
			joyInputEvent = inputEvent
	setJoyIcon()

func setDevices():
	setKBVisible(devices.has(0))
	setJoyVisible(
		devices.has(1) || \
		devices.has(2) || \
		devices.has(3) || \
		devices.has(4)
	)
	# setJoyVisible(int(devices.has(0)) + 1)

func setJoyOverwrite(joyBind: int, isAxis: bool):
	if isAxis:
		joyInputEvent = InputEventJoypadMotion.new()
		joyInputEvent.axis = joyBind
	else:
		joyInputEvent = InputEventJoypadButton.new()
		joyInputEvent.button_index = joyBind
	applyJoyInputEvent()
	setJoyIcon()

func setKeyOverwrite(keyBind: int):
	kbInputEvent = InputEventKey.new()
	kbInputEvent.physical_keycode = keyBind
	applyKBInputEvent()
	setKBIcon()