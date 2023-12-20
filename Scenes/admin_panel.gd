extends PanelContainer

const TREE_NAME_EDIT = preload("res://Objects/tree_name_edit.tscn")
const TREE_COMPAT_EDIT = preload("res://Objects/tree_compat_edit.tscn")
const PLANTATION_EDIT = preload("res://Objects/plantation_edit.tscn")

@onready var left: Control = $HBoxContainer/Left

@onready var change_names:  = $HBoxContainer/Right/ChangeNames as CoolButton
@onready var change_compat: = $HBoxContainer/Right/ChangeCompat as CoolButton
@onready var change_plantations: CoolButton = $HBoxContainer/Right/ChangePlantations


func _ready() -> void:
	Globals.db.path = "res://trees.sqlite"
	Globals.db.foreign_keys = true
	
	change_names.btn.button_up.connect(func():
		left.get_children()[0].queue_free()
		var tree_name_edit = TREE_NAME_EDIT.instantiate()
		left.add_child(tree_name_edit)
		)
	change_compat.btn.button_up.connect(func():
		left.get_children()[0].queue_free()
		var tree_compat_edit = TREE_COMPAT_EDIT.instantiate()
		left.add_child(tree_compat_edit)
		)
	change_plantations.btn.button_up.connect(func():
		left.get_children()[0].queue_free()
		var plant_edit = PLANTATION_EDIT.instantiate()
		left.add_child(plant_edit)
		)
	
	var tree_name_edit = TREE_NAME_EDIT.instantiate()
	left.add_child(tree_name_edit)


func _on_exit_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/general_page.tscn")


func _on_in_editor_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/editor_vp_container.tscn")
