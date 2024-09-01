@tool
class_name SpriteColor extends RefCounted

var name: String
var color: Color
var brightness: float = 0.0

func to_color():
  if brightness >= 0.0:
    return color.lightened(brightness)
  else:
    return color.darkened(-brightness)
