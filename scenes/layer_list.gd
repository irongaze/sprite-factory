@tool
extends VBoxContainer

# Get scene refs
const LayerWidget = preload("res://addons/sprite_factory/scenes/layer_widget.tscn")

# The texture type we manage
@export var channel: Sprite.Channel

# Uplinks to model
var model: SpriteModel
var texture: SpriteTexture

# Link to our layer widget container
var layer_container: VBoxContainer

# Button links
var add_layer_button: Button
var layer_up_button: Button
var layer_down_button: Button
var delete_layer_button: Button

func _ready():
  layer_container = find_child("LayersContainer")

  add_layer_button = find_child("AddLayerButton")
  add_layer_button.pressed.connect(add_layer)

  layer_up_button = find_child("LayerUpButton")
  layer_up_button.pressed.connect(move_layer.bind(false))

  layer_down_button = find_child("LayerDownButton")
  layer_down_button.pressed.connect(move_layer.bind(true))

  delete_layer_button = find_child("DeleteLayerButton")
  delete_layer_button.pressed.connect(delete_layer)

  model_changed(null)

  SpriteEditor.model_changed.connect(model_changed)
  SpriteEditor.layer_changed.connect(layer_changed)

func _exit_tree():
  SpriteEditor.layer_changed.disconnect(layer_changed)
  SpriteEditor.model_changed.disconnect(model_changed)

func model_changed(new_model: SpriteModel):
  # Save refs
  model = new_model
  texture = model.get_texture(channel) if model else null

  # Update controls
  add_layer_button.disabled = model == null
  update_layers()
  update_ui()

func layer_changed(layer):
  update_ui()

func add_layer():
  var new_layer = SpriteLayer.new(texture)
  texture.layers.push_front(new_layer)
  SpriteEditor.fire_model_changed()
  SpriteEditor.select_layer(new_layer)

func delete_layer():
  SpriteEditor.selection.clear()

  var layer = SpriteEditor.layer
  texture.delete_layer(layer)

  SpriteEditor.fire_model_changed()

func move_layer(down: bool):
  var layer = SpriteEditor.layer

  var index = layer.calc_index()
  var other_index = index + 1 if down else index - 1

  texture.layers[index] = texture.layers[other_index]
  texture.layers[other_index] = layer

  SpriteEditor.fire_model_changed()

func update_layers():
  # We may be getting null here as there's no current sprite
  %NoSpriteLabel.visible = texture == null
  if texture != null:
    # Run the layers in our texture and ensure there's a widget to match
    for i in range(texture.layers.size()):
      var layer = texture.layers[i]
      var ctrl
      if layer_container.get_child_count() > i:
        ctrl = layer_container.get_child(i)
      else:
        ctrl = LayerWidget.instantiate()
        layer_container.add_child(ctrl)
      ctrl.set_layer(layer)

  # Now delete any *extra* widgets that are no longer needed...
  var last_idx = 0 if texture == null else texture.layers.size()
  while layer_container.get_child_count() > last_idx:
    var ctrl = layer_container.get_child(last_idx)
    layer_container.remove_child(ctrl)
    ctrl.queue_free()

func update_ui():
  # Update our layer button state based on the number of selected layers
  var layer = SpriteEditor.layer
  layer_up_button.disabled = layer == null || layer.calc_index() == 0
  layer_down_button.disabled = layer == null || layer.calc_index() >= layer.texture.layers.size() - 1
  delete_layer_button.disabled = layer == null
