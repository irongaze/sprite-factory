@tool
class_name SpriteFactory extends EditorPlugin

# Holds our main panel (center screen/editing)
const MainPanel = preload("res://addons/sprite_factory/scenes/main_panel/main_panel.tscn")
var main_panel

# Holds our layer dock (right tab)
const LayerPanel = preload("res://addons/sprite_factory/scenes/side_panel/layer_panel.tscn")
var layer_panel

# Holds our preview dock (top left tab)
#var preview_panel

var selection = []

func _enter_tree():
  # Add layers
  layer_panel = LayerPanel.instantiate()
  add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, layer_panel)

  # Create our main panel scene instance
  main_panel = MainPanel.instantiate()
  # Add the main panel to the editor's main viewport.
  get_editor_interface().get_editor_main_screen().add_child(main_panel)
  # Hide the main panel. Very much required.
  _make_visible(false)

  # Add our custom node/resource type
  add_custom_type('Sprite Model', 'Resource', preload("res://addons/sprite_factory/sprite_model.gd"), preload("res://addons/sprite_factory/icons/ToolTriangle.svg"))
  add_custom_type('Factory Sprite', 'Node2D', preload("res://addons/sprite_factory/factory_sprite.gd"), preload("res://addons/sprite_factory/icons/Sprite.svg"))

  # Listen for project settings changes
  project_settings_changed.connect(func():
    print('settings changed!!!')
    SpriteFactorySettings.changed.emit()
  )

# Clean-up of the plugin goes here.
func _exit_tree():
  # Remove first
  remove_control_from_docks(layer_panel)

  # Kill off panels
  main_panel.queue_free()
  layer_panel.queue_free()

  # Remove our custom node/resource types
  remove_custom_type("Sprite")
  remove_custom_type("SpriteResource")

func _has_main_screen():
  return true

func _make_visible(visible):
  # Show the main center panel
  main_panel.visible = visible

  # Activate and show our special tabs
  activate_tab(layer_panel, visible)

  # Edit the currently selected node, if any
  var nodes = get_editor_interface().get_selection().get_selected_nodes()
  if nodes.size() == 1:
    edit_node(nodes[0])

# Call with a docked panel to have that panel's tab selected
func activate_tab(panel, visible):
  # Sanity
  if panel == null: return

  # Find the tab's index
  var dock = panel.get_parent()
  var index = null
  for i in range(dock.get_tab_count()):
    var tab = dock.get_tab_control(i)
    if tab == panel:
      index = i

  if index >= 0:
    # Show or hide the tab
    dock.set_tab_hidden(index, !visible)
    # Select it
    dock.current_tab = index if visible else 0

func _get_plugin_name():
  return "Sprite Factory"

func _get_plugin_icon():
  return preload("res://addons/sprite_factory/icons/ToolTriangle.svg")

# Override to request editing notifications for this node/resource type
func _handles(obj):
  return obj is FactorySprite

# Called by system to edit the given node
func _edit(node):
  edit_node(node)

# Called by system before a context switch to let us save our work
func _apply_changes():
  SpriteEditor.save_model()

# Actually load up a model (if possible) and start editing
func edit_node(node):
  # Extract the model from the node if it's a Sprite
  var model = null
  if node != null and node is FactorySprite:
    model = SpriteModel.from(node)
  # And edit it!
  SpriteEditor.edit_model(model)

# Override to store global editor settings (select tool, last-used color, whatever)
#func _get_window_layout():
#func _set_window_layout():
