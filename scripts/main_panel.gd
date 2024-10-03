@tool
extends Control

var canvas: RenderCanvas

# Called when the node enters the scene tree for the first time.
func _ready():
  canvas = find_child('PrimaryCanvas')

  SpriteEditor.model_changed.connect(on_model_changed)
  SpriteEditor.channel_changed.connect(on_channel_changed)

func on_model_changed(model):
  on_channel_changed(FactorySprite.Channel.DIFFUSE)

func on_channel_changed(channel: FactorySprite.Channel):
  var model = SpriteEditor.model
  if model != null:
    canvas.renderable = model.get_texture(channel)
  else:
    canvas.renderable = null
