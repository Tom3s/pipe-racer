extends Control

var leftEnd: VSlider
var rightEnd: VSlider
var leftStart: VSlider
var rightStart: VSlider

var leftEndSpinbox: SpinBox
var rightEndSpinbox: SpinBox
var leftStartSpinbox: SpinBox
var rightStartSpinbox: SpinBox

var leftSmoothing: OptionButton
var rightSmoothing: OptionButton

var curvedTickBox: CheckBox

var straightLength: SpinBox
var straightOffset: SpinBox
var straightSmoothing: OptionButton

var curveForward: SpinBox
var curveSideways: SpinBox

signal leftEndChanged(value: float)
signal rightEndChanged(value: float)
signal leftStartChanged(value: float)
signal rightStartChanged(value: float)

signal leftSmoothingChanged(value: int)
signal rightSmoothingChanged(value: int)

signal curvedChanged(value: bool)

signal straightLengthChanged(value: float)
signal straightOffsetChanged(value: float)
signal straightSmoothingChanged(value: int)

signal curveForwardChanged(value: float)
signal curveSidewaysChanged(value: float)

func _ready():
	leftEnd = %LeftEnd
	rightEnd = %RightEnd
	leftStart = %LeftStart
	rightStart = %RightStart

	leftEndSpinbox = %LeftEndSpinbox
	rightEndSpinbox = %RightEndSpinbox
	leftStartSpinbox = %LeftStartSpinbox
	rightStartSpinbox = %RightStartSpinbox

	leftSmoothing = %LeftSmoothing
	rightSmoothing = %RightSmoothing

	curvedTickBox = %CurvedTickBox

	straightLength = %StraightLength
	straightOffset = %StraightOffset
	straightSmoothing = %StraightSmoothing

	curveForward = %CurveForward
	curveSideways = %CurveSideways

	leftEnd.value_changed.connect(onLeftEndChanged)
	rightEnd.value_changed.connect(onRightEndChanged)
	leftStart.value_changed.connect(onLeftStartChanged)
	rightStart.value_changed.connect(onRightStartChanged)

	leftEndSpinbox.value_changed.connect(onLeftEndSpinboxChanged)
	rightEndSpinbox.value_changed.connect(onRightEndSpinboxChanged)
	leftStartSpinbox.value_changed.connect(onLeftStartSpinboxChanged)
	rightStartSpinbox.value_changed.connect(onRightStartSpinboxChanged)

	leftSmoothing.item_selected.connect(onLeftSmoothingChanged)
	rightSmoothing.item_selected.connect(onRightSmoothingChanged)

	curvedTickBox.toggled.connect(onCurvedChanged)

	straightLength.value_changed.connect(onStraightLengthChanged)
	straightOffset.value_changed.connect(onStraightOffsetChanged)
	straightSmoothing.item_selected.connect(onStraightSmoothingChanged)

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

func onLeftSmoothingChanged(value: int):
	leftSmoothingChanged.emit(value)

func onRightSmoothingChanged(value: int):
	rightSmoothingChanged.emit(value)

func onCurvedChanged(value: bool):
	%CurveProperties.visible = value
	%StraightProperties.visible = !value
	curvedChanged.emit(value)

func onStraightLengthChanged(value: float):
	straightLengthChanged.emit(value)

func onStraightOffsetChanged(value: float):
	straightOffsetChanged.emit(value)

func onStraightSmoothingChanged(value: int):
	straightSmoothingChanged.emit(value)

