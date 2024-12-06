## Represents a texture in a sprite, i.e. the collection of layers from each
## component, rendered down into a PNG.  Does not own data!  Acts as a facade
## over the various components + layers in the main model.
@tool
class_name FSTexture extends RefCounted

# Our owning model
var model : FSModel

# What type of texture we are
var type : FS.Channel

# Layers in this texture's channel, cached, owned by components
var layers : Array

# Where to save/load this texture
var file_path

# Possibly helpful code snippet for once we're trying to dynamically
# update preview after save...
#var tex = $SubViewport.get_texture()
#level_image.texture_normal = tex
#tex.get_image().save_png(singleton.capture_path + ".png")


# Constructor
func _init(parent : FSModel, new_type = 0, new_path = ''):
  model = parent
  type = new_type
  file_path = new_path
  set_layers([])


func set_layers(list : Array):
  layers = list


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
      if closest == null || FSPoint.distance(pt, test_pt) < FSPoint.distance(pt, closest):
        closest = test_pt
  return closest


func closest_line(pt):
  var closest = null
  for layer in layers:
    # Find closes point on a line
    var test_pt = layer.closest_line(pt)
    if test_pt != null:
      # See if it's the new best option
      if closest == null || FSPoint.distance(pt, test_pt) < FSPoint.distance(pt, closest):
        closest = test_pt
  return closest


func render(canvas: RenderCanvas):
  # Invert order for proper z-order
  for i in range(layers.size()-1, -1, -1):
    var layer = layers[i]
    layer.render(canvas)


# Helpers for cleaner code
func is_diffuse():
  return type == FS.Channel.DIFFUSE
func is_normal():
  return type == FS.Channel.NORMAL
func is_emissive():
  return type == FS.Channel.EMISSIVE
