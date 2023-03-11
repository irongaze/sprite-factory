# Project container, owns models and project settings
class_name Project

extends Resource

var path
var rootDir
var models = []

func _init():
	print(OS.get_executable_path())

# Load json and
func load(filePath):
	# Sanity check
	if not FileAccess.file_exists(filePath):
		return false

	# Store off our path
	path = filePath

	# Read the json & parse it
	var file = FileAccess.open(path, FileAccess.READ)
	var json = file.get_as_text()
	var data = JSON.parse_string(json)

	# Run the data
	models = []


func save():
	var data = { "models": []}

	var json = JSON.stringify(data)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(json)

func loadModel():
	pass
