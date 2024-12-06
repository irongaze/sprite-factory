@tool
class_name FSPalette extends RefCounted

# What texture channel we're for (e.g. diffuse)
var channel : FS.Channel

# Map of key to FSColor
var map = {}


# Constructor
func _init(ch := FS.Channel.DIFFUSE):
  channel = ch


# Add a new color to the palette
func add_color(color: FSColor):
  map[color.key] = color


# Look up a color by its key
func get_color(key: String):
  return map.get(key)


# De-serialize
static func from_data(data):
  var p = FSPalette.new()
  p.channel = data.get_val('channel')
  for color in data.get_val('colors'):
    var c = FSColor.from_data(color)
    p.add_color(c)
  return p


func to_data():
  var colors = []
  return {
    channel: channel,
    colors: colors
  }
