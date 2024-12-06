@tool
extends VBoxContainer

# Get scene refs
const LayerWidget = preload("res://addons/sprite_factory/scenes/side_panel/layer_widget.tscn")

# The texture type we manage
@export var channel : FS.Channel

# Link to our layer widget container
var layer_container : VBoxContainer

# Button links
var add_component_button : Button
var component_up_button : Button
var component_down_button : Button
var delete_component_button : Button


func _ready():
  layer_container = find_child("LayersContainer")

  add_component_button = find_child("AddLayerButton")
  add_component_button.pressed.connect(add_component)

  component_up_button = find_child("LayerUpButton")
  component_up_button.pressed.connect(move_component.bind(false))

  component_down_button = find_child("LayerDownButton")
  component_down_button.pressed.connect(move_component.bind(true))

  delete_component_button = find_child("DeleteLayerButton")
  delete_component_button.pressed.connect(delete_component)

  model_changed()

  FS.model_changed.connect(model_changed)
  FS.data_changed.connect(model_changed)
  FS.ui_changed.connect(ui_changed)


func _exit_tree():
  FS.ui_changed.disconnect(ui_changed)
  FS.data_changed.disconnect(model_changed)
  FS.model_changed.disconnect(model_changed)


func model_changed():
  # Update controls
  update_layers()
  update_ui()


func ui_changed():
  update_ui()


func add_component():
  FSEditor.add_component()


func delete_component(c : FSComponent):
  FSEditor.delete_component(c)


func move_component(down: bool):
  var index = FS.component.calc_index()
  var other_index = index + 1 if down else index - 1

  FS.model.components[index] = FS.model.components[other_index]
  FS.model.components[other_index] = FS.component

  FSEditor.fire_data_changed()


func update_layers():
  # We may be getting null here as there's no current sprite
  %NoSpriteLabel.visible = FS.model == null
  if FS.model != null:
    # Run the layers in our texture and ensure there's a widget to match
    for i in range(FS.model.components.size()):
      var layer = FS.model.components[i].get_layer(channel)
      var ctrl
      if layer_container.get_child_count() > i:
        ctrl = layer_container.get_child(i)
      else:
        ctrl = LayerWidget.instantiate()
        layer_container.add_child(ctrl)
      ctrl.set_layer(layer)

  # Now delete any *extra* widgets that are no longer needed...
  var last_idx = 0 if FS.model == null else FS.model.components.size()
  while layer_container.get_child_count() > last_idx:
    var ctrl = layer_container.get_child(last_idx)
    layer_container.remove_child(ctrl)
    ctrl.queue_free()


func update_ui():
  # Got a model?
  add_component_button.disabled = FS.model == null

  # Update our component button state based on the number of selected components
  var component = FS.component
  var component_count = FS.model.components.size() if FS.model != null else 0
  component_up_button.disabled = component == null || component.calc_index() == 0
  component_down_button.disabled = component == null || component.calc_index() >= component_count - 1
  delete_component_button.disabled = component == null || component_count <= 1
