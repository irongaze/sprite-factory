@tool
extends MarginContainer

@export var title: String

func _ready():
	$Title.text = title
