extends Control

class_name Canvas

@export var snap_grid: int = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()

# Custom draw function
func _draw():
	draw_helpers()
	# draw_model()

func draw_helpers():
	# Setup
	set_native_scale()
	var size = get_size().x
	var scale = size / 96
	var half = size / 2.0

	# Fill background
	draw_rect(Rect2(-half,-half,size,size), Color.BLACK, true)

	# Draw main axes
	var color = Color('222')
	draw_line(Vector2(0,-half), Vector2(0,half), color, 1.0)
	draw_line(Vector2(-half,0), Vector2(half,0), color, 1.0)

	# Draw snap grid
	color = Color('111')
	var x = snap_grid * scale
	while x < half:
		draw_line(Vector2(x,-half), Vector2(x,half), color, 1.0)
		draw_line(Vector2(-x,-half), Vector2(-x,half), color, 1.0)
		x += snap_grid * scale
	var y = snap_grid * scale
	while y < half:
		draw_line(Vector2(-half,y), Vector2(half,y), color, 1.0)
		draw_line(Vector2(-half,-y), Vector2(half,-y), color, 1.0)
		y += snap_grid * scale

func set_native_scale():
	var size = get_size()
	draw_set_transform(size / 2, 0, Vector2.ONE)

func set_model_scale():
	var size = get_size()
	draw_set_transform(size / 2, 0, Vector2.ONE)
