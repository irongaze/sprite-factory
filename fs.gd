@tool
class_name FS extends RefCounted

# Our 3 types of textures
enum Channel {
  DIFFUSE = 0,
  NORMAL = 1,
  EMISSIVE = 2
}

# Instance of our main editor
static var editor := FSEditor.new()


# References

# Selected Godot node that we're editing (if any)
static var node : FactorySprite
# Model data extracted from the node we work on
static var model : FSModel
# Which channel are we editing
static var channel := FS.Channel.DIFFUSE
# Which component in the model are we working with
static var component : FSComponent
# Given the channel + component, we're editing this layer
static var layer : FSLayer
# Currently selected tool
static var tool : FSTool


# Signals

# When fired, which model we're editing has changed
static var model_changed: Signal:
  get: return editor.model_changed

# When fired, the channel we're working on has changed
static var channel_changed: Signal:
  get: return editor.channel_changed

# When fired, the component/layer we're working on has changed
static var component_changed: Signal:
  get: return editor.component_changed

# When fired, the model's data has changed and previews need to redraw etc
static var data_changed: Signal:
  get: return editor.data_changed

# When fired, the UI needs to update
static var ui_changed: Signal:
  get: return editor.ui_changed
