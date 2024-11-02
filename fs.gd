@tool
class_name FS extends RefCounted

# Our 3 types of textures
enum Channel {
  DIFFUSE = 0,
  NORMAL = 1,
  EMISSIVE = 2
}

# Selected Godot node that we're editing
static var node : FactorySprite
# Model data extracted from the node we work on
static var model : FSModel
# Which channel are we editing
static var channel := FS.Channel.DIFFUSE
# Which component in the model are we editing
static var component : FSComponent
# Given the channel + component, we're editing a layer
static var layer : FSLayer
