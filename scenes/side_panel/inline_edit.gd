@tool
extends LineEdit

var saved_text: String


func _ready():
  text_submitted.connect(on_submit)
  focus_entered.connect(save_state)


func on_submit(e):
  release_focus()


func save_state():
  saved_text = text


func _gui_input(event):
  if event is InputEventKey && event.pressed:
    if event.keycode == KEY_ESCAPE:
      text = saved_text
      release_focus()


func accept_event():
  return false
