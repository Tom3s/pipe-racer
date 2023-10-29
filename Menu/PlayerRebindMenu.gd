# @tool
extends PanelContainer
class_name PlayerRebindMenu

var allowedDevices: MultiSelectButton
var container: VBoxContainer

@export
var playerIndex: int = 1

var keyOverrides = {}
var joyOverrides = {}

var rebinders: Array[Rebinder] = []

var defaultButton: Button

func _init(index: int = 1):
	playerIndex = index
	# setDeviceList()

func _ready():
	add_theme_stylebox_override("panel", load("res://Menu/PaddedPanel.tres"))

	set_process_unhandled_input(false)

	container = VBoxContainer.new()
	add_child(container)


	allowedDevices = MultiSelectButton.new()
	allowedDevices.text = "Allowed Devices"

	container.add_child(allowedDevices)


	allowedDevices.clear()
	allowedDevices.addItem("Keyboard")
	for device in Input.get_connected_joypads():
		allowedDevices.addItem(Input.get_joy_name(device))	

	allowedDevices.itemToggled.connect(onAllowedDevices_itemToggled)

	for action in RebindMenu.ALL_ACTIONS:
		var actionString = 'p' + str(playerIndex) + '_' + action
		var rebinder = Rebinder.new(action, actionString)
		container.add_child(rebinder)
		if GlobalProperties.JOY_CONTROL_OVERWRITES[str(playerIndex)].has(action):
			var settings = GlobalProperties.JOY_CONTROL_OVERWRITES[str(playerIndex)][action]
			rebinder.setJoyOverwrite(settings[0], settings[1])
		if GlobalProperties.KB_CONTROL_OVERWRITES[str(playerIndex)].has(action):
			rebinder.setKeyOverwrite(GlobalProperties.KB_CONTROL_OVERWRITES[str(playerIndex)][action])
		if GlobalProperties.CONTROL_DEVICE_OVERWRITES[str(playerIndex)].size() > 0:
			var intArray: Array[int]
			intArray.assign(GlobalProperties.CONTROL_DEVICE_OVERWRITES[str(playerIndex)])
			print("OverWritten Devices: ", intArray)
			rebinder.devices = intArray
			allowedDevices.setSelectedItems(intArray)

		# set rebinder's joy and key overrides


		rebinders.append(rebinder)

		rebinder.joyOverwritten.connect(onJoyOwerwritten)
		rebinder.kbOverwritten.connect(onKeyOverwritten)

	defaultButton = Button.new()
	defaultButton.text = "Default"
	defaultButton.pressed.connect(onDefaultButton_pressed)
	defaultButton.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	container.add_child(defaultButton)

	setDeviceList()


func onAllowedDevices_itemToggled(index: int, isToggled: bool) -> void:
	# if index == 0:
	# 	for rebinder in rebinders:
	# 		rebinder.setKBVisible(isToggled)
	# else:
	# 	for rebinder in rebinders:
	# 		rebinder.setJoyVisible(isToggled)
	
	var deviceList = allowedDevices.getSelectedItems()

	for rebinder in rebinders:
		# if index == 0:
		# 	rebinder.setKBVisible(isToggled)
		# else:
		# 	rebinder.setJoyVisible(isToggled)
		# rebinder.devices = deviceList
		rebinder.devices = deviceList

func setDeviceList():
	var deviceList: Array[int]
	if GlobalProperties.CONTROL_DEVICE_OVERWRITES[str(playerIndex)].size() > 0:
		deviceList.assign(GlobalProperties.CONTROL_DEVICE_OVERWRITES[str(playerIndex)])
	# match playerIndex:
	# 	1:
	# 		if deviceList == null:
	# 			deviceList = [0, 1]
	# 		onAllowedDevices_itemToggled(0, true)
	# 		onAllowedDevices_itemToggled(1, true)
	# 	2:
	# 		if deviceList == null:
	# 			deviceList = [0, 2]
	# 		onAllowedDevices_itemToggled(0, true)
	# 		onAllowedDevices_itemToggled(2, true)
	# 	3:
	# 		if deviceList == null:
	# 			deviceList = [3]
	# 		onAllowedDevices_itemToggled(0, false)
	# 		onAllowedDevices_itemToggled(3, true)
	# 	4:
	# 		if deviceList == null:
	# 			deviceList = [4]
	# 		onAllowedDevices_itemToggled(0, false)
	# 		onAllowedDevices_itemToggled(4, true)
	# 	_:
	# 		deviceList = [0]
	
	allowedDevices.setSelectedItems(deviceList)

func onDefaultButton_pressed():
	for rebinder in rebinders:
		rebinder.reset()
		
func onJoyOwerwritten(actionName: String, joypadBind: int, isAxis: bool):
	joyOverrides[actionName] = [joypadBind, isAxis]
	GlobalProperties.JOY_CONTROL_OVERWRITES[str(playerIndex)] = joyOverrides
	GlobalProperties.CONTROL_DEVICE_OVERWRITES[str(playerIndex)] = allowedDevices.getSelectedItems()
	GlobalProperties.saveToFile()

func onKeyOverwritten(actionName: String, keyBind: int):
	keyOverrides[actionName] = keyBind
	GlobalProperties.KB_CONTROL_OVERWRITES[str(playerIndex)] = keyOverrides
	GlobalProperties.CONTROL_DEVICE_OVERWRITES[str(playerIndex)] = allowedDevices.getSelectedItems()
	GlobalProperties.saveToFile()