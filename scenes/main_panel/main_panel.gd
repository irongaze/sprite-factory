@tool
extends Control

var canvas: RenderCanvas

# Called when the node enters the scene tree for the first time.
func _ready():
  canvas = find_child('PrimaryCanvas')

  FS.model_changed.connect(update_renderable)
  FS.channel_changed.connect(update_renderable)

func update_renderable():
  if FS.model != null:
    canvas.renderable = FS.model.get_texture(FS.channel)
  else:
    canvas.renderable = null
