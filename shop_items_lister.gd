@tool
extends EditorScript

## This tool doesn't work, see:
## https://github.com/godotengine/godot/issues/72563

var ITEM_RESOURCES_FOLDER_PATH = "res://items"


func _run() -> void:
	if not get_scene() is Shop:
		return
	
	var shop_scene: Shop = get_scene()
	
	var item_resource_files = []
	var item_resources_directory = DirAccess.open(ITEM_RESOURCES_FOLDER_PATH)
	
	if not item_resources_directory:
		print("Item resources directory not found.")
		return
	
	item_resources_directory.list_dir_begin()
	var item_resource_file = item_resources_directory.get_next()
	
	while item_resource_file != "":
		item_resource_files.append(ITEM_RESOURCES_FOLDER_PATH + "/" + item_resource_file)
		item_resource_file = item_resources_directory.get_next()
	
	shop_scene.item_resource_files = item_resource_files
