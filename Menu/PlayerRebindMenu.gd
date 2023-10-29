# @tool
extends PanelContainer
class_name PlayerRebindMenu

var allowedDevices: MultiSelectButton
var container: VBoxContainer

@export
var playerIndex: int = 1

var overrides = {}

var rebinders: Array[Rebinder] = []

func _init(index: int = 1):
	playerIndex = index

func _ready():
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


func onAllowedDevices_itemToggled(index: int, isToggled: bool) -> void:
	if index == 0:
		for rebinder in rebinders:
			rebinder.setKBVisible(isToggled)
	else:
		for rebinder in rebinders:
			rebinder.setJoyVisible(isToggled)



		
