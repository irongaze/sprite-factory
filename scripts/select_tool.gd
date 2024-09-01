@tool
extends SpriteTool

# Drawing state
var cur_shape: SpriteShape
var cur_point: SpritePoint

func _is_available():
  # We're available when there's a layer selected
  return get_layer() != null

func _on_mouse_click(pt, index, down):
  if down: print('clicked')
  # Get the active layer and ensure it exists
  var layer = get_layer()
  if !layer:
    if down: print('no layer to select on')
    return

  if index == 1:
    if down:
      # Find the shape under the cursor, if any
      var shape = layer.hit_test(pt)

    else:
      # Mouse up?  Stop editing this point
      pass

  if index == 2:
    # Right-click to close shape
    SpriteEditor.selection.clear()

func _on_mouse_move(pt):
  pass
