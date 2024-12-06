@tool
extends Control

var color : FSColor

var color_ctrl : ColorRect

func _ready():
  color_ctrl = find_child("Color")


# Call to assign the given FSColor to this control
func bind_color(c : FSColor):
  color = c
  update_ui()


func update_ui():
  if color != null:
    color_ctrl.color = color.color
