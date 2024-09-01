@tool
extends Control

# Display constants
const active_color = Color(0.36, 0.58, 0.78)
const inactive_color = Color(0.2, 0.22, 0.27)

# References

# Our state
var layer: SpriteLayer
var active := false

func _ready():
  # Init our background to unselected
  $ColorRect.color = inactive_color

  # Bind to owned control signals
  %LayerName.text_submitted.connect(name_changed)
  %VisibilityButton.state_changed.connect(button_state_changed)
  %MirrorButton.state_changed.connect(button_state_changed)
  %LockButton.state_changed.connect(button_state_changed)

  SpriteEditor.layer_changed.connect(on_layer_changed)

func _exit_tree():
  SpriteEditor.layer_changed.disconnect(on_layer_changed)

func _gui_input(event):
  if event is InputEventMouseButton && event.button_index == 1 && event.pressed:
    SpriteEditor.select_layer(layer)

func on_layer_changed(layer):
  update_ui()

func set_layer(new_layer: SpriteLayer):
  layer = new_layer
  update_ui()

func update_ui():
  # Is a lag between ready and having a layer
  if !layer: return

  # Update the layer name
  %LayerName.text = layer.name

  # Update our toggle buttons, don't emit changes
  %VisibilityButton.set_state(!layer.hidden, false)
  %MirrorButton.set_state(layer.mirror, false)
  %LockButton.set_state(layer.locked, false)

  # Make sure our preview is previewing the right thing
  %RenderCanvas.set_renderable(layer)

  # Change appearance when selected
  $ColorRect.color = active_color if SpriteEditor.layer == layer else inactive_color

func name_changed(new_name):
  layer.name = new_name
  SpriteEditor.fire_model_changed()

func button_state_changed():
  layer.hidden = !%VisibilityButton.get_state()
  layer.mirror = %MirrorButton.get_state()
  layer.locked = %LockButton.get_state()
  SpriteEditor.fire_model_changed()
