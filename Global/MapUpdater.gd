extends Node
class_name MapUpdater



# def fixFormat(readData, filename):
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
#         print("Fixing map", filename)

#         jsonData = json.loads(readData)

#         newProps = []
	var newProps = []

#         if (jsonData.get('props') == None) or (jsonData['format'] == 2):
#                 return
	if !jsonData.has('props'): # || jsonData['format'] == 2:
		return


#         jsonData['format'] = 2
	jsonData['format'] = 2


#         for prop in jsonData['props']:
	for prop in jsonData['props']:
#                 newProp = prop
		var newProp = prop
#                 if newProp.get('textureIndex') == None:
		if !newProp.has('textureIndex'):
#                         print(newProp)
#                         return
			return

#                 newProp['textureName'] = mappings[int(newProp['textureIndex'])]
		newProp['textureName'] = mappings[str(newProp['textureIndex']).to_int()]
#                 newProp.pop('textureIndex')
		newProp.erase('textureIndex')

#                 newProps.append(newProp)
		newProps.append(newProp)

#         jsonData['props'] = newProps
	jsonData['props'] = newProps

#         with open(filename, 'w') as f:
#                 f.write(json.dumps(jsonData))
	var fileHandler = FileAccess.open(fileName, FileAccess.READ)
	
	fileHandler.store_string(JSON.stringify(jsonData, "\t"))

	fileHandler.close()