@tool
extends Control


func get_sprite():
  return find_child('NormalSmooth')

func _gui_input(event):
  if event is InputEventMouseButton && event.is_pressed() && event.button_index == 1:
    var sprite = get_sprite()
    var tex = sprite.texture
    var img = tex.get_image()
    var color = img.get_pixel(event.position.x, event.position.y)
    #FSEditor.apply_color(color)
