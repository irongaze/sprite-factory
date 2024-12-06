## A logical part of a sprite, containing 3 layers, one for
## each channel.
@tool
class_name FSComponent extends RefCounted

# Parent
var model : FSModel

# The layers we own, hashed by channel
var layers : Dictionary

# Our layer name
var name : String

# Do we auto-mirror our shapes
var mirror := true
# Are we locked for editing
var locked := false
# Are we visible
var hidden := false


func _init(parent : FSModel):
  model = parent
  for channel in FS.Channel.values():
    layers[channel] = FSLayer.new(self, channel)


func get_layer(channel : FS.Channel):
  return layers[channel]


func is_selected():
  return FS.component == self


func calc_index():
  return model.components.find(self)


func load(data : Dictionary):
  # Get our core info
  name = data.get('name')
  mirror = data.get('mirror', true)
  locked = data.get('locked', false)
  hidden = data.get('hidden', false)

  # Load up our layers
  layers = {}
  var layer_list = data.get('layers', [])
  for layer_data in layer_list:
    # Load the layer
    var layer = FSLayer.new(self)
    layer.load(layer_data)
    # Add to our hash
    layers[layer.channel] = layer


func save():
  # Build our core data
  var data = {
    "name": name,
    "mirror": mirror,
    "locked": locked,
    "hidden": hidden,
  }

  # Add in our shape info
  var layer_data = []
  for ch in layers:
    var layer = layers[ch]
    layer_data.append(layer.save())
  data.layers = layer_data

  # And return it
  return data
