@tool
class_name FactorySprite extends Node

# Our 3 types of textures
enum Channel {
  DIFFUSE = 0,
  NORMAL = 1,
  EMISSIVE = 2
}

# Support editing this model in the Sprite Factory
@export_group("Model")
@export_range(32, 512, 32) var size := 128
@export_multiline var model_json: String

func _ready():
  # Auto-create child nodes
  pass
