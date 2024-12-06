@tool
extends FSTool

# Drawing state
var cur_shape: FSShape
var cur_point: FSPoint

func _is_available():
  # We're available when there's a layer selected
  return FS.layer != null

func _on_mouse_click(pt, index, down):
  if down: print('clicked')
  # Get the active layer and ensure it exists
  if !FS.layer:
    if down: print('no layer to select on')
    return

  if index == 1:
    if down:
      # Find the shape under the cursor, if any
      var shape = FS.layer.hit_test(pt)

    else:
      # Mouse up?  Stop editing this point
      pass

  if index == 2:
    pass

func _on_mouse_move(pt):
  pass
