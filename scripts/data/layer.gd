## A collection of shapes within a component, for a given channel.
@tool
class_name FSLayer extends RefCounted

# Our owning component
var component : FSComponent

# What channel we're for
var channel : FS.Channel

# Array of shapes we contain
var shapes : Array[FSShape]


func _init(parent : FSComponent, ch := FS.Channel.DIFFUSE):
  component = parent
  channel = ch
  shapes = []


func add_shape():
  var shape = FSShape.new(self)
  shapes.append(shape)
  return shape


func remove_shape(shape):
  if shape.layer == self: shape.layer = null
  shapes.remove_at(shapes.find(shape))
  return shape


func hit_test(pt):
  if !component.hidden && !component.locked:
    # Run shapes from top to bottom
    for i in range(shapes.size()-1, -1, -1):
      var shape = shapes[i]
      var found = shape.hit_test(pt)
      if found != null: return found
  return null


func closest_point(pt):
  var closest = null
  # Skip this layer if we're hidden
  if !component.hidden:
    # Run all shapes
    for shape in shapes:
      # Find closes point
      var test_pt = shape.closest_point(pt)
      if test_pt != null:
        # See if it's the new best option
        if closest == null || FSPoint.distance(pt, test_pt) < FSPoint.distance(pt, closest):
          closest = test_pt

  return closest


func closest_line(pt):
  var closest = null
  # Skip this layer if we're hidden
  if !component.hidden:
    # Run all shapes
    # Run all shapes
    for shape in shapes:
      # Find closes point on a line
      var test_pt = shape.closest_line(pt)
      if test_pt != null:
        # See if it's the new best option
        if closest == null || FSPoint.distance(pt, test_pt) < FSPoint.distance(pt, closest):
          closest = test_pt

  return closest


# Helpers for cleaner code
func is_diffuse():
  return channel == FS.Channel.DIFFUSE
func is_normal():
  return channel == FS.Channel.NORMAL
func is_emissive():
  return channel == FS.Channel.EMISSIVE


func load(data : Dictionary):
  # Get our core info
  channel = data.get('channel')

  # Load up our shapes
  shapes = []
  var shapes_list = data.get('shapes', [])
  for shape_data in shapes_list:
    # Load the new shape
    var shape = FSShape.new(self)
    shape.load(shape_data)
    # Validate it
    if shape.points.size() >= 3:
      shapes.append(shape)


func save():
  # Build our core data
  var data = {
    "channel": channel
  }

  # Add in our shape info
  var shape_data = []
  for shape in shapes:
    shape_data.append(shape.save())
  data.shapes = shape_data

  # And return it
  return data


func render(canvas: RenderCanvas):
  if component.hidden && !canvas.show_hidden: return

  # Render bottom-up for proper z-order
  for i in range(shapes.size()-1, -1, -1):
    var shape = shapes[i]
    shape.render(canvas, false)
    if component.mirror:
      canvas.set_transform(true)
      shape.render(canvas, true)
      canvas.set_transform(false)
