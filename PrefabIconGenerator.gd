extends Node3D
class_name PrefabIconGenerator

@onready var camera: Camera3D = %Camera3D
@onready var prefabMesher: PrefabMesher = %PrefabMesher
@onready var subViewport: SubViewport = %SubViewport

# var initialPosition: Vector3 = Vector3(-70, 120, -143)

signal newPrefab(category: int, name: String, data: Dictionary, icon: Texture)
signal done()


# var done: bool = false

var endOffsetSize: int = floori(PrefabConstants.TRACK_WIDTH / PrefabConstants.GRID_SIZE)






var lengthIndex = 0
var lengthRange = range(2, 3 + 1)

var endOffsetIndex = 0
var endOffsetRange = [0, -endOffsetSize, endOffsetSize]

var leftHeightIndex = 0
var leftHeightRange = range(0, 3 + 1, 3)

var rightHeightIndex = 0
var rightHeightRange = range(0, 3 + 1, 3)

var startWallIndex = 0
var startWallRange = [false, true]

var endWallIndex = 0
var endWallRange = [false, true]

var curveIndex = 0
var curveRange = [false, true]

var curveForwardIndex = 0
var curveForwardRange = [endOffsetSize, endOffsetSize * 2, endOffsetSize * 3]

var curveSidewaysIndex = 0
var curveSidewaysRange = [endOffsetSize, endOffsetSize * 2, endOffsetSize * 3]

var started: int = 3
var curve: bool = false

var fresh: bool = true

func _ready():
	var dir = DirAccess.open("user://")
	if dir.dir_exists("user://prefabIcons"):
		fresh = false
	else:
		dir.make_dir("user://prefabIcons")
		fresh = true


var length
var endOffset
var leftHeight
var rightHeight
var startWall
var endWall
var curveForward
var curveSideways

func prepareVariables():
	length = lengthRange[lengthIndex]
	endOffset = endOffsetRange[endOffsetIndex]
	leftHeight = leftHeightRange[leftHeightIndex]
	rightHeight = rightHeightRange[rightHeightIndex]
	startWall = startWallRange[startWallIndex]
	endWall = endWallRange[endWallIndex]
	curveForward = curveForwardRange[curveForwardIndex]
	curveSideways = curveSidewaysRange[curveSidewaysIndex]

func getStraightDict():
	return {
		"length": length,
		"endOffset": endOffset,
		"leftStartHeight": leftHeight,
		"rightStartHeight": rightHeight,
		"leftEndHeight": leftHeight,
		"rightEndHeight": rightHeight,
		"leftWallStart": startWall,
		"rightWallStart": startWall,
		"leftWallEnd": endWall,
		"rightWallEnd": endWall,
		"leftSmoothTilt": 3,
		"rightSmoothTilt": 3,
		"smoothOffset": 3,
		"curve": false,
	}

func incrementStraigthIndeces():
	
	lengthIndex += 1
	if lengthIndex >= lengthRange.size(): # || curveIndex == 0:
		lengthIndex = 0
		endOffsetIndex += 1
	if endOffsetIndex >= endOffsetRange.size(): # || curveIndex == 0:
		endOffsetIndex = 0
		endWallIndex += 1
	if endWallIndex >= endWallRange.size():
		endWallIndex = 0
		startWallIndex += 1
	if startWallIndex >= startWallRange.size():
		startWallIndex = 0
		rightHeightIndex += 1
	if rightHeightIndex >= rightHeightRange.size():
		rightHeightIndex = 0
		leftHeightIndex += 1
	if leftHeightIndex >= leftHeightRange.size():
		leftHeightIndex = 0
		curve = true

func getCurveDict():
	return {
		"leftStartHeight": leftHeight,
		"rightStartHeight": rightHeight,
		"leftEndHeight": leftHeight,
		"rightEndHeight": rightHeight,
		"leftWallStart": startWall,
		"rightWallStart": startWall,
		"leftWallEnd": endWall,
		"rightWallEnd": endWall,
		"curve": true,
		"leftSmoothTilt": 3,
		"rightSmoothTilt": 3,
		"smoothOffset": 3,
		"curveForward": curveForward,
		"curveSideways": curveSideways,
	}

func incrementCurveIndeces():
	curveSidewaysIndex += 1
	if curveSidewaysIndex >= curveSidewaysRange.size(): # || curveIndex == 1:
		curveSidewaysIndex = 0
		curveForwardIndex += 1
	if curveForwardIndex >= curveForwardRange.size(): # || curveIndex == 1:
		curveForwardIndex = 0
		endWallIndex += 1
	if endWallIndex >= endWallRange.size():
		endWallIndex = 0
		startWallIndex += 1
	if startWallIndex >= startWallRange.size():
		startWallIndex = 0
		rightHeightIndex += 1
	if rightHeightIndex >= rightHeightRange.size():
		rightHeightIndex = 0
		leftHeightIndex += 1
	if leftHeightIndex >= leftHeightRange.size():
		leftHeightIndex = 0
		print("done")
		done.emit()
		queue_free()
		visible = false
		doneGenerating = true

var doneGenerating: bool = false
func _process(_delta):
	if !fresh:
		while !doneGenerating:
			getNextIcon()
	if (started > 0):
		prepareVariables()
		var dict = {
				"length": length,
				"endOffset": endOffset,
				"leftStartHeight": leftHeight,
				"rightStartHeight": rightHeight,
				"leftEndHeight": leftHeight,
				"rightEndHeight": rightHeight,
				"leftWallStart": startWall,
				"rightWallStart": startWall,
				"leftWallEnd": endWall,
				"rightWallEnd": endWall,
				"curve": false,
			}

		prefabMesher.decodeData(dict)
		started -= 1
		return
	
	getNextIcon()
	# await newPrefab

func preparePicture(dict: Dictionary):
	prefabMesher.decodeData(dict)
	camera.look_at(Vector3(0, 0, 0))
	prefabMesher.global_position = -prefabMesher.getCenteringOffset()

func getNextIcon():
	var category = 0
	var dict = {}
	if (rightHeightIndex == 1 && leftHeightIndex == 1):
		if !curve:
			incrementStraigthIndeces()
		else:
			incrementCurveIndeces()
	prepareVariables()
	if !curve: # straight only
		dict = getStraightDict()
		category = 0
		incrementStraigthIndeces()
	else:
		dict = getCurveDict()
		category = 1
		incrementCurveIndeces()
	
	if fresh:
		preparePicture(dict)
		await RenderingServer.frame_post_draw
		newPrefab.emit(category, prefabMesher.getStringName(), dict, ImageTexture.create_from_image(subViewport.get_texture().get_image()))
		subViewport.get_texture().get_image().save_png("user://prefabIcons/" + prefabMesher.getStringName() + ".png")
	else:
		var stringName = prefabMesher.getStringNameFromData(dict)
		newPrefab.emit(category, stringName, dict, ImageTexture.create_from_image(Image.load_from_file("user://prefabIcons/" + stringName + ".png")))



