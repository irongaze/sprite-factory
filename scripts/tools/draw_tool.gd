@tool
extends SpriteTool

# Drawing state
var cur_shape: SpriteShape
var cur_point: SpritePoint

func get_layer():
  return SpriteEditor.layer

func end():
  # No-op if not currently drawing
  if cur_shape == null: return
  # De-select our shape
  SpriteEditor.selection.remove(cur_shape)
  # Auto-delete it if not enough points to show
  if cur_shape.points.size() < 3:
    cur_shape.layer.remove_shape(cur_shape)
  # And finally reset our internal state
  cur_shape = null
  cur_point = null

func _is_available():
  # We're available when there's a single non-locked layer selected
  var layer = get_layer()
  return layer != null && !layer.hidden && !layer.locked

# Override to end drawing if anything changes - selection, model, etc.
func _on_any_changed():
  end()

# Handle a click on the main canvas, implements drawing
func _on_mouse_click(pt, index, down):
  # Get the active layer and ensure it exists
  var layer = get_layer()
  if !layer: return

  if index == 1:
    var snap_pt = snap_pt(pt)
    if down:
      # Start shape if needed and add a new point
      if !cur_shape:
        cur_shape = layer.add_shape()
        SpriteEditor.selection.set_to(cur_shape)
      cur_point = cur_shape.add_point(snap_pt)

    else:
      # Mouse up?  Stop editing this point
      cur_point.update(snap_pt)
      cur_point = null

    # No matter what, model has changed
    SpriteEditor.fire_model_changed()

  if index == 2:
    # Right-click to close shape
    end()

# Handle mouse movement on the main canvas
func _on_mouse_move(pt):
  if cur_point:
    var snap_pt = snap_pt(pt)
    cur_point.update(snap_pt)
    SpriteEditor.fire_model_changed()
