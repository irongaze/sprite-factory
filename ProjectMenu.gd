extends MenuButton

@onready var editor = get_node('/root/Editor')

# Called when the node enters the scene tree for the first time.
func _ready():
	get_popup().id_pressed.connect(menu_id_pressed)
	about_to_popup.connect(update_items)

func update_items():
	var has_project = editor.project != null
	var popup = get_popup()
	popup.set_item_disabled(popup.get_item_index(2), !has_project)
	popup.set_item_disabled(popup.get_item_index(3), !has_project)

func menu_id_pressed(id):
	match id:
		5: show_new()
		1: show_load()
		2: show_properties()
		3: reveal_folder()
		4: do_exit()
	pass

func show_new():
	pass

func show_load():
	var dlg = $ProjectDialog
	dlg.popup_centered(dlg.get_size())
	dlg.file_selected.connect(load_new_project)

func load_new_project(path):
	print("Loading path: " + path)
#	Editor.project.load(path)

#	var vId = RenderingServer.viewport_create()
#	RenderingServer.viewport_set_size(vId, 64, 64)
#	var canvasId = RenderingServer.canvas_create()
#	RenderingServer.viewport_attach_canvas(vId, canvasId)
#	var cId = RenderingServer.canvas_item_create()
#	RenderingServer.canvas_item_set_parent(cId, canvasId)
#	RenderingServer.canvas_item_add_rect(cId, Rect2(0,0,32,32), Color.RED)
#	await RenderingServer.frame_post_draw
#	var tId = RenderingServer.viewport_get_texture(vId)
#	var image = RenderingServer.texture_2d_get(tId)
#	image.save_png("c:/code/test.png")
#	var viewport = SubViewport.new()
#	viewport.set_size(Vector2(64, 64))
#	var node = Node2D.new()
#	viewport.add_child(node)
#	node.draw_rect(Rect2(0,0,32,32), Color.RED, true)
#	viewport.get_texture().get_image().save_png("c:\\test.png")

func show_properties():
	pass

func reveal_folder():
#	OS.shell_open(Editor.project.root_dir)
	pass

func do_exit():
	get_tree().quit()
