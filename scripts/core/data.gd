## Base class for all our serializable data elements starting with FSModel down to FSPoint
@tool
class_name FSData extends RefCounted

func load(json: String):
  var data = Data.new(json)
  _load(data)


# Override to extract data as needed from the passed Data store
func _load(data):
  pass


# Override to set data into the passed Data store
func _save(data):
  pass
