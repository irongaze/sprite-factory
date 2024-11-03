## Manages selection of layers/shapes/points, along with tools
## for checking contents.
@tool
class_name SpriteSelection extends RefCounted

## NOT CURRENTLY IN USE

# Our list of selected items
var items = []

## Test an object to see if we can add it to our selection
func is_selectable(obj):
  return obj is FSShape || obj is FSPoint

## Reset the selection
func clear(emit = true):
  set_to([], emit)

## Add a specific item to the selection
func add(item, emit = true):
  if is_selectable(item):
    if !has_item(item):
      items.push_back(item)
      if emit: FSEditor.fire_selection_changed()
  else:
    print('Unable to add to selection!')
    print(item)

## Remove a specific item from the selection
func remove(item, emit = true):
  if has_item(item):
    items.remove_at(items.find(item))
    if emit: FSEditor.fire_selection_changed()

func toggle(item, emit = true):
  if has_item(item):
    remove(item, emit)
  else:
    add(item, emit)

## Set the selection to a specific set of items
func set_to(new_items, emit = true):
  if not new_items is Array:
    new_items = [new_items]

  items = []
  for item in new_items:
    add(item, false)
  if emit: FSEditor.fire_selection_changed()

## Get all selected items, optionally filtered by one or more classes
func get_all(klass = null):
  var subset = []

  # By default, return all selected items
  if klass == null:
    return items.duplicate()

  # Allow passing in an array of classes, recurse
  if klass is Array:
    for item in items:
      subset += get_all(item)
    return subset

  # Single class mode, extract subset
  for item in items:
    if is_instance_of(item, klass):
      subset.push_back(item)
  return subset

## Get count of selected items, with optional class/class array
func count(klass = null):
  return get_all(klass).size()

## Test if the selection contains ANY of a given class
func has_type(klass):
  return count(klass) > 0

## Test if the selection contains a specific item
func has_item(item):
  return items.has(item)
