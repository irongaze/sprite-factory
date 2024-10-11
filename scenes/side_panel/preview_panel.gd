@tool
extends PanelContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  #queue_redraw()
  %PreviewRoot.position = size / 2.0
  %PreviewLight.rotation_degrees += delta * 60.0
