@tool
extends FSTool

# Drawing state
var cur_shape: FSShape
var cur_point: FSPoint


func end():
  # No-op if not currently drawing
  if cur_shape == null: return

  # Auto-delete it if not enough points to show
  if cur_shape.points.size() < 3:
    cur_shape.layer.remove_shape(cur_shape)

  # And finally reset our internal state
  cur_shape = null
  cur_point = null


func _is_available():
  # We're available when there's a single non-locked layer selected
  return FS.layer != null && !FS.component.hidden && !FS.component.locked


# Override to end drawing if anything changes - selection, model, etc.
func _on_any_changed():
  end()


# Handle a click on the main canvas, implements drawing
func _on_mouse_click(pt, index, down):
  # Get the active layer and ensure it exists
  if !FS.layer: return

  if index == 1:
    var snap_pt = snap_pt(pt)
    if down:
      # Start shape if needed and add a new point
      if !cur_shape:
        cur_shape = FS.layer.add_shape()
        #FSEditor.selection.set_to(cur_shape)
      cur_point = cur_shape.add_point(snap_pt)

    else:
      # Mouse up?  Stop editing this point
      cur_point.update(snap_pt)
      cur_point = null

    # No matter what, model has changed
    FSEditor.fire_data_changed()

  if index == 2:
    # Right-click to close shape
    end()


# Handle mouse movement on the main canvas
func _on_mouse_move(pt):
  if cur_point:
    var snap_pt = snap_pt(pt)
    cur_point.update(snap_pt)
    FSEditor.fire_data_changed()
