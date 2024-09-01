# Stores the editing data for a sprite, modified by the editor, saved
# to disk as a resource
@tool
class_name SpriteModel extends RefCounted

# Call with a Sprite node to get the model we
# can use to edit it's look
static func from(sprite):
  assert(sprite != null)
  var model = SpriteModel.new(sprite)
  return model

# Sprite we're editing
var sprite: Sprite

# Size in PX
var size: int

# 3 textures
var diffuse: SpriteTexture
var normal: SpriteTexture
var emissive: SpriteTexture

func _init(new_sprite: Sprite):
  # Capture the sprite
  assert(new_sprite != null)
  sprite = new_sprite

  # Set up our textures
  var tex_path = sprite.scene_file_path.replace('.tscn', '')
  diffuse = SpriteTexture.new(self, Sprite.Channel.DIFFUSE, tex_path + '.png')
  normal = SpriteTexture.new(self, Sprite.Channel.NORMAL, tex_path + '-n.png')
  emissive = SpriteTexture.new(self, Sprite.Channel.EMISSIVE, tex_path + '-glow.png')

  # Load up our textures!
  load_all()

# Get the texture resource of the given type
func get_texture(type: Sprite.Channel):
  match type:
    Sprite.Channel.DIFFUSE: return diffuse
    Sprite.Channel.NORMAL: return normal
    Sprite.Channel.EMISSIVE: return emissive

# True if this model uses the given channel (currently means "has layers")
func export_texture(type: Sprite.Channel):
  return get_texture(type).layers.size() > 0

# Load the image from disk and return as a texture
func load_texture_image(type: Sprite.Channel):
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
