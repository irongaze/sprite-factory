## Base class for our various tools - draw, modify, etc.
@tool
class_name FSTool extends Button

# Initialize our state
func _ready():
  # Handle being pressed
  pressed.connect(on_pressed)

  # Tie into our various editor signals
  FS.model_changed.connect(on_model_changed)
  #FS.component_changed.connect(on_component_changed)
  #FS.tool_changed.connect(on_tool_changed)

  # Do an initial UI refresh
  update_ui()

# Override to handle the given events
func _on_model_changed(): pass
func _on_component_changed(): pass
#func _on_selection_changed(): pass
func _on_tool_changed(): pass
func _on_any_changed(): pass

# Override to handle UI events
func _on_mouse_click(pt, index, down): pass
func _on_mouse_move(pt): pass
func _on_key(code, down):	pass

# Override to be smarter about availability
func _is_available():	return FS.model != null


func activate():
  pass

func deactivate():
  pass

func on_pressed():
  if _is_available():
    FS.editor.select_tool(self)

# Dispatch callbacks & update UI
func on_model_changed():
  _on_model_changed()
  _on_any_changed()
  update_ui()

# Dispatch callbacks & update UI
func on_component_changed():
  _on_component_changed()
  _on_any_changed()
  update_ui()

## Dispatch callbacks & update UI
#func on_selection_changed():
  #_on_selection_changed()
  #_on_any_changed()
  #update_ui()

# Dispatch callbacks & update UI
func on_tool_changed():
  _on_tool_changed()
  _on_any_changed()
  update_ui()


## Snap a logical point to other points, lines and the grid.  Respects
## the state of the associated buttons, and allows override with SHIFT key.
func snap_pt(pt):
  # Setup
  var test_pt
  var snap_pt
  var snap_dist = 2.5
  var sprite_size = FS.model.size
  var half_size = sprite_size / 2.0

  # If shift is held down, never snap
  if Input.is_key_pressed(KEY_SHIFT):
    snap_pt = pt

  # First try snapping to a point
  if FSEditor.snap_point && snap_pt == null:
    var sprite_pt = FSEditor.closest_point(pt)
    if sprite_pt != null && FSPoint.distance(pt, sprite_pt) <= snap_dist:
      snap_pt = sprite_pt.to_vector()

  # Next, see if we can snap to a line
  if FSEditor.snap_line && snap_pt == null:
    test_pt = FSEditor.closest_line(pt)
    if test_pt != null && FSPoint.distance(pt, test_pt) <= snap_dist:
      snap_pt = test_pt

  # Finally, snap to grid or keep original
  if snap_pt == null:
    if FSEditor.snap_grid:
      # Snap to grid
      var grid = FSSettings.grid_size
      snap_pt = Vector2(roundf(pt.x / grid) * grid, roundf(pt.y / grid) * grid)

    # No snap? Keep the original point
    else:
      snap_pt = pt

  # Bound & return point
  var x_max = 0 if FS.component.mirror else half_size
  snap_pt = snap_pt.clamp(Vector2(-half_size, -half_size), Vector2(x_max, half_size))
  return snap_pt


# Called by canvas input with UI events
func handle_mouse_click(logical_pt: Vector2, event: InputEventMouseButton):
  _on_mouse_click(logical_pt, event.button_index, event.pressed)


# Called by canvas input with UI events
func handle_mouse_move(logical_pt: Vector2, event: InputEventMouseMotion):
  _on_mouse_move(logical_pt)


func update_ui():
  disabled = FS.model == null || !_is_available()
  button_pressed = FS.tool == self
