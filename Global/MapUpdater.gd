extends Node
class_name MapUpdater



static func updateMap(jsonData, fileName: String) -> void:
	var mappings = {
		0: 'BumpyRoadOld',
		1: 'ChicaneLeftOld',
		2: 'ChicaneRightOld',
		3: 'SharpLeftOld',
		4: 'SharpRightOld',
		5: 'TheChampion',
		-2: 'Custom'
	}
	var newProps = []

	if !jsonData.has('props'): # || jsonData['format'] == 2:
		# return
		jsonData['props'] = []

	jsonData['format'] = 2


	for prop in jsonData['props']:
		var newProp = prop
		# if !newProp.has('textureIndex'):
		# 	return

		newProp['textureName'] = mappings[str(newProp['textureIndex']).to_int()]
		newProp.erase('textureIndex')

		newProps.append(newProp)

	jsonData['props'] = newProps

	if jsonData["format"] == 2:
		# var validated: bool = false
		# var bestTotalTime: int = -1
		# var bestTotalReplay: String = ""
		# var bestLapTime: int = -1
		# var bestLapReplay: String = ""
		jsonData["format"] = 3
		jsonData["validated"] = false
		jsonData["bestTotalTime"] = -1
		jsonData["bestTotalReplay"] = ""
		jsonData["bestLapTime"] = -1
		jsonData["bestLapReplay"] = ""
		
	var fileHandler = FileAccess.open(fileName, FileAccess.WRITE)

	if fileHandler == null:
		print("Map update failed: ", fileHandler.get_open_error())
		return
	
	fileHandler.store_string(JSON.stringify(jsonData, "\t"))

	fileHandler.close()
