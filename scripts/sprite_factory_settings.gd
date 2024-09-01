## Manages per-project settings for the Sprite Factory.  Settings are stored in
## the ProjectSettings system (aka the project.godot file & project settings dialog).
@tool
class_name SpriteFactorySettings extends RefCounted

# Our supported settings meta-data.  Supports:
#
#  name: Settings name/path (required)
#  default: Default value (required)
#  desc: Description for tooltip in project settings dialog (optional)
#  advanced: true to hide by default (optional, default false)
#  internal: true to hide always (optional, default false)
const SETTINGS = {
  "grid_size": {
    "name": "ui/grid_size",
    "default": 4.0,
    "desc": "Spacing of the snap-grid in pixels",
  },
  "color_palette": {
    "name": "colors/palette",
    "default": "{\"palette\": []}",
    "desc": "Keyed color palette used when editing sprites",
    "internal": true,
  }
}


## Spacing of snap-grid in pixels
static var grid_size: float :
  get: return get_setting("grid_size")
  set(val): set_setting("grid_size", val)

# When fired, the selection has changed
signal _changed()
static var changed: Signal:
  get: return instance._changed


# Global instance to hold our static signals
static var instance := SpriteFactorySettings.new()


# Setup meta-data for our various settings on load
static func _static_init():
  # Run each defined setting
  for key in SETTINGS:
    # Get our metadata
    var info = SETTINGS[key]
    var name = "sprite_factory/" + info.name
    # Make sure we have a value first
    if !ProjectSettings.has_setting(name):
      ProjectSettings.set_setting(name, info.default)
    # Set main metadata
    ProjectSettings.add_property_info({
      "name": name,
      "type": typeof(info.default),
      "hint_string": info.get("desc", "no description")
    })
    # Advanced only?
    ProjectSettings.set_as_basic(name, !info.get("advanced", false))
    # Internal?
    ProjectSettings.set_as_internal(name, info.get("internal", false))
    # If has default, set as initial value to allow reverting
    ProjectSettings.set_initial_value(name, info.get("default"))


# Internal helper to get a setting via metadata key
static func get_setting(key):
  var info = SETTINGS.get(key)
  var default = info.get("default", null)
  return ProjectSettings.get_setting("sprite_factory/" + info.name, default)


# Internal helper to set a setting via metadata key
static func set_setting(key, val):
  var info = SETTINGS.get(key)
  ProjectSettings.set_setting("sprite_factory/" + info.name, val)
