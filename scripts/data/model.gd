## Stores the editing data for a sprite, modified by the editor, saved
## to the sprite node as attributes and a JSON hash.
@tool
class_name FSModel extends RefCounted

# Sprite we're editing
var sprite: FactorySprite

# Size in PX
var size: int

# Our list of components (which own our layers)
var components : Array[FSComponent]

# 3 textures, which slice our components
var diffuse : FSTexture
var normal : FSTexture
var emissive : FSTexture


# Call with a Sprite node to get the model we
# can use to edit it's look
static func from(sprite : FactorySprite):
  assert(sprite != null)
  var model = FSModel.new(sprite)
  return model


func _init(new_sprite : FactorySprite):
  # Capture the sprite
  assert(new_sprite != null)
  sprite = new_sprite

  # Set up our textures
  var tex_path = sprite.scene_file_path.replace('.tscn', '')
  diffuse = FSTexture.new(self, FS.Channel.DIFFUSE, tex_path + '.png')
  normal = FSTexture.new(self, FS.Channel.NORMAL, tex_path + '-n.png')
  emissive = FSTexture.new(self, FS.Channel.EMISSIVE, tex_path + '-glow.png')

  # Load up our textures!
  load_all()


# Get the texture of the given type
func get_texture(type : FS.Channel):
  match type:
    FS.Channel.DIFFUSE: return diffuse
    FS.Channel.NORMAL: return normal
    FS.Channel.EMISSIVE: return emissive


# Get all layers in the given channel
func get_layers(type : FS.Channel):
  var list = []
  for c in components:
    list.append(c.get_layer(type))
  return list


func update_textures():
  for ch in FS.Channel.values():
    var tex = get_texture(ch)
    tex.set_layers(get_layers(ch))


# True if this model uses the given channel
func uses_channel(ch : FS.Channel):
  for component in components:
    if component.get_layer(ch).shapes.size() > 0:
      return true
  return false


# Load the image from disk and return as a texture
func load_texture_image(type: FS.Channel):
  var tex = get_texture(type)
  var path = tex.file_path
  return load(path)


func load_all():
  # Get any data from our sprite
  size = sprite.size

  # Get our data from the sprite's JSON
  var data = {}
  print("loading model:")
  if sprite.model_json:
    print(sprite.model_json)
    data = JSON.parse_string(sprite.model_json)
  else: print('no json!')

  # Load up our components
  components = []
  var component_list = data.get('components', [])
  for component_data in component_list:
    # Load the component
    var component = FSComponent.new(self)
    component.load(component_data)
    # Add to our master list
    components.append(component)

  if components.size() == 0:
    components.append(FSComponent.new(self))

  # Update our textures since our components have changed
  update_textures()


func save_all():
  # Build our core data
  var data = {
    "size": size
  }

  # Add in our components
  var component_data = []
  for component in components:
    component_data.append(component.save())
  data.components = component_data

  # Convert from a hash to a JSON string
  var json = JSON.stringify(data)
  # And store it back in the node
  sprite.model_json = json
  print("saving model:")
  print(json)

  # Notify the inspector etc. that things have changed
  sprite.notify_property_list_changed()
