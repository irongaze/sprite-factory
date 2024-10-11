@tool
class_name SpriteColor extends RefCounted

var name: String
var color := Color()
var brightness: float = 0.0

func update(val: SpriteColor):
  name = val.name
  color = val.color
  brightness = val.brightness
  pass

func to_color():
  if brightness >= 0.0:
    return color.lightened(brightness)
  else:
    return color.darkened(-brightness)

# Load from a cursor
static func from_data(cursor):
  var c = SpriteColor.new()
  c.name = cursor.get_val('name')
  c.color.from_string(cursor.get_val('color'))
  c.brightness = cursor.get_val('brightness', 0.0)
  return c

# Convert to simple format used by our Data class
func to_data():
  return {
    name: name,
    color: color.to_html(),
    brightness: brightness
  }
