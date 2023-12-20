extends HBoxContainer

@onready var compatibilities: VBoxContainer = %Compatibilities
@onready var edit_compat: TextEdit = $EditCompat/edit_compat
@onready var delete_compat_btn: PanelContainer = $EditCompat/DeleteCompatBtn
@onready var submit_compat_change_btn: PanelContainer = $EditCompat/SubmitCompatChange

@onready var selected_tree_1: OptionButton = $EditCompat/SelectedTree1
@onready var selected_tree_2: OptionButton = $EditCompat/SelectedTree2
@onready var add_new_compat_value: TextEdit = $EditCompat/AddNewCompatValue
@onready var add_new_compat_btn: PanelContainer = $EditCompat/AddNewCompat

@onready var tree_compat_scene = preload("res://Objects/tree_compat_option.tscn")

var cur_compat : TreeCompatOption :
	set(value):
		if cur_compat != null:
			cur_compat.btn.set_pressed_no_signal(false)
		cur_compat = value
		edit_compat.text = str(cur_compat.compat)

func _ready() -> void:
	Globals.db.path = "res://trees.sqlite"
	Globals.db.foreign_keys = true
	
	delete_compat_btn.btn.button_up.connect(delete_compat)
	submit_compat_change_btn.btn.button_up.connect(submit_compat_change)
	add_new_compat_btn.btn.button_up.connect(add_new_compat)
	
	show_tree_compat()

func show_tree_compat():
	Globals.db.query("select tn1.name as Tree1, tn2.name as Tree2, Compatibility from TreesCompatibility tc join TreeNames tn1 on tc.tree1 = tn1.id join TreeNames tn2 on tc.tree2 = tn2.id order by tc.tree1, tc.tree2")
	for compatibility in compatibilities.get_children():
		compatibility.queue_free()
	for row in Globals.db.query_result:
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
	Globals.db.query("select name from TreeNames")
	 
	selected_tree_1.clear()
	selected_tree_2.clear()
	for row in Globals.db.query_result:
		selected_tree_1.add_item(row["Name"])
		selected_tree_2.add_item(row["Name"])

func submit_compat_change():
	if cur_compat == null or str(cur_compat.compat) == edit_compat.text or edit_compat.text.is_empty():
		return
	 
	var q = "update TreesCompatibility set Compatibility = " + edit_compat.text + " where tree1 = (select id from TreeNames where name = \'" + cur_compat.tree1+ "\') and tree2 = (select id from TreeNames where name = \'" + cur_compat.tree2+ "\')"
	Globals.db.query(q)
	 
	print(Globals.db.error_message)
	if(Globals.db.error_message == "not an error"):
		cur_compat.compat = float(edit_compat.text)

func add_new_compat():
	if selected_tree_1.get_selected_id() == -1 or selected_tree_2.get_selected_id() == -1:
		return
	var tree1 = selected_tree_1.get_item_text(selected_tree_1.get_selected_id())
	var tree2 = selected_tree_2.get_item_text(selected_tree_2.get_selected_id())
	if tree1 == tree2 or add_new_compat_value.text.is_empty():
		return
	 
	Globals.db.query("select id from TreeNames where name = \'" + tree1 +  "\'")
	var tree1id = Globals.db.query_result[0]["ID"]
	Globals.db.query("select id from TreeNames where name = \'" + tree2 +  "\'")
	var tree2id = Globals.db.query_result[0]["ID"]
	if tree1id > tree2id:
		var tmp = tree2id
		tree2id = tree1id
		tree1id = tmp
	var q = "insert into TreesCompatibility values (" + str(tree1id) + ", " + str(tree2id) + ", " + add_new_compat_value.text + ")"
	Globals.db.query(q)
	 
	print(Globals.db.error_message)
	if(Globals.db.error_message == "not an error"):
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

func delete_compat():
	if cur_compat == null:
		return
	 
	Globals.db.query("delete from TreesCompatibility where tree1 = (select id from TreeNames where name = \'" + cur_compat.tree1+ "\') and tree2 = (select id from TreeNames where name = \'" + cur_compat.tree2+ "\')")
	 
	if( Globals.db.error_message == "not an error"):
		compatibilities.remove_child(cur_compat)
		cur_compat.queue_free()
		edit_compat.clear()
