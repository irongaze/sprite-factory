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
  if new_model == FS.model: return

  # Reset our state
  FS.model = new_model
  if FS.model != null:
    select_component(FS.model.components[0])

  # Force a rebuild of the UI
  FS.model_changed.emit()
  FS.data_changed.emit()
  FS.ui_changed.emit()


static func save_model():
  if FS.model != null:
    FS.model.save_all()


static func select_tool(new_tool: FSTool):
  # Tell the old tool it's toast
  if FS.tool != null:
    FS.tool.deactivate()

  # Tell the new tool it's up
  FS.tool = new_tool

  # Assuming it exists, activate it
  if FS.tool:
    FS.tool.activate()

  # Tell the UI to update
  FS.ui_changed.emit()


static func select_channel(new_channel: FS.Channel):
  if new_channel == FS.channel: return

  # Save new channel
  FS.channel = new_channel

  # Switch to new layer in our current component
  if FS.component:
    var new_layer = FS.component.get_layer(new_channel)
    FS.layer = new_layer

  # Let folks know we're on a new channel
  fire_ui_changed()


static func add_component():
  if FS.model == null: return null
  var c = FSComponent.new(FS.model)
  FS.model.components.push_front(c)

  select_component(c)

  fire_data_changed()


static func delete_component(c : FSComponent):
  if FS.model == null: return null

  # Locate it and remove it
  var idx = FS.model.components.find(c)
  FS.model.components.erase(c)

  # If this component was selected, select next nearest
  if FS.component == c:
    if idx >= FS.model.components.size():
      idx = FS.model.components.size() - 1
    select_component(FS.model.components[idx])

  # Let folks know the data has changed
  fire_data_changed()


static func select_component(new_component: FSComponent):
  if new_component == FS.component: return

  FS.component = new_component
  if new_component != null:
    FS.layer = FS.component.get_layer(FS.channel)
  else:
    FS.layer = null

  fire_component_changed()


static func fire_component_changed():
  FS.component_changed.emit()
  fire_ui_changed()


static func fire_data_changed():
  save_model()
  FS.data_changed.emit()
  fire_ui_changed()


static func fire_ui_changed():
  FS.ui_changed.emit()


static func hit_test(pt):
  if FS.model == null: return null

  var texture = FS.model.get_texture(FS.channel)
  return texture.hit_test(pt)


static func closest_point(pt):
  if FS.model == null: return null

  var closest = null
  for ch in FS.Channel.values():
    var tex = FS.model.get_texture(ch)
    var test_pt = tex.closest_point(pt)
    if test_pt != null:
      # See if it's the new best option
      if closest == null || FSPoint.distance(pt, test_pt) < FSPoint.distance(pt, closest):
        closest = test_pt
  return closest


static func closest_line(pt):
  if FS.model == null: return null
  var closest = null
  for ch in FS.Channel.values():
    var tex = FS.model.get_texture(ch)
    if tex != null:
      # Find closes point to a line
      var test_pt = tex.closest_line(pt)
      if test_pt != null:
        # See if it's the new best option
        if closest == null || FSPoint.distance(pt, test_pt) < FSPoint.distance(pt, closest):
          closest = test_pt
  return closest
