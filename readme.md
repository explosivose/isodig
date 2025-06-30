# isometric digging

## first poc goals

- view controls
  - move up and down layers
  - move center x/y
- edit controls
  - add block to layer
  - remove block from layer


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

We see a layer and it's surrounds. There's a quick UI for going up or down to neighbouring layers. It could be clipped to a square, beyond which the vertical faces could be seen (like the edge of a RCT map). The view square could have a UI for changing the size.

### Vertical corner slice

Like taking a quarter of a layer cake and seeing all the layers inside. This view is for visualising verticalities and connections between layers.

### X-ray cube

Similar to the vertical corner slice by way of having  solid a xyz back plane. The difference is that in the volume of the fore-cube we also show the intersecting tunnels. 

For example, showing all floors and walls with transparency within the volume.
