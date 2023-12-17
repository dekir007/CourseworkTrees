extends Node2D

const ADD_TREE_QUERY_BOX = preload("res://Objects/add_tree_query_box.tscn")
const TREE_SILHOUETTE = preload("res://Assets/tree-silhouette.png")
const INFO_BOX = preload("res://Objects/info_box.tscn")
const TREE = preload("res://Objects/tree.tscn")

@onready var tmp: Node2D = $tmp

var db : SQLite = SQLite.new()
var tree_kind_names : Array[String]
var plantation_names : Array[String]

func _ready() -> void:
	db.path = "res://trees.sqlite"
	update_tree_kind_names()
	update_plantation_names()
	
	plant_trees()

func _process(delta: float) -> void:
	$Label.text = str(get_global_mouse_position())
	$Label.global_position = (get_global_mouse_position()) + Vector2(10,0)

func update_tree_kind_names():
	db.open_db()
	db.query("select Name from TreeNames")
	db.close_db()
	tree_kind_names.clear()
	for row in db.query_result:
		tree_kind_names.append(row["Name"])

func update_plantation_names():
	db.open_db()
	db.query("select Name from Plantation")
	db.close_db()
	plantation_names.clear()
	for row in db.query_result:
		plantation_names.append(row["Name"])

func plant_trees():
	db.open_db()
	db.query("select * from trees")
	db.close_db()
	for row in db.query_result:
		var tree = TREE.instantiate()
		tree.tree = row
		tmp.add_child(tree)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.double_click and event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_click = get_global_mouse_position()
			var query_box = ADD_TREE_QUERY_BOX.instantiate()
			query_box.query.connect(handle_query_box)
			query_box.global_position = mouse_click
			query_box.names = tree_kind_names
			query_box.plantation_names = plantation_names
			tmp.add_child(query_box)

func handle_query_box(args : AddTreeQueryBox.TreeArgs):
	print(args.tree_name, args.coords, args.plantation, args.tree_kind)
	
	# db adding
	if args.tree_name.is_empty():
		args.tree_name = "Дерево " + args.coords
	db.open_db()
	var q = "insert into Trees(Name, TreeID, PlantationID, Coords, PlantDate) values(\"" + args.tree_name + "\",(select id from treenames where name = \"" + args.tree_kind + "\")" + ", (select id from Plantation where name =\"" + args.plantation + "\"),\"" + args.coords + "\",\"" + args.plant_date + "\")"
	db.query(q)
	#db.close_db()
	# select id from treenames where name = args.tree_kind
	# select id from plantation where name = args.tree_kind
	if db.error_message != "not an error":
		db.close_db()
		show_info_box(db.error_message)
		return
	
	show_info_box("Успех!")
	
	args.sender.queue_free()
	
	db.query("select last_insert_rowid()")
	var id = db.query_result[0].values()[0]
	db.query("select * from trees where id = " + str(id))
	var row = db.query_result
	db.close_db()
	
	var tree = TREE.instantiate()
	tree.tree = row[0]
	tmp.add_child(tree)

func handle_change_tree_box(args : ChangeTreeBox.ChangeArgs):
	if args.delete:
		db.open_db()
		db.query("delete from trees where id = " + str(args.tree["ID"]))
		if db.error_message != "not an error":
			show_info_box(db.error_message)
		else:
			show_info_box("Успешно удалено")
			args.sender.tree_node.queue_free()
			args.sender.queue_free()
		return
	
	var q = "update trees set Name = \""+args.tree_name+"\", TreeID = (select id from treenames where name = \"" + args.tree_kind + "\")" + ", PlantationID = (select id from Plantation where name =\"" + args.plantation + "\"),Coords = \"" + args.coords + "\", PlantDate = \"" + args.plant_date + "\"" + (", CutDate = \"" + args.cut_date + "\"" if !args.cut_date.is_empty() else "") + " where id = " + str(args.tree["ID"])
	print(q)
	db.open_db()
	db.query(q)
	if db.error_message != "not an error":
			show_info_box(db.error_message)
	else:
		show_info_box("Успешно изменено")
		db.query("select * from trees where id = " + str(args.tree["ID"]))
		args.sender.tree_node.tree = db.query_result[0]
		args.sender.queue_free()
	
	db.close_db()

func show_info_box(text:String, pos:Vector2 = get_global_mouse_position()):
	var info_box = INFO_BOX.instantiate()
	info_box.text = text
	info_box.global_position = pos
	tmp.add_child(info_box)
