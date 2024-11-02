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

# 3 textures
var diffuse: FSTexture
var normal: FSTexture
var emissive: FSTexture


# Call with a Sprite node to get the model we
# can use to edit it's look
static func from(sprite):
  assert(sprite != null)
  var model = FSModel.new(sprite)
  return model


func _init(new_sprite: FactorySprite):
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
func get_texture(type: FS.Channel):
  match type:
    FS.Channel.DIFFUSE: return diffuse
    FS.Channel.NORMAL: return normal
    FS.Channel.EMISSIVE: return emissive


# True if this model uses the given channel (currently means "has layers")
func export_texture(type: FS.Channel):
  return get_texture(type).layers.size() > 0


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

  # Load each texture
  diffuse.load(data.get('diffuse', {}))
  normal.load(data.get('normal', {}))
  emissive.load(data.get('emissive', {}))

func save_all():
  # Build our core data
  var data = {
    "size": size
  }

  # Save off each texture
  data.diffuse = diffuse.save()
  data.normal = normal.save()
  data.emissive = emissive.save()

  # Convert from a hash to a JSON string
  var json = JSON.stringify(data)
  # And store it back in the node
  sprite.model_json = json
  print("saving model:")
  print(json)

  # Notify the inspector etc. that things have changed
  sprite.notify_property_list_changed()
