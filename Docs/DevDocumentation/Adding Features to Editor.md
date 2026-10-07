- [Checklist](#checklist)
	- [Scene for visuals](#scene-for-visuals)
	- [Scene for editor and in-game functionality](#scene-for-editor-and-in-game-functionality)
	- [EditorEventListener.gd](#editoreventlistenergd)
	- [InteractiveMap.gd](#interactivemapgd)
	- [UI](#ui)

## Checklist

### Scene for visuals
- [ ] `@tool` script on root
- [ ] exposed script parameters control the mesh (this is for testing)
- named `Procedural<whatever>`

```python
func getProperties() -> Dictionary:
	return {
		"<param>": <param>,

		"position": global_position,
		"rotation": global_rotation,
	}
```
```python
func setProperties(properties: Dictionary) -> void:
	if properties.has("<param>"):
		<param> = properties["<param>"]
	
	if properties.has("position"):
		global_position = properties["position"]
	if properties.has("rotation"):
		global_rotation = properties["rotation"]
```
```python
func convertToPhysicsObject() -> void:
	<mesh>.create_trimesh_collision()
	<mesh>.setPhysicsMaterial(PhysicsSurface.SurfaceType.ROAD)
```
- `<mesh>` has type `PhysicsSurface extends MeshInstance3D`

- (optional) `@onready var arrow: Node3D = %Arrow` for directional elements

### Scene for editor and in-game functionality
- [ ] `@tool` script on root
- [ ] exposed same parameters that control the mesh

```python
@export
var isPreview: bool = false:
	set(newValue):
	...
```
- used to disable collision on the mouse preview


```python
@export_range(<range>)
var <param>: float = 1.0:
	set(newValue):
		<param> = newValue
		<proceduralMesh>.<param> = newValue
		setCollisionShape() # for the area trigger
```
```python
func getProperties() -> Dictionary:
	return {
		"<param>": <param>,
		...
		"position": global_position,
		"rotation": global_rotation,
	}
```
```python
func setProperties(properties: Dictionary, setTransform: bool = true) -> void:
	if properties.has("<param>"):
		<param> = properties["<param>"]
	...
	if setTransform:
		if properties.has("position"):
			global_position = properties["position"]
		if properties.has("rotation"):
			global_rotation = properties["rotation"]
```
```python
func importData(data: Dictionary):
	global_position = str_to_var(data["position"])
	global_rotation = str_to_var(data["rotation"])
	id = data["id"]
	...
```

```python
func getExportData() -> Dictionary:
	var data = {
		"position": var_to_str(global_position),
		"rotation": var_to_str(global_rotation),
		"id": id,
	}

	if <param> != <default>:
		data["<param>"] = <param>
	
	return data
```

```python
func setIngame(ingame: bool = true) -> void:
	%Collider.use_collision = !ingame
	%Arrow.visible = !ingame
	... # look at other element implementations
```

### EditorEventListener.gd

- `inputHandler.placePressed.connect()`
```python
elif currentEditorMode == EditorMode.BUILD:
	elif ClassFunctions.getClassName(currentElement) == "<element>":
		map.add<element>(
			<element>Scene.instantiate(),
			currentElement.global_position, 
			currentElement.global_rotation,
			currentElement.getProperties() # or <element>PropertiesUI.getProperties()
		)
		editorStats.increasePlacedProps()
```
- place down the element
- requires corresponding implementation in `map`

```python
elif currentEditorMode == EditorMode.EDIT:
	if currentElement != null && \
		(ClassFunctions.getClassName(currentElement) == "FunctionalStartLine" || \
			...
			ClassFunctions.getClassName(currentElement) == "<element>" || \
			ClassFunctions.getClassName(currentElement) == "PrismShapeDeco"):
		currentElement.convertToPhysicsObject()
```
- apply changes to previously editet element
  
```python
elif ClassFunctions.getClassName(collidedObject) == "<element>":
	currentElement = collidedObject
	<element>PropertiesUI.setProperties(collidedObject.getProperties())
	setEditUIVisibility(EditUIType.<ELEMENT_PROPERTIES)
	rotator.enable()
	rotator.moveToNode(currentElement)
	translator.enable()
	translator.global_position = currentElement.global_position
	setGizmoScale(camera.global_position)
```
- requires UI implementation
- requires `EditUIType.` enum

```python
elif currentEditorMode == EditorMode.DELETE:
	elif ClassFunctions.getClassName(collidedObject) == "<element>":
			map.remove<element>(collidedObject)
```

---

add to:
```python
rotator.rotationChanged.connect(func(newRotation: Vector3):
	elif ClassFunctions.getClassName(currentElement) == "<element>":
		<element>PropertiesUI.setProperties(currentElement.getProperties())
)
```
```python
translator.positionChanged.connect(func(newPos: Vector3):
	elif ClassFunctions.getClassName(currentElement) == "<element>":
		<element>PropertiesUI.setProperties(currentElement.getProperties())
)
```
```python
editorSidebarUI.editorModeChanged.connect(func(mode: EditorMode):
	if ClassFunctions.getClassName(currentElement) == "<element>":
		currentElement.convertToPhysicsObject()
	
	var <element>Properties = <element>PropertiesUI.getProperties()
		<element>Properties.erase("position")
		<element>Properties.erase("rotation")
		<element>.setProperties(<element>Properties)
)
```

---

Connect UI changes to element changes:

```python
# <element> properties ui
<element>PropertiesUI.<param>Changed.connect(func(<param>: Type):
	if currentElement == null || ClassFunctions.getClassName(currentElement) != "<element>":
		return
		
	currentElement = currentElement as <element>
	currentElement.<param> = <param>
)
```

---

Set UI Layer

```python
enum EditUIType {
	...
	# add <ELEMENT>_PROPERTIES here
	NONE,
}

func setEditUIVisibility(ui: EditUIType):
	# add <element>PropertiesUI.visible = ui == EditUIType.<ELEMENT>_PROPERTIES
	...

func setCurrentElement():
	if currentEditorMode == EditorMode.BUILD:
		<element>Preview.visible = currentBuildMode == BuildMode.<ELEMENT>
		# this is the preview element; no collision

		elif currentBuildMode == BuildMode.<ELEMENT>:
			currentElement = <element>Preview
		
		...

		<element>Preview.visible = currentEditorMode == EditorMode.BUILD
```

### InteractiveMap.gd

- [ ] add parent node

```python
func add<element>(node: <element>, position: Vector3, rotation: Vector3, properties: Dictionary):
	<elementParent>.add_child(node)
	node.global_position = position
	node.global_rotation = rotation
	node.setProperties(properties, false)
```
```python
func remove<element>(node: <element>):
	node.queue_free()
```
```python
func clearMap():
	# either deco subChild
	# or proper prent node
	# Clear here
```

---

```python
func exportTrack(autosave: bool = false, resetValidate: bool = true) -> bool:
	...
	if <element>.get_child_count() > 0:
		trackData["deco"]["<element>"] = []
		for node in <element>.get_children():
			trackData["deco"]["<element>"].append(node.getExportData())
```
```python
func importTrack(fileName: String) -> bool:
	...
	if trackData["deco"].has("<element>"):
		for <element>Data in trackData["deco"]["<element>"]:
			var <element>: <element>Type = <element>Scene.instantiate() as <element>Type
			if <element>Data.has("<param>"):
				var <param>: Type = str_to_var(<element>Data["<param>"])
				<element>Data["<param>"] = <param>
				
			add<element>(
				light,
				str_to_var(<element>Data["position"]),
				str_to_var(<element>Data["rotation"]),
				<element>Data
			)

```
```python
func setIngame(ingame: bool = true) -> void:
	...
	for child in <elements>.get_children():
		child.setIngame(ingame)
```

### UI

```python
extends Control
class_name <element>PropertiesUI

# UI elements
@onready var mainContainer: PanelContainer = %MainContainer

@onready var <param>Spinbox: SpinBox = %<param>Spinbox
@onready var <param>Toggle: CheckButton = %<param>Toggle

@onready var posXSpinbox: SpinBox = %PosXSpinbox
@onready var posYSpinbox: SpinBox = %PosYSpinbox
@onready var posZSpinbox: SpinBox = %PosZSpinbox
...
@onready var rotXSpinbox: SpinBox = %RotXSpinbox
@onready var rotYSpinbox: SpinBox = %RotYSpinbox
@onready var rotZSpinbox: SpinBox = %RotZSpinbox

# show hide the UI panel
@onready var visibilityButton: Button = %VisibilityButton
```
```python
# out signals
signal <param>Changed(<param>: Type)
...
signal positionChanged(position: Vector3)
signal rotationChanged(rotation: Vector3)
```
```python
# in setters
func set<element>(new<element>: float) -> void:
	<element>Spinbox.set_value_no_signal(new<element>)

func set<element>(new<element>: bool) -> void:
	<element>Toggle.button_pressed = new<element>
...
func setPosition(newPosition: Vector3) -> void:
	posXSpinbox.set_value_no_signal(newPosition.x)
	posYSpinbox.set_value_no_signal(newPosition.y)
	posZSpinbox.set_value_no_signal(newPosition.z)

func setRotation(newRotation: Vector3) -> void:
	rotXSpinbox.set_value_no_signal(newRotation.x)
	rotYSpinbox.set_value_no_signal(newRotation.y)
	rotZSpinbox.set_value_no_signal(newRotation.z)
```
```python
func _ready():
	rotXSpinbox.step = deg_to_rad(5)
	rotYSpinbox.step = deg_to_rad(5)
	rotZSpinbox.step = deg_to_rad(5)

	rotXSpinbox.custom_arrow_step = deg_to_rad(5)
	rotYSpinbox.custom_arrow_step = deg_to_rad(5)
	rotZSpinbox.custom_arrow_step = deg_to_rad(5)

	connectSignals()
```

connect signals
```python
func connectSignals():
	<param>Spinbox.value_changed.connect(func(value: float):
		<param>Changed.emit(value)
	)
	...
	posXSpinbox.value_changed.connect(func(value: float):
		positionChanged.emit(Vector3(value, posYSpinbox.value, posZSpinbox.value))
	)

	posYSpinbox.value_changed.connect(func(value: float):
		positionChanged.emit(Vector3(posXSpinbox.value, value, posZSpinbox.value))
	)

	posZSpinbox.value_changed.connect(func(value: float):
		positionChanged.emit(Vector3(posXSpinbox.value, posYSpinbox.value, value))
	)

	rotXSpinbox.value_changed.connect(func(value: float):
		rotationChanged.emit(Vector3(value, rotYSpinbox.value, rotZSpinbox.value))
	)

	rotYSpinbox.value_changed.connect(func(value: float):
		rotationChanged.emit(Vector3(rotXSpinbox.value, value, rotZSpinbox.value))
	)

	rotZSpinbox.value_changed.connect(func(value: float):
		rotationChanged.emit(Vector3(rotXSpinbox.value, rotYSpinbox.value, value))
	)
```

---

Save/Lod

```python
func getProperties() -> Dictionary:
	var properties := {
		"sides": sideSpinbox.value,
		...
		"position": Vector3(posXSpinbox.value, posYSpinbox.value, posZSpinbox.value),
		"rotation": Vector3(rotXSpinbox.value, rotYSpinbox.value, rotZSpinbox.value)
	}
	...
	return properties

func setProperties(properties: Dictionary) -> void:
	if properties.has("<param>"):
		set<param>(properties["<param>"])
	...
	if properties.has("position"):
		setPosition(properties["position"])
	if properties.has("rotation"):
		setRotation(properties["rotation"])
```