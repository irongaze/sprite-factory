@tool
class_name FactorySprite extends Node

# A dynamically editable sprite, built in the sprite factory, designed
# for use with 2D lighting.

# Support editing this model in the Sprite Factory
@export_group("Model")
@export_range(32, 512, 32) var size := 128
#@export_storage var model_json: String
@export_multiline var model_json: String

func _ready():
  # Auto-create child nodes
  pass
