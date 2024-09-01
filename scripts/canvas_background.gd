@tool
extends Control

# Remember the last settings we drew, redraw if they change
var cur_snap_spacing = -1
var cur_sprite_size = -1

func _ready():
  SpriteFactorySettings.changed.connect(check_for_change)
  SpriteEditor.model_changed.connect(func(model): check_for_change())

# Request a draw (needed since we're a control)
func check_for_change():
  var snap_spacing = get_snap_spacing()
  var sprite_size = get_sprite_size()
  if snap_spacing != cur_snap_spacing || sprite_size != cur_sprite_size:
    queue_redraw()

# Pixel snap distance, eventually get from editor/UI
func get_snap_spacing():
  return SpriteFactorySettings.grid_size

func get_sprite_size():
  if SpriteEditor.model:
    return SpriteEditor.model.size
  else:
    return 128

# Custom draw function
func _draw():
  # Remember what we're drawing
  cur_sprite_size = get_sprite_size()
  cur_snap_spacing = get_snap_spacing()

  # Prep for drawing by putting 0,0 at the center of the control
  var size = get_size()
  draw_set_transform(size / 2, 0, Vector2.ONE)

  # Draw our grid
  draw_helpers()

func draw_helpers():
  # Setup
  var size = get_size().x
  var scale = size / get_sprite_size()
  var half = size / 2.0

  # Fill background
  draw_rect(Rect2(-half,-half,size,size), Color.BLACK, true)

  # Draw main axes
  var color = Color('222')
  draw_line(Vector2(0,-half), Vector2(0,half), color, 1.0)
  draw_line(Vector2(-half,0), Vector2(half,0), color, 1.0)

  # Draw snap grid
  color = Color('111')
  var x = cur_snap_spacing * scale
  while x < half:
    draw_line(Vector2(x,-half), Vector2(x,half), color, 1.0)
    draw_line(Vector2(-x,-half), Vector2(-x,half), color, 1.0)
    x += cur_snap_spacing * scale
  var y = cur_snap_spacing * scale
  while y < half:
    draw_line(Vector2(-half,y), Vector2(half,y), color, 1.0)
    draw_line(Vector2(-half,-y), Vector2(half,-y), color, 1.0)
    y += cur_snap_spacing * scale
