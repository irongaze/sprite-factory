@tool
extends Button

@export var on_icon: Texture2D
@export var off_icon: Texture2D

signal state_changed()

var cur_state = true

func _ready():
	pressed.connect(on_pressed)

func on_pressed():
	toggle_state()

func toggle_state(emit = true):
	set_state(!cur_state, emit)

func get_state():
	return cur_state

func set_state(new_state, emit = true):
	# No change?
	if new_state == cur_state: return

	# Save state
	cur_state = new_state

	# Set our correct icon
	icon = on_icon if cur_state else off_icon
	# Gray out if toggled off
	if cur_state:
		remove_theme_color_override("icon_normal_color")
	else:
		add_theme_color_override("icon_normal_color", Color(0.15, 0.17, 0.2))

	if emit:
		state_changed.emit()
