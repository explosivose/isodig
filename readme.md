# isometric digging

## TODOs for poc

- add a view class which manage layer visibility
  - based on a center point
- add dig mode and fill mode
- add some dig and fill audio
- smooth movement
- add some 'budge' when cant move
- animate the character
- build for web, publish online

## first poc goals

- view controls
  - move up and down layers
  - move center x/y
- edit controls
  - add block to layer
  - remove block from layer

## next poc goals

- npc that moves from A to B
- npc that digs straight down to near-bottom, then digs a NxN cave
  - will redig if player fills it in
- build & publish

## voxel notes

Query return types:

- 3D arrays

Queries might look like:

- get_cube(pos, size)

### 3D array

Probably the simplest approach.

### Sparse voxel tree

Another memory efficient approach.

## rendering notes

The scene hierarchy could look like this:

- root
  - World
    - View
      - Layer
      - Layer
      - Layer

Where there are several views that each manage their TileMapLayers. The World node contains the voxel data and provides a query interface for the Views.

## View ideas

### Horizontal slice

We see a layer and it's surrounds. There's a quick UI for going up or down to neighboring layers. It could be clipped to a square, beyond which the vertical faces could be seen (like the edge of a RCT map). The view square could have a UI for changing the size.

There could also be a transparent preview for routes entering neighboring layers.

### Vertical corner slice

Like taking a quarter of a layer cake and seeing all the layers inside. This view is for visualising verticalities and connections between layers.

### X-ray cube

Similar to the vertical corner slice by way of having solid a xyz back plane. The difference is that in the volume of the fore-cube we also show the intersecting tunnels.

For example, showing all floors and walls with transparency within the volume.

### Reachable cubes

Show all cubes that I can walk to (if I were spiderman) inside a bounding box.

For occluding walls we could draw a transparent sprite of just the wall touching the empty cube.
