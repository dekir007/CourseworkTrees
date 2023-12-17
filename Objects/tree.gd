extends Node2D

@export var tree : Dictionary

const CHANGE_TREE_BOX = preload("res://Objects/change_tree_box.tscn")

func _ready() -> void:
	var coords = tree["Coords"].split(";")
	global_position = Vector2(int(coords[0]), int(coords[1]))

func _on_button_button_up() -> void:
	print(tree)
	var tree_box = CHANGE_TREE_BOX.instantiate()
	tree_box.tree = tree
	var editor = get_parent().get_parent()
	tree_box.names = editor.tree_kind_names
	tree_box.plantation_names = editor.plantation_names
	tree_box.global_position = global_position
	tree_box.tree_node = self
	tree_box.query.connect(editor.handle_change_tree_box)
	editor.tmp.add_child(tree_box)
