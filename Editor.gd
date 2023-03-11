extends VBoxContainer

# Class
class_name Editor

# Signals
signal model_changed(model)
signal component_changed(component)
signal shape_changed(shape)

# Variables
var project = null
var Project = load("res://lib/Project.gd")

# Settings
@export var min_size = Vector2i(1000, 800)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create & load project
	project = Project.new()
	# Set minimum window size
	DisplayServer.window_set_min_size(min_size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
