## Data model for a shape - a set of points + color that
## draws a polygon in one of our channels.
@tool
class_name FSShape extends RefCounted

# Layer that owns us
var layer : FSLayer

# Points that represent the shape
var points : Array[FSPoint]

# Shape's explicit color
var color : FSColor


func _init(new_layer: FSLayer):
  layer = new_layer
  points = []
  color = FSColor.new()


func set_color(new_color: FSColor):
  color.update(new_color)
  SpriteEditor.fire_model_changed()


func add_point(loc):
  var pt = FSPoint.new(self, loc.x, loc.y)
  points.append(pt)
  return pt


func load(data):
  points = []
  var points_list = data.get('points', [])
  for point_data in points_list:
    var pt = FSPoint.new(self)
    pt.load(point_data)
    points.append(pt)


func to_data():
  var data = {}

  var point_data = []
  for pt in points:
    point_data.append(pt.save())
  data.points = point_data

  return data


# Render ourselves to the provided target
func render(canvas: RenderCanvas, mirror = false):
  # Get our points as vector2's
  var draw_points = []
  for pt in points:
    draw_points.append(pt.to_vector())

  # Only fill our shape once it's drawable
  if points.size() >= 3:
    # Mirror our color?
    var draw_color = color
    if mirror && layer.texture.is_normal():
      draw_color.r = 1.0 - draw_color.r

    # Fill polygon
    canvas.draw_colored_polygon(draw_points, draw_color)

  ## Show our points if we're selected
  #if canvas.show_selection && is_selected() && !mirror:
    #var radius = 5.0 / canvas.get_render_scale()
    #for pt in draw_points:
      #canvas.draw_circle(pt, radius, Color.WHITE)
      #canvas.draw_circle(pt, radius * 0.8, Color.BLACK)

  # Re-draw border as anti-aliased lines to add anti-aliasing to border and avoid
  # gaps between ideal polygons
#	draw_points.append(draw_points[0]) # close shape
#	canvas.draw_polyline(draw_points, draw_color, 0.2, true)


# Returns this shape or null, based on whether the point passed is
# inside the shape.
func hit_test(pt: Vector2):
  # Run all consecutive point pairs, and test that segment against
  # a horizontal segment from the test pt to the same point at x+5000.
  var distant_pt = Vector2(pt.x, pt.y)
  distant_pt.x += 5000
  var count = 0
  for i in range(points.size()):
    if test_intersect(pt, distant_pt, points[i], points[(i + 1) % points.size()]):
      count += 1

  # If the count of crossings is odd, the point is within the shape.
  if count % 2 == 1:
    return self
  else:
    return null;


func closest_point(pt: Vector2):
  # Run all points, find the best one
  var closest = null
  for test_pt in points:
    # Don't find points in the current selection, don't want to
    # snap to ourselves
    if !test_pt.is_selected():
      if closest == null || SpritePoint.distance(pt, test_pt) < SpritePoint.distance(pt, closest):
        closest = test_pt
  return closest


# Find the point closest to any of our segments
func closest_line(pt):
  var closest = null
  for i in range(points.size()):
    var test_pt = closest_segment(points[i], points[(i + 1) % points.size()], pt);
    if closest == null || SpritePoint.distance(pt, test_pt) < SpritePoint.distance(pt, closest):
      closest = test_pt

  # Return as vector if found
  return SpritePoint.vector(closest)


# Returns the point on the given segment closest to the test point
func closest_segment(ptA, ptB, test_pt):
  var dx = ptB.x - ptA.x
  var dy = ptB.y - ptA.y
  var px = test_pt.x - ptA.x
  var py = test_pt.y - ptA.y
  var t = (px * dx + py * dy) / (dx * dx + dy * dy)
  if t <= 0.0: return ptA
  if t >= 1.0: return ptB
  return Vector2(ptA.x + t * dx, ptA.y + t * dy);


# Helper for hit testing.  Given three collinear points p, q, r, the function
# checks if point q lies on line segment 'pr'.
func on_segment(p, q, r):
  return q.x <= maxf(p.x, r.x) && q.x >= minf(p.x, r.x) && q.y <= maxf(p.y, r.y) && q.y >= minf(p.y, r.y)


# To find orientation of ordered tripvar (p, q, r).
# The function returns following values
# 0 --> p, q and r are collinear
# 1 --> Clockwise
# 2 --> Counterclockwise
func calc_orientation(p, q, r):
  # See https:#www.geeksforgeeks.org/orientation-3-ordered-points/
  # for details of below formula.
  var val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y)

  # Collinear?
  if val == 0: return 0

  # Clockwise or counterclockwise
  return 1 if val > 0 else 2


# The main function that returns true if line segment 'p1q1'
# and 'p2q2' intersect.
func test_intersect(p1, q1, p2, q2):
  # Find the four orientations needed for general and
  # special cases
  var o1 = calc_orientation(p1, q1, p2)
  var o2 = calc_orientation(p1, q1, q2)
  var o3 = calc_orientation(p2, q2, p1)
  var o4 = calc_orientation(p2, q2, q1)

  # General case
  if o1 != o2 && o3 != o4:
    return true

  # Special Cases
  # p1, q1 and p2 are collinear and p2 lies on segment p1q1
  if o1 == 0 && on_segment(p1, p2, q1): return true

  # p1, q1 and q2 are collinear and q2 lies on segment p1q1
  if o2 == 0 && on_segment(p1, q2, q1): return true

  # p2, q2 and p1 are collinear and p1 lies on segment p2q2
  if o3 == 0 && on_segment(p2, p1, q2): return true

  # p2, q2 and q1 are collinear and q1 lies on segment p2q2
  if o4 == 0 && on_segment(p2, q1, q2): return true

  # Doesn't fall in any of the above cases
  return false
