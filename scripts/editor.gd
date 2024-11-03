## Master class that manages editing process internals.  Implemented
## as a set of static state, functions, and signals.  Manages
## current selections.
@tool
class_name FSEditor extends RefCounted

# Signals - use FS.foo.connect instead, see there for comments
signal model_changed()
signal channel_changed()
signal component_changed()
signal data_changed()
signal ui_changed()

# UI State - move to FSSettings?
static var snap_point := true
static var snap_line := true
static var snap_grid := true


# Call to select a new model for editing
static func edit_model(new_model):
  # Reset our state
  selection.clear()
  select_layer(null)
  FS.model = new_model

  # Force a rebuild of the UI
  fire_model_changed()


static func save_model():
  if FS.model != null:
    FS.model.save_all()


static func select_tool(new_tool: SpriteTool):
  tool = new_tool
  SpriteEditor.tool_changed.emit(tool)


static func select_channel(new_channel: FS.Channel):
  # Reset our selection
  selection.clear()

  # Save new channel & emit!
  channel = new_channel

  # Auto-select top-most layer if none selected
  if model:
    var tex = model.get_texture(channel)
    var new_layer = null if tex.layers.size() == 0 else tex.layers.front()
    select_layer(new_layer)

  # Let folks know we're on a new channel
  SpriteEditor.channel_changed.emit(channel)


static func select_layer(new_layer: SpriteLayer):
  if new_layer != layer:
    layer = new_layer
    SpriteEditor.layer_changed.emit(layer)


static func fire_model_changed():
  save_model()
  SpriteEditor.model_changed.emit(model)


static func fire_selection_changed():
  SpriteEditor.selection_changed.emit()


static func hit_test(pt):
  if model == null: return null
  var texture = model.get_texture(channel)
  if texture == null:
    return null
  else:
    return texture.hit_test(pt)


static func closest_point(pt):
  if model == null: return null
  var closest = null
  for ch in FS.Channel.values():
    var tex = model.get_texture(ch)
    if tex != null:
      # Find closes point
      var test_pt = tex.closest_point(pt)
      if test_pt != null:
        # See if it's the new best option
        if closest == null || FSPoint.distance(pt, test_pt) < FSPoint.distance(pt, closest):
          closest = test_pt
  return closest


static func closest_line(pt):
  if model == null: return null
  var closest = null
  for ch in FS.Channel.values():
    var tex = model.get_texture(ch)
    if tex != null:
      # Find closes point to a line
      var test_pt = tex.closest_line(pt)
      if test_pt != null:
        # See if it's the new best option
        if closest == null || FSPoint.distance(pt, test_pt) < FSPoint.distance(pt, closest):
          closest = test_pt
  return closest
