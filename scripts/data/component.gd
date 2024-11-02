## A logical part of a sprite, containing 3 layers, one for
## each channel.
@tool
class_name FSComponent extends RefCounted

func is_selected():
  return FS.component == self


func select():
  SpriteEditor.selection.set_to(self)


func deselect():
  SpriteEditor.selection.remove(self)


func toggle_selection():
  if is_selected():
    deselect()
  else:
    select()
