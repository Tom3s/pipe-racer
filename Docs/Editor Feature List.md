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

## functional

- start line
  - current
  - circular
  - rally type
- checkpoints
  - current 
  - current, but only top half 
  - similar to finish line
  - rally type

## Scenery

- Terraformable heightmap
- colorable texture for road
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
- waterfalls
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
- simple shapes with custom textures


## notes from other games

![alt text](pictures/revolt-museum2.png)
- glass bridges (glass surface, guard rails, no support, water under)

![alt text](pictures/revolt-museum2-2.png)
- bridge inside pipe

![alt text](<pictures/revolt-toyworld (1).png>)
- animals 

![alt text](<pictures/revolt-toyworld (2).png>)
- wide/narrow roads

![alt text](<pictures/lego-racers (1).png>)
- road with guard rails, vehicle props, simple shapes in sky

![alt text](<pictures/lego-racers (2).png>)
- briddge inside pipe + lava + poles

![alt text](<pictures/lego-racers (3).png>)
- large pipe as cave, road with runoff, simple pipes/shapes as support

![alt text](<pictures/lego-racers (4).png>)
- support on side, insie pipe as tunnel, waterfall, etc.

![alt text](<pictures/lego-racers (5).png>)
- pillars, simple shapes, road with walls

![alt text](<pictures/lego-racers (6).png>)
- road with fence, pillars, simple shapes, lava
  
![alt text](<pictures/lego-racers-2 (1).png>)
- terraformed surface, wallride should be possible with prefab

![alt text](<pictures/lego-racers-2 (3).png>)
- pipe as tunnel, road with walls, shapes for crystals

![alt text](<pictures/lego-racers-2 (4).png>)
- tunnel etc + waterfall + water