@tool
class_name RenderCanvas extends Control

# Color to paint background, used when doing layer thumbnails etc
@export var bg_color := Color.TRANSPARENT

# When true, renders hidden layers (useful in thumbnails)
@export var show_hidden := false

# When true, renders hidden layers (useful in thumbnails)
@export var show_selection := false

# What we're rendering (texture, layer, shape, etc)
var renderable = null
#var opacity = 0.5

# Is this a thumbnail/canvas in editor, or for export as a png?
var is_export = false

func _process(delta):
  queue_redraw()

func set_renderable(new_renderable):
  renderable = new_renderable

func get_canvas_size():
  return float(get_size().x)

func get_sprite_size():
  var model = FS.model
  if model:
    return float(model.size)
  else:
    return 128.0

func get_render_scale():
  return get_canvas_size() / get_sprite_size()

# Custom draw function
func _draw():
  # Do we need to fill the background?
  if bg_color != null && bg_color.a > 0:
    reset_transform()
    draw_rect(Rect2(Vector2.ZERO, get_size()), bg_color, true)

  if FS.model:
    # Prep for drawing by putting 0,0 at the center of the control and
    # scaling to match our model's pixel dimensions
    set_transform()

    # Can't render if there's nothing TO render...
    if renderable:
      renderable.render(self)

func reset_transform():
  # Reset to origin at top-left, scale = 1.0
  draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

func set_transform(mirrored = false):
  # Set transform to have origin in middle of control, with
  # scale set so that the edge of the sprite is at the edge of the control.
  var cur_scale = get_render_scale()
  var xscale = -cur_scale if mirrored else cur_scale
  draw_set_transform(get_size() / 2, 0, Vector2(xscale, cur_scale))

#func with_native_scale(fn: Callable):
#	var transform = get_transform()
#	draw_set_transform(get_size() / 2, 0, Vector2.ONE)
#	fn.call()
#	draw_set_transform_matrix(transform)
