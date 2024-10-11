@tool
class_name SpritePoint extends RefCounted

# Parent
var shape: SpriteShape

# Data
var x: float
var y: float


# Distance between two points, accepts Vector2 and SpritePoint
static func distance(a, b):
  var dx = a.x - b.x
  var dy = a.y - b.y
  return sqrt(dx * dx + dy * dy)


static func vector(val):
  if val == null: return null
  if val is Vector2: return val
  return val.to_vector()


func _init(parent: SpriteShape, nx = 0.0, ny = 0.0):
  shape = parent
  x = nx
  y = ny


func is_selected():
  return SpriteEditor.selection.has_item(self)


func select():
  SpriteEditor.selection.set_to(self)


func deselect():
  SpriteEditor.selection.remove(self)


func toggle_selection():
  if is_selected():
    deselect()
  else:
    select()


func update(loc):
  x = loc.x
  y = loc.y


func distance_to(pt):
  var dx = pt.x - x
  var dy = pt.y - y
  return sqrt(dx * dx + dy * dy)


func load(data):
  x = data.x
  y = data.y


func save():
  var data = {
    "x": x,
    "y": y,
  }
  return data


func to_vector():
  return Vector2(x,y)
