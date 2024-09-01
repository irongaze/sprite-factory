@tool
extends SubViewport

func export():
  print('exporting textures...')

#	await RenderingServer.frame_post_draw
#	get_texture().get_data().save_png("res://my_img.png")
