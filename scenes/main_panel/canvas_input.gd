@tool
extends Control

@export var snap_grid: int = 5

signal mouse_down(pt, button, event)
signal mouse_up(pt, button, event)
signal mouse_move(pt)

# Current tool in use
var tool = null


# Called when the node enters the scene tree for the first time.
func _ready():
  pass

func _gui_input(event):
  if FS.tool == null:	return

  if event is InputEventMouseButton:
    var logical_pt = to_logical(event.position)
    FS.tool.handle_mouse_click(logical_pt, event)

  elif event is InputEventMouseMotion:
    var logical_pt = to_logical(event.position)
    FS.tool.handle_mouse_move(logical_pt, event)


func get_sprite_size():
  if FS.model != null:
    return FS.model.size
  else:
    return 128


func to_logical(screen_pt):
  # How big in pixels is our sprite?
  var sprite_size = get_sprite_size()
  var half_size = sprite_size / 2.0
  # Convert to 0.0 -> sprite_size
  var logical_pt = screen_pt * sprite_size / get_size()
  # Now center
  logical_pt = logical_pt - Vector2(sprite_size / 2.0, sprite_size / 2.0)
  # And bound to our total canvas size
  logical_pt = logical_pt.clamp(Vector2(-half_size, -half_size), Vector2(half_size, half_size))
  return logical_pt


func snap(logical_pt):
  pass


#func set_native_scale():
#	var size = get_size()
#	draw_set_transform(size / 2, 0, Vector2.ONE)
#
#func set_model_scale():
#	var size = get_size()
#	draw_set_transform(size / 2, 0, Vector2.ONE)
