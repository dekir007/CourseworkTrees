extends PanelContainer

@onready var tree_names: VBoxContainer = $HBoxContainer/Left/TreeNames
@onready var tree_compat: VBoxContainer = $HBoxContainer/Left/TreeCompat

@onready var options: VBoxContainer = %Options
@onready var compatibilities: VBoxContainer = %Compatibilities
@onready var edit_name: TextEdit = $HBoxContainer/Left/Editing/TextEdit
@onready var add_new_name_text: TextEdit = $HBoxContainer/Left/Editing/AddNewName
@onready var submit_change_btn: PanelContainer = $HBoxContainer/Left/Editing/SubmitChange
@onready var add_new_btn: PanelContainer = $HBoxContainer/Left/Editing/AddNew
@onready var delete_name_btn: PanelContainer = $HBoxContainer/Left/Editing/DeleteBtn
@onready var edit_names: VBoxContainer = $HBoxContainer/Left/Editing

@onready var edit_compat_vbox: VBoxContainer = $HBoxContainer/Left/EditCompat
@onready var edit_compat: TextEdit = $HBoxContainer/Left/EditCompat/edit_compat
@onready var delete_compat_btn: PanelContainer = $HBoxContainer/Left/EditCompat/DeleteCompatBtn
@onready var submit_compat_change_btn: PanelContainer = $HBoxContainer/Left/EditCompat/SubmitCompatChange

@onready var selected_tree_1: OptionButton = $HBoxContainer/Left/EditCompat/SelectedTree1
@onready var selected_tree_2: OptionButton = $HBoxContainer/Left/EditCompat/SelectedTree2
@onready var add_new_compat_value: TextEdit = $HBoxContainer/Left/EditCompat/AddNewCompatValue
@onready var add_new_compat_btn: PanelContainer = $HBoxContainer/Left/EditCompat/AddNewCompat

@onready var change_names: PanelContainer = $HBoxContainer/Right/ChangeNames
@onready var change_compat: PanelContainer = $HBoxContainer/Right/ChangeCompat

@onready var tree_name_scene = preload("res://Objects/tree_name_option.tscn")
@onready var tree_compat_scene = preload("res://Objects/tree_compat_option.tscn")

var db := SQLite.new()

var cur_option : TreeNameOption :
	set = set_cur_option
var cur_compat : TreeCompatOption :
	set(value):
		if cur_compat != null:
			cur_compat.btn.set_pressed_no_signal(false)
		cur_compat = value
		edit_compat.text = str(cur_compat.compat)


func _ready() -> void:
	db.path = "res://trees.sqlite"
	db.foreign_keys = true
	
	submit_change_btn.btn.button_up.connect(submit_change)
	add_new_btn.btn.button_up.connect(add_new_name)
	delete_name_btn.btn.button_up.connect(delete_name)
	
	delete_compat_btn.btn.button_up.connect(delete_compat)
	submit_compat_change_btn.btn.button_up.connect(submit_compat_change)
	add_new_compat_btn.btn.button_up.connect(add_new_compat)
	
	change_names.btn.button_up.connect(
		func(): 
			show_tree_names()
			tree_compat.hide()
			edit_compat_vbox.hide()
			tree_names.show()
			edit_names.show()
			edit_name.clear()
			)
	change_compat.btn.button_up.connect(
		func(): 
			show_tree_compat()
			tree_names.hide()
			edit_names.hide()
			tree_compat.show()
			edit_compat_vbox.show()
			edit_compat.clear()
			)
	
	show_tree_names()

func show_tree_names():
	db.open_db()
	db.query("select name from TreeNames")
	db.close_db()
	for option in options.get_children():
		option.queue_free()
	for row in db.query_result:
		var tree_name : TreeNameOption =  tree_name_scene.instantiate()
		options.add_child(tree_name)
		tree_name.text = row["Name"]
		tree_name.btn.button_up.connect(
			func(): 
				cur_option = tree_name
				print("anon func changed cur_option: " + cur_option.text)
				)

func show_tree_compat():
	db.open_db()
	db.query("select tn1.name as Tree1, tn2.name as Tree2, Compatibility from TreesCompatibility tc join TreeNames tn1 on tc.tree1 = tn1.id join TreeNames tn2 on tc.tree2 = tn2.id order by tc.tree1, tc.tree2")
	for compatibility in compatibilities.get_children():
		compatibility.queue_free()
	for row in db.query_result:
		var tree_compat = tree_compat_scene.instantiate()
		tree_compat.tree1 = row["Tree1"]
		tree_compat.tree2 = row["Tree2"]
		tree_compat.compat = row["Compatibility"]
		compatibilities.add_child(tree_compat)
		tree_compat.btn.button_up.connect(
			func(): 
				cur_compat = tree_compat
				print("anon func changed cur_compat: " + str(cur_compat.compat))
				)
	db.query("select name from TreeNames")
	db.close_db()
	selected_tree_1.clear()
	selected_tree_2.clear()
	for row in db.query_result:
		selected_tree_1.add_item(row["Name"])
		selected_tree_2.add_item(row["Name"])

func submit_change():
	if cur_option == null or cur_option.text == edit_name.text or edit_name.text.is_empty():
		return
	db.open_db()
	var q = "update TreeNames set name = \'" + edit_name.text + "\' where name = \'" + cur_option.text + "\'"
	db.query(q)
	db.close_db()
	print(db.error_message)
	if(db.error_message == "not an error"):
		cur_option.text = edit_name.text

func submit_compat_change():
	if cur_compat == null or str(cur_compat.compat) == edit_compat.text or edit_compat.text.is_empty():
		return
	db.open_db()
	var q = "update TreesCompatibility set Compatibility = " + edit_compat.text + " where tree1 = (select id from TreeNames where name = \'" + cur_compat.tree1+ "\') and tree2 = (select id from TreeNames where name = \'" + cur_compat.tree2+ "\')"
	db.query(q)
	db.close_db()
	print(db.error_message)
	if(db.error_message == "not an error"):
		cur_compat.compat = float(edit_compat.text)

func add_new_name():
	if add_new_name_text.text.is_empty():
		return
	db.open_db()
	var q = "insert into TreeNames(Name) values (\'" + add_new_name_text.text +  "\')"
	db.query(q)
	db.close_db()
	print(db.error_message)
	if(db.error_message == "not an error"):
		var tree_name : TreeNameOption =  tree_name_scene.instantiate()
		options.add_child(tree_name)
		tree_name.text = add_new_name_text.text
		tree_name.btn.button_up.connect(
			func(): 
				cur_option = tree_name
				print("anon func changed cur_option: " + cur_option.text)
				)
		add_new_name_text.clear()

func add_new_compat():
	if selected_tree_1.get_selected_id() == -1 or selected_tree_2.get_selected_id() == -1:
		return
	var tree1 = selected_tree_1.get_item_text(selected_tree_1.get_selected_id())
	var tree2 = selected_tree_2.get_item_text(selected_tree_2.get_selected_id())
	if tree1 == tree2 or add_new_compat_value.text.is_empty():
		return
	db.open_db()
	db.query("select id from TreeNames where name = \'" + tree1 +  "\'")
	var tree1id = db.query_result[0]["ID"]
	db.query("select id from TreeNames where name = \'" + tree2 +  "\'")
	var tree2id = db.query_result[0]["ID"]
	if tree1id > tree2id:
		var tmp = tree2id
		tree2id = tree1id
		tree1id = tmp
	var q = "insert into TreesCompatibility values (" + str(tree1id) + ", " + str(tree2id) + ", " + add_new_compat_value.text + ")"
	db.query(q)
	db.close_db()
	print(db.error_message)
	if(db.error_message == "not an error"):
		var tree_compat : TreeCompatOption =  tree_compat_scene.instantiate()
		compatibilities.add_child(tree_compat)
		tree_compat.tree1 = tree1
		tree_compat.tree2 = tree2
		tree_compat.compat = float(add_new_compat_value.text)
		tree_compat.btn.button_up.connect(
			func(): 
				cur_compat = tree_compat
				print("anon func changed cur_compat: " + str(cur_compat.compat))
				)
		add_new_compat_value.clear()

func delete_name():
	if cur_option == null:
		return
	db.open_db()
	db.query("delete from TreeNames where name = \'" + cur_option.text + "\'")
	db.close_db()
	if(db.error_message == "not an error"):
		options.remove_child(cur_option)
		cur_option.queue_free()
		edit_name.clear()

func delete_compat():
	if cur_compat == null:
		return
	db.open_db()
	db.query("delete from TreesCompatibility where tree1 = (select id from TreeNames where name = \'" + cur_compat.tree1+ "\') and tree2 = (select id from TreeNames where name = \'" + cur_compat.tree2+ "\')")
	db.close_db()
	if(db.error_message == "not an error"):
		compatibilities.remove_child(cur_compat)
		cur_compat.queue_free()
		edit_compat.clear()

func set_cur_option(new_opt : TreeNameOption):
	if cur_option != null:
		cur_option.btn.set_pressed_no_signal(false)
	cur_option = new_opt
	edit_name.text = cur_option.text


func _on_exit_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/general_page.tscn")


func _on_in_editor_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/editor_vp_container.tscn")
