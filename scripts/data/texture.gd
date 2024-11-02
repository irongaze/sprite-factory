## Represents a texture in a sprite, i.e. the collection of layers from each
## component, rendered down into a PNG.  Does not own data!  Acts as a facade
## over the various components + layers in the main model.
@tool
class_name FSTexture extends RefCounted

# Our owning model
var model : FSModel

# What type of texture we are
var type : FS.Channel

# Layers in this channel
var layers : Array[FSLayer]

# Where to save/load this texture
var file_path

# Constructor
func _init(new_model: FSModel, new_type = 0, new_path = ''):
  model = new_model
  type = new_type
  file_path = new_path
  layers = []

func hit_test(pt):
  # Run layers from top to bottom
  for i in range(layers.size()-1, -1, -1):
    var layer = layers[i]
    var found = layer.hit_test(pt)
    if found != null: return found
  return null

func closest_point(pt):
  var closest = null
  for layer in layers:
    # Find closes point
    var test_pt = layer.closest_point(pt)
    if test_pt != null:
      # See if it's the new best option
      if closest == null || SpritePoint.distance(pt, test_pt) < SpritePoint.distance(pt, closest):
        closest = test_pt
  return closest

func closest_line(pt):
  var closest = null
  for layer in layers:
    # Find closes point on a line
    var test_pt = layer.closest_line(pt)
    if test_pt != null:
      # See if it's the new best option
      if closest == null || SpritePoint.distance(pt, test_pt) < SpritePoint.distance(pt, closest):
        closest = test_pt
  return closest

func load(data):
  # Load up and instantiate our layers
  var layers_list = data.get('layers', [])
  for layer_data in layers_list:
    var layer = FSLayer.new(self)
    layer.load(layer_data)
    layers.append(layer)

func save():
  # Build our data hash
  var data = {}

  # Add in our layer info
  data.layers = []
  for layer in layers:
    data.layers.append(layer.save())

  # And return it!
  return data

func render(canvas: RenderCanvas):
  for i in range(layers.size()-1, -1, -1):
    var layer = layers[i]
    layer.render(canvas)

func delete_layer(layer: SpriteLayer):
  layers.remove_at(layers.find(layer))

# Helpers for cleaner code
func is_diffuse():
  return type == FS.Channel.DIFFUSE
func is_normal():
  return type == FS.Channel.NORMAL
func is_emissive():
  return type == FS.Channel.EMISSIVE