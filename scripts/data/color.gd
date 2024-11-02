## Implements a shape's color, which includes the color itself,
## the key it came from in the palette if any, and a brightness value.
@tool
class_name FSColor extends RefCounted

# Attributes
var key : String
var color := Color()
var brightness : float = 0.0


func update(val: FSColor):
  key = val.key
  color = val.color
  brightness = val.brightness


func to_color():
  if brightness >= 0.0:
    return color.lightened(brightness)
  else:
    return color.darkened(-brightness)


# Load from a cursor
static func from_data(cursor):
  var c = FSColor.new()
  c.key = cursor.get_val('key')
  c.color.from_string(cursor.get_val('color'))
  c.brightness = cursor.get_val('brightness', 0.0)
  return c


# Convert to simple format used by our Data class
func to_data():
  return {
    key: key,
    color: color.to_html(),
    brightness: brightness
  }
