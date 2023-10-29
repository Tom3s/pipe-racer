# @tool
extends PanelContainer
class_name PlayerRebindMenu

var allowedDevices: MultiSelectButton
var container: VBoxContainer

@export
var playerIndex: int = 1

var overrides = {}

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

		rebinders.append(rebinder)

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
		if index == 0:
			rebinder.setKBVisible(isToggled)
		else:
			rebinder.setJoyVisible(isToggled)
		rebinder.devices = deviceList

func setDeviceList():
	var deviceList: Array[int] = []
	match playerIndex:
		1:
			deviceList = [0, 1]
			onAllowedDevices_itemToggled(0, true)
			onAllowedDevices_itemToggled(1, true)
		2:
			deviceList = [0, 2]
			onAllowedDevices_itemToggled(0, true)
			onAllowedDevices_itemToggled(2, true)
		3:
			deviceList = [3]
			onAllowedDevices_itemToggled(0, false)
			onAllowedDevices_itemToggled(3, true)
		4:
			deviceList = [4]
			onAllowedDevices_itemToggled(0, false)
			onAllowedDevices_itemToggled(4, true)
		_:
			deviceList = [0]
	
	allowedDevices.setSelectedItems(deviceList)

func onDefaultButton_pressed():
	for rebinder in rebinders:
		rebinder.reset()
		
