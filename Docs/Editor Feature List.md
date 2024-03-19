# Editor Revamp

## Prefabs

![alt text](pictures/prefab-generator.png)

- __<span style="color: #F00">Red</span>__: Road Profile / Connection Points
  - direction
  - slope (also in __<span style="color: #A0F">Purple</span>__)
  - tilt 
  - position
  - width
  - profile
    - straight
    - sausage
    - bowl
    - custom
- __<span style="color: #0F0">Green</span>__: Support Structure
  - type
    - solid
    - scaffold
    - pillars
    - none
  - material (texture)
- __<span style="color: #06F">Blue</span>__: Guard Rails / Wall
  - type
	- guard rail
	- wall
	- fence
	- none 
- __<span style="color: #FF0">Yellow</span>__: Runoff Area (extension)
  - on/off (each side)
  - size
  - profile
  - surface
- __<span style="color: #888">Gray</span>__: Surface
  - side smoothing (on/off)
  - type
    - road
    - dirt
    - grass
    - booster
    - _sand_
    - _ice_
    - _mud_
    - _glass_
- __Not shown__: Color

## Pipes

![alt text](pictures/pipe-generator.png)

- __<span style="color: #F00">Red</span>__: Profile
  - direction
  - slope 
  - tilt (also in __<span style="color: #A0F">Purple</span>__)
  - position
  - profile / openness (in degrees) (also in __<span style="color: #2F2">Green</span>__)
  - radius (also in __<span style="color: #06F">Blue</span>__)
- __<span style="color: #888">Black</span>__: Surface
  - side smoothing (on/off)
  - type
    - same as before
- __Not shown__: inside/outside pipe


## Scenery

- Terraformable heightmap
- Select surface type
- custom gradient color
- wheater
  - fog
  - rain / snow / sandstorm
  - wind
  - time of day 

## Deco

- Vegetation
  - trees
  - bushes
  - hedges
- Props
  - buildings (in parts)
  - signs
  - lights
  - fences
  - barriers
  - poles
  - traffic cones
  - barrels
  - crates
  - vehicles
- entities (static / animated)
  - animals
  - people
  - robots
  - monsters
- Structural
  - I-beams
  - Cables
  - Pipes
- Special
  - billboards (led screens) 

## Misc

- fluid containers
  - type
    - water
    - lava
    - acid
    - oil
    - mud
  - shape (prolly simple cuboid, maybe cillinder)
- particle emitters
  - type
	- smoke
	- fire
	- sparks
	- dust 
- maybe sound emitters
  - type
	- music
	- ambient
	- sfx
