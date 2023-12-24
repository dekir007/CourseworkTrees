extends Control

@export var cityid : int = 1

@onready var cool_button: = $UI/CoolButton as CoolButton
@onready var editor:  = $SubViewportContainer/SubViewport/Editor as Editor
@onready var background_btn: = $UI/BackgroundBtn as CoolButton
@onready var file_dialog: FileDialog = $FileDialog
@onready var selected_background: OptionButton = $UI/SelectedBackground
@onready var selected_city: OptionButton = $UI/SelectedCity

var pics : Dictionary

func _ready() -> void:
	cityid = ProjectSettings.get_setting("global/CityID")
	#print("editor vp",cityid)
	#editor.cityid = cityid
	cool_button.btn.button_up.connect(func():
		get_tree().change_scene_to_file("res://Scenes/admin_panel.tscn")
		)
	background_btn.btn.button_up.connect(func():
		file_dialog.show()
		)
	get_backs()
	get_cities()
	_on_selected_background_item_selected(0)
	
func get_cities():
	Globals.db.query("select name from Cities")
	selected_city.clear()
	for row in Globals.db.query_result:
		selected_city.add_item(row["Name"])
	selected_city.select(cityid-1)

func get_backs():
	Globals.db.query("select id, Background from Backgrounds where CityID = " + str(cityid))
	selected_background.clear()
	for row in Globals.db.query_result:
		var img =  Image.new()
		img.load_png_from_buffer(row["Background"])
		pics[row["ID"]] = img
		selected_background.add_item(str(row["ID"]))
	#texture_rect.texture = ImageTexture.create_from_image(img)

func _on_file_dialog_files_selected(paths: PackedStringArray) -> void:
	for path in paths:
		print(path)
		var img = load_external_tex(path)
		Globals.db.query_with_bindings("insert into Backgrounds(Background, CityID) values (?, " + str(cityid) + ")", [img.save_png_to_buffer()])
		#await get_tree().create_timer(1).timeout
	get_backs()
	if editor.photo.texture == null:
		_on_selected_background_item_selected(0)

func load_external_tex(path) -> Image:
	var tex_file = FileAccess.open(path, FileAccess.READ)
	var bytes = tex_file.get_buffer(tex_file.get_length())
	var img = Image.new()
	var data
	#if path.right(3) == "jpg":
		#data = img.load_jpg_from_buffer(bytes)
	if path.right(3) == "png":
		data = img.load_png_from_buffer(bytes)
	else: 
		printerr("NOT PNG")
		return
	return img

func _on_selected_background_item_selected(index: int) -> void:
	var pics_inx = int(selected_background.get_item_text(index))
	if pics.has(pics_inx):
		editor.photo.texture = ImageTexture.create_from_image(pics[pics_inx])
		editor.get_node("Camera2D")._ready()
	else:
		editor.photo.texture = null
		editor.get_node("Camera2D").clamp_viewport = true
		editor.get_node("Camera2D").clamp_sprite = false
		editor.get_node("Camera2D")._ready()


func _on_selected_city_item_selected(index: int) -> void:
	if selected_city.has_focus():
		ProjectSettings.set_setting("global/CityID", index+1)
		print(ProjectSettings.get_setting("global/CityID"))
		get_tree().reload_current_scene()
