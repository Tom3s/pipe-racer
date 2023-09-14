extends Node3D
class_name PrefabIconGenerator

@onready var camera: Camera3D = %Camera3D
@onready var prefabMesher: PrefabMesher = %PrefabMesher
@onready var subViewport: SubViewport = %SubViewport

# var initialPosition: Vector3 = Vector3(-70, 120, -143)

signal newPrefab(category: int, name: String, data: Dictionary, icon: Texture)
signal done()


# var done: bool = false

var endOffsetSize: int = PrefabConstants.TRACK_WIDTH / PrefabConstants.GRID_SIZE






var lengthIndex = 0
var lengthRange = range(2, 3 + 1)

var endOffsetIndex = 0
var endOffsetRange = [-endOffsetSize, 0, endOffsetSize]

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
func _process(_delta):
	if (started > 0):
		var length = lengthRange[lengthIndex]
		var endOffset = endOffsetRange[endOffsetIndex]
		var leftHeight = leftHeightRange[leftHeightIndex]
		var rightHeight = rightHeightRange[rightHeightIndex]
		var startWall = startWallRange[startWallIndex]
		var endWall = endWallRange[endWallIndex]
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
	if !curve: # straight only
		# if leftHeightIndex == 1 && rightHeightIndex == 1:
		# 	return
		if !(rightHeightIndex == 1 && leftHeightIndex == 1):
			var length = lengthRange[lengthIndex]
			var endOffset = endOffsetRange[endOffsetIndex]
			var leftHeight = leftHeightRange[leftHeightIndex]
			var rightHeight = rightHeightRange[rightHeightIndex]
			var startWall = startWallRange[startWallIndex]
			var endWall = endWallRange[endWallIndex]


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
				"leftSmoothTilt": 3,
				"rightSmoothTilt": 3,
				"smoothOffset": 3,
				"curve": false,
			}

			prefabMesher.decodeData(dict)
			camera.look_at(Vector3(0, 0, 0))
			prefabMesher.global_position = -prefabMesher.getCenteringOffset()

			await RenderingServer.frame_post_draw
			newPrefab.emit(0, prefabMesher.getStringName(), dict, ImageTexture.create_from_image(subViewport.get_texture().get_image()))

		rightHeightIndex += 1
		if rightHeightIndex >= rightHeightRange.size():
			rightHeightIndex = 0
			leftHeightIndex += 1
		if leftHeightIndex >= leftHeightRange.size():
			leftHeightIndex = 0
			endWallIndex += 1
		if endWallIndex >= endWallRange.size():
			endWallIndex = 0
			startWallIndex += 1
		if startWallIndex >= startWallRange.size():
			startWallIndex = 0
			lengthIndex += 1
		if lengthIndex >= lengthRange.size(): # || curveIndex == 0:
			lengthIndex = 0
			endOffsetIndex += 1
		if endOffsetIndex >= endOffsetRange.size(): # || curveIndex == 0:
			endOffsetIndex = 0
			curve = true
			# done = true
			# print("done")
			# queue_free()
			# visible = false
	else:
		# if leftHeightIndex == 1 && rightHeightIndex == 1:
		# 	return
		if !(rightHeightIndex == 1 && leftHeightIndex == 1):
			var leftHeight = leftHeightRange[leftHeightIndex]
			var rightHeight = rightHeightRange[rightHeightIndex]
			var startWall = startWallRange[startWallIndex]
			var endWall = endWallRange[endWallIndex]
			var curveForward = curveForwardRange[curveForwardIndex]
			var curveSideways = curveSidewaysRange[curveSidewaysIndex]


			var dict = {
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

			prefabMesher.decodeData(dict)
			camera.look_at(Vector3(0, 0, 0))
			prefabMesher.global_position = -prefabMesher.getCenteringOffset()

			await RenderingServer.frame_post_draw
			newPrefab.emit(1, prefabMesher.getStringName(), dict, ImageTexture.create_from_image(subViewport.get_texture().get_image()))

		rightHeightIndex += 1
		if rightHeightIndex >= rightHeightRange.size():
			rightHeightIndex = 0
			leftHeightIndex += 1
		if leftHeightIndex >= leftHeightRange.size():
			leftHeightIndex = 0
			endWallIndex += 1
		if endWallIndex >= endWallRange.size():
			endWallIndex = 0
			startWallIndex += 1
		if startWallIndex >= startWallRange.size():
			startWallIndex = 0
			curveSidewaysIndex += 1
		if curveSidewaysIndex >= curveSidewaysRange.size(): # || curveIndex == 1:
			curveSidewaysIndex = 0
			curveForwardIndex += 1
		if curveForwardIndex >= curveForwardRange.size(): # || curveIndex == 1:
			curveForwardIndex = 0
			print("done")
			done.emit()
			queue_free()
			visible = false


