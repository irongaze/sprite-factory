@tool
class_name SpriteComponent extends RefCounted

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
