@tool
extends Control

# Display constants
const active_color = Color(0.36, 0.58, 0.78)
const inactive_color = Color(0.2, 0.22, 0.27)

# References

# Our state
var layer: FSLayer


func _ready():
  # Init our background to unselected
  $ColorRect.color = inactive_color

  # Bind to owned control signals
  %LayerName.text_submitted.connect(name_changed)
  %VisibilityButton.state_changed.connect(button_state_changed)
  %MirrorButton.state_changed.connect(button_state_changed)
  %LockButton.state_changed.connect(button_state_changed)

  FS.data_changed.connect(on_layer_changed)
  FS.ui_changed.connect(on_layer_changed)


func _exit_tree():
  FS.ui_changed.disconnect(on_layer_changed)
  FS.data_changed.disconnect(on_layer_changed)


func _gui_input(event):
  if event is InputEventMouseButton && event.button_index == 1 && event.pressed:
    FSEditor.select_component(layer.component)


func on_layer_changed():
  update_ui()


func set_layer(new_layer: FSLayer):
  layer = new_layer
  update_ui()


func update_ui():
  # Is a lag between ready and having a layer
  if !layer:
    $ColorRect.color = inactive_color
    return

  # Update the layer name
  %LayerName.text = layer.component.name

  # Update our toggle buttons, don't emit changes
  %VisibilityButton.set_state(!layer.component.hidden, false)
  %MirrorButton.set_state(layer.component.mirror, false)
  %LockButton.set_state(layer.component.locked, false)

  # Make sure our preview is previewing the right thing
  %RenderCanvas.set_renderable(layer)

  # Change appearance when selected
  $ColorRect.color = active_color if FS.layer == layer else inactive_color


func name_changed(new_name):
  layer.component.name = new_name
  FSEditor.fire_data_changed()


func button_state_changed():
  layer.component.hidden = !%VisibilityButton.get_state()
  layer.component.mirror = %MirrorButton.get_state()
  layer.component.locked = %LockButton.get_state()
  FSEditor.fire_data_changed()
