@tool
extends Control

# Remember the last settings we drew, redraw if they change
var cur_model = null
var cur_snap_spacing = -1
var cur_sprite_size = -1

@onready var ui_font = ThemeDB.fallback_font
@onready var ui_font_size = ThemeDB.fallback_font_size


func _ready():
  FSSettings.changed.connect(check_for_change)
  FS.model_changed.connect(func(): model_changed())


func model_changed():
  if FS.model != cur_model:
    cur_model = FS.model
    queue_redraw()
  else:
    check_for_change()


# Request a draw (needed since we're a control)
func check_for_change():
  var snap_spacing = get_snap_spacing()
  var sprite_size = get_sprite_size()
  if snap_spacing != cur_snap_spacing || sprite_size != cur_sprite_size:
    queue_redraw()


# Pixel snap distance, eventually get from editor/UI
func get_snap_spacing():
  return max(FSSettings.grid_size, 2)


# What size in pixels is our current sprite?
func get_sprite_size():
  if FS.model:
    return FS.model.size
  else:
    return 128


# Override control drawing, called once and cached, only called on queue_redraw()
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

  # Gray ourselves out if we've got no selected model
  var line_fn = draw_line
  var bg_color = Color.BLACK
  if FS.model == null:
    line_fn = draw_dashed_line
    bg_color = Color(0.1,0.1,0.1,0.6)

  # Fill background
  draw_rect(Rect2(-half,-half,size,size), bg_color, true)

  # Draw snap grid
  var color = bg_color.lightened(0.075)
  var x = cur_snap_spacing * scale
  while x < half:
    line_fn.call(Vector2(x,-half), Vector2(x,half), color, 1.0)
    line_fn.call(Vector2(-x,-half), Vector2(-x,half), color, 1.0)
    x += cur_snap_spacing * scale
  var y = cur_snap_spacing * scale
  while y < half:
    line_fn.call(Vector2(-half,y), Vector2(half,y), color, 1.0)
    line_fn.call(Vector2(-half,-y), Vector2(half,-y), color, 1.0)
    y += cur_snap_spacing * scale

  # Draw main axes
  color = bg_color.lightened(0.125)
  line_fn.call(Vector2(0,-half), Vector2(0,half), color, 1.0)
  line_fn.call(Vector2(-half,0), Vector2(half,0), color, 1.0)

  if FS.model == null:
    var notice = "no sprite selected"
    var pos = ui_font.get_string_size(notice) / 2.0
    pos.x *= -1
    pos.y = 5
    draw_string(ui_font, pos, notice, HORIZONTAL_ALIGNMENT_CENTER, -1, ui_font_size, Color('444'))
