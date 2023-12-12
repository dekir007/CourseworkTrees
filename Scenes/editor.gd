extends Node2D

const ADD_TREE_QUERY_BOX = preload("res://Objects/add_tree_query_box.tscn")
const TREE_SILHOUETTE = preload("res://Assets/tree-silhouette.png")

@onready var tmp: Node2D = $tmp

var db : SQLite = SQLite.new()
var tree_kind_names : Array[String]
var plantation_names : Array[String]

func _ready() -> void:
	db.path = "res://trees.sqlite"
	update_tree_kind_names()
	update_plantation_names()

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
	print(args.tree_name, args.coords)
	
	# db adding
	
	if db.error_message != "not an error":
		# TODO show box
		return
	
	args.sender.queue_free()
	
	var spr = Sprite2D.new()
	spr.texture = TREE_SILHOUETTE
	var coords = args.coords.split(";")
	spr.global_position = Vector2(int(coords[0]), int(coords[1]))
	spr.scale /= 10
	tmp.add_child(spr)
