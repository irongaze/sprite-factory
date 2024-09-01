@tool
extends TabContainer

func _ready():
  tab_changed.connect(on_tab_changed)

func on_tab_changed(index):
  var name = get_tab_title(index)
  match(name):
    "Diffuse":
      SpriteEditor.select_channel(Sprite.Channel.DIFFUSE)
    "Normal":
      SpriteEditor.select_channel(Sprite.Channel.NORMAL)
    "Emissive":
      SpriteEditor.select_channel(Sprite.Channel.EMISSIVE)
    _:
      print("UNKNOWN TAB: " + name)
