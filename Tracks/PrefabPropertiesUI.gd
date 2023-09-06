extends Control
class_name PrefabPropertiesUI

var leftEnd: VSlider
var rightEnd: VSlider
var leftStart: VSlider
var rightStart: VSlider

var leftEndSpinbox: SpinBox
var rightEndSpinbox: SpinBox
var leftStartSpinbox: SpinBox
var rightStartSpinbox: SpinBox

var leftWallStart: CheckBox
var rightWallStart: CheckBox
var leftWallEnd: CheckBox
var rightWallEnd: CheckBox

var leftSmoothing: OptionButton
var rightSmoothing: OptionButton

var curvedTickBox: CheckBox

var snapTickBox: CheckBox

var resetButton: Button

var straightLength: SpinBox
var straightOffset: SpinBox
var straightSmoothing: OptionButton

var curveForward: SpinBox
var curveSideways: SpinBox

var roadTypeSelector: ItemList

signal leftEndChanged(value: float)
signal rightEndChanged(value: float)
signal leftStartChanged(value: float)
signal rightStartChanged(value: float)

signal leftWallEndChanged(value: bool)
signal rightWallEndChanged(value: bool)
signal leftWallStartChanged(value: bool)
signal rightWallStartChanged(value: bool)

signal leftSmoothingChanged(value: int)
signal rightSmoothingChanged(value: int)

signal curvedChanged(value: bool)

signal snapChanged(value: bool)

signal straightLengthChanged(value: float)
signal straightOffsetChanged(value: float)
signal straightSmoothingChanged(value: int)

signal curveForwardChanged(value: float)
signal curveSidewaysChanged(value: float)

signal roadTypeChanged(value: int)

signal mouseEnteredPrefabProperties()
signal mouseExitedPrefabProperties()

func _ready():
	leftEnd = %LeftEnd
	rightEnd = %RightEnd
	leftStart = %LeftStart
	rightStart = %RightStart

	leftEndSpinbox = %LeftEndSpinbox
	rightEndSpinbox = %RightEndSpinbox
	leftStartSpinbox = %LeftStartSpinbox
	rightStartSpinbox = %RightStartSpinbox

	leftWallStart = %LeftWallStart
	rightWallStart = %RightWallStart
	leftWallEnd = %LeftWallEnd
	rightWallEnd = %RightWallEnd

	leftSmoothing = %LeftSmoothing
	rightSmoothing = %RightSmoothing
	leftSmoothingChanged.emit(3)
	rightSmoothingChanged.emit(3)

	curvedTickBox = %CurvedTickBox

	snapTickBox = %SnapTickBox

	resetButton = %ResetButton

	straightLength = %StraightLength
	straightOffset = %StraightOffset
	straightSmoothing = %StraightSmoothing
	straightSmoothingChanged.emit(3)

	curveForward = %CurveForward
	curveSideways = %CurveSideways

	roadTypeSelector = %RoadTypeSelector
	roadTypeSelector.select(0)
	roadTypeChanged.emit(0)

	leftEnd.value_changed.connect(onLeftEndChanged)
	rightEnd.value_changed.connect(onRightEndChanged)
	leftStart.value_changed.connect(onLeftStartChanged)
	rightStart.value_changed.connect(onRightStartChanged)

	leftEndSpinbox.value_changed.connect(onLeftEndSpinboxChanged)
	rightEndSpinbox.value_changed.connect(onRightEndSpinboxChanged)
	leftStartSpinbox.value_changed.connect(onLeftStartSpinboxChanged)
	rightStartSpinbox.value_changed.connect(onRightStartSpinboxChanged)

	leftWallStart.toggled.connect(onLeftWallStartChanged)
	rightWallStart.toggled.connect(onRightWallStartChanged)
	leftWallEnd.toggled.connect(onLeftWallEndChanged)
	rightWallEnd.toggled.connect(onRightWallEndChanged)

	leftSmoothing.item_selected.connect(onLeftSmoothingChanged)
	rightSmoothing.item_selected.connect(onRightSmoothingChanged)

	curvedTickBox.toggled.connect(onCurvedChanged)

	snapTickBox.toggled.connect(onSnapChanged)

	resetButton.pressed.connect(reset)

	straightLength.value_changed.connect(onStraightLengthChanged)
	straightOffset.value_changed.connect(onStraightOffsetChanged)
	straightSmoothing.item_selected.connect(onStraightSmoothingChanged)

	curveForward.value_changed.connect(onCurveForwardChanged)
	curveSideways.value_changed.connect(onCurveSidewaysChanged)

	roadTypeSelector.item_selected.connect(onRoadTypeChanged)

# sync slider with spinbox
func onLeftEndChanged(value: float):
	if leftEndSpinbox.value != value:
		leftEndSpinbox.value = value
		leftEndChanged.emit(value)

func onRightEndChanged(value: float):
	if rightEndSpinbox.value != value:
		rightEndSpinbox.value = value
		rightEndChanged.emit(value)

func onLeftStartChanged(value: float):
	if leftStartSpinbox.value != value:
		leftStartSpinbox.value = value
		leftStartChanged.emit(value)

func onRightStartChanged(value: float):
	if rightStartSpinbox.value != value:
		rightStartSpinbox.value = value
		rightStartChanged.emit(value)

func onLeftEndSpinboxChanged(value: float):
	if leftEnd.value != value:
		leftEnd.value = value
		leftEndChanged.emit(value)

func onRightEndSpinboxChanged(value: float):
	if rightEnd.value != value:
		rightEnd.value = value
		rightEndChanged.emit(value)

func onLeftStartSpinboxChanged(value: float):
	if leftStart.value != value:
		leftStart.value = value
		leftStartChanged.emit(value)

func onRightStartSpinboxChanged(value: float):
	if rightStart.value != value:
		rightStart.value = value
		rightStartChanged.emit(value)

func onLeftWallStartChanged(value: bool):
	leftWallStartChanged.emit(value)

func onRightWallStartChanged(value: bool):
	rightWallStartChanged.emit(value)

func onLeftWallEndChanged(value: bool):
	leftWallEndChanged.emit(value)

func onRightWallEndChanged(value: bool):
	rightWallEndChanged.emit(value)

func onLeftSmoothingChanged(value: int):
	leftSmoothingChanged.emit(value)

func onRightSmoothingChanged(value: int):
	rightSmoothingChanged.emit(value)

func onCurvedChanged(value: bool):
	%CurveProperties.visible = value
	%StraightProperties.visible = !value
	curvedChanged.emit(value)

func onSnapChanged(value: bool):
	snapChanged.emit(value)

func onStraightLengthChanged(value: float):
	straightLengthChanged.emit(value)

func onStraightOffsetChanged(value: float):
	straightOffsetChanged.emit(value)

func onStraightSmoothingChanged(value: int):
	straightSmoothingChanged.emit(value)

func onCurveForwardChanged(value: float):
	curveForwardChanged.emit(value)

func onCurveSidewaysChanged(value: float):
	curveSidewaysChanged.emit(value)

func onRoadTypeChanged(value: int):
	roadTypeChanged.emit(value)

func setFromData(data):
	# func decodeData(data: Variant):
	# leftStartHeight = data["leftStartHeight"]
	# leftEndHeight = data["leftEndHeight"]
	# leftSmoothTilt = data["leftSmoothTilt"]
	# rightStartHeight = data["rightStartHeight"]
	# rightEndHeight = data["rightEndHeight"]
	# rightSmoothTilt = data["rightSmoothTilt"]
	# curve = data["curve"]
	# endOffset = data["endOffset"]
	# smoothOffset = data["smoothOffset"]
	# length = data["length"]
	# curveForward = data["curveForward"]
	# curveSideways = data["curveSideways"]

	leftStart.value = data["leftStartHeight"]
	leftEnd.value = data["leftEndHeight"]
	leftSmoothing.selected = data["leftSmoothTilt"]
	leftSmoothingChanged.emit(data["leftSmoothTilt"])
	rightStart.value = data["rightStartHeight"]
	rightEnd.value = data["rightEndHeight"]
	rightSmoothing.selected = data["rightSmoothTilt"]
	rightSmoothingChanged.emit(data["rightSmoothTilt"])
	leftWallStart.button_pressed = data["leftWallStart"]
	rightWallStart.button_pressed = data["rightWallStart"]
	leftWallEnd.button_pressed = data["leftWallEnd"]
	rightWallEnd.button_pressed = data["rightWallEnd"]
	curvedTickBox.button_pressed = data["curve"]
	straightOffset.value = data["endOffset"]
	straightSmoothing.selected = data["smoothOffset"]
	straightSmoothingChanged.emit(data["smoothOffset"])
	straightLength.value = data["length"]
	curveForward.value = data["curveForward"]
	curveSideways.value = data["curveSideways"]
	roadTypeSelector.select(data["roadType"])
	roadTypeChanged.emit(data["roadType"])

func reset():
	setFromData({
		"leftStartHeight": 0,
		"leftEndHeight": 0,
		"leftSmoothTilt": 3,
		"rightStartHeight": 0,
		"rightEndHeight": 0,
		"rightSmoothTilt": 3,
		"leftWallStart": false,
		"rightWallStart": false,
		"leftWallEnd": false,
		"rightWallEnd": false,
		"curve": false,
		"endOffset": 0,
		"smoothOffset": 3,
		"length": 1,
		"curveForward": 16,
		"curveSideways": 16,
		"roadType": 0,
	})
