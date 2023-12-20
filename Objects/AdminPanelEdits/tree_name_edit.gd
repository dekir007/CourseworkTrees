extends HBoxContainer

@onready var options: VBoxContainer = %Options
@onready var edit_name: TextEdit = $Editing/TextEdit
@onready var add_new_name_text: TextEdit = $Editing/AddNewName

@onready var submit_change_btn: PanelContainer = $Editing/SubmitChange
@onready var add_new_btn: PanelContainer = $Editing/AddNew
@onready var delete_name_btn: PanelContainer = $Editing/DeleteBtn

@onready var tree_name_scene = preload("res://Objects/name_option.tscn")

var cur_option : NameOption :
	set = set_cur_option

func _ready() -> void:
	submit_change_btn.btn.button_up.connect(submit_change)
	add_new_btn.btn.button_up.connect(add_new_name)
	delete_name_btn.btn.button_up.connect(delete_name)
	
	show_tree_names()

func show_tree_names():
	Globals.db.query("select name from TreeNames")
	for option in options.get_children():
		option.queue_free()
	for row in Globals.db.query_result:
		var tree_name : NameOption =  tree_name_scene.instantiate()
		options.add_child(tree_name)
		tree_name.text = row["Name"]
		tree_name.btn.button_up.connect(
			func(): 
				cur_option = tree_name
				print("anon func changed cur_option: " + cur_option.text)
				)

func submit_change():
	if cur_option == null or cur_option.text == edit_name.text or edit_name.text.is_empty():
		return
	 
	var q = "update TreeNames set name = \'" + edit_name.text + "\' where name = \'" + cur_option.text + "\'"
	Globals.db.query(q)
	 
	print(Globals.db.error_message)
	if(Globals.db.error_message == "not an error"):
		cur_option.text = edit_name.text

func add_new_name():
	if add_new_name_text.text.is_empty():
		return
	 
	var q = "insert into TreeNames(Name) values (\'" + add_new_name_text.text +  "\')"
	Globals.db.query(q)
	 
	print(Globals.db.error_message)
	if(Globals.db.error_message == "not an error"):
		var tree_name : NameOption =  tree_name_scene.instantiate()
		options.add_child(tree_name)
		tree_name.text = add_new_name_text.text
		tree_name.btn.button_up.connect(
			func(): 
				cur_option = tree_name
				print("anon func changed cur_option: " + cur_option.text)
				)
		add_new_name_text.clear()

func delete_name():
	if cur_option == null:
		return
	 
	Globals.db.query("delete from TreeNames where name = \'" + cur_option.text + "\'")
	 
	if(Globals.db.error_message == "not an error"):
		options.remove_child(cur_option)
		cur_option.queue_free()
		edit_name.clear()

func set_cur_option(new_opt : NameOption):
	if cur_option != null:
		cur_option.btn.set_pressed_no_signal(false)
	cur_option = new_opt
	edit_name.text = cur_option.text
