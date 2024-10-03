# Master class that manages editing process internals.  Implemented
# as a set of static state, functions, and signals.  Manages
# current selections.
@tool
class_name SpriteEditor extends RefCounted

# Singleton to hold our signals
static var instance = SpriteEditor.new()


# Signals

# When fired, the model's data has changed
signal _model_changed(model: SpriteModel)
static var model_changed: Signal:
  get: return instance._model_changed

# When fired, the selection has changed
signal _selection_changed()
static var selection_changed: Signal:
  get: return instance._selection_changed

# When fired, the selection has changed
signal _tool_changed(tool: SpriteTool)
static var tool_changed: Signal:
  get: return instance._tool_changed

# When fired, the channel we're working on has changed
signal _channel_changed(channel: FactorySprite.Channel)
static var channel_changed: Signal:
  get: return instance._channel_changed

# When fired, the layer we're working on has changed
signal _layer_changed(layer: SpriteLayer)
static var layer_changed: Signal:
  get: return instance._layer_changed

# When fired, a new color has been selected for the given channel
signal _color_changed(color: Color, channel: FactorySprite.Channel)
static var color_changed: Signal:
  get: return instance._color_changed

# When fired, the UI needs to update
signal _ui_changed()
static var ui_changed: Signal:
  get: return instance._ui_changed


# Current selections

# Sprite model we're editing
static var model: SpriteModel

# Which channel we're editing
static var channel := FactorySprite.Channel.DIFFUSE

# Currently selected layer
static var layer: SpriteLayer

# Currently selected tool
static var tool: SpriteTool

# Seleted elements
static var selection = SpriteSelection.new()

# UI State
static var snap_point := true
static var snap_line := true
static var snap_grid := true


# Call to select a new model for editing
static func edit_model(new_model):
  # Reset our state
  selection.clear()
  select_layer(null)
  model = new_model

  # Force a rebuild of the UI
  fire_model_changed()


static func save_model():
  if model != null:
    model.save_all()


static func select_tool(new_tool: SpriteTool):
  tool = new_tool
  SpriteEditor.tool_changed.emit(tool)


static func select_channel(new_channel: FactorySprite.Channel):
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
  for ch in FactorySprite.Channel.values():
    var tex = model.get_texture(ch)
    if tex != null:
      # Find closes point
      var test_pt = tex.closest_point(pt)
      if test_pt != null:
        # See if it's the new best option
        if closest == null || SpritePoint.distance(pt, test_pt) < SpritePoint.distance(pt, closest):
          closest = test_pt
  return closest


static func closest_line(pt):
  if model == null: return null
  var closest = null
  for ch in FactorySprite.Channel.values():
    var tex = model.get_texture(ch)
    if tex != null:
      # Find closes point to a line
      var test_pt = tex.closest_line(pt)
      if test_pt != null:
        # See if it's the new best option
        if closest == null || SpritePoint.distance(pt, test_pt) < SpritePoint.distance(pt, closest):
          closest = test_pt
  return closest
