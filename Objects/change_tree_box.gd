extends Control
class_name ChangeTreeBox

signal query(tree_args : ChangeArgs)

@onready var cool_button: CoolButton = $Panel/MarginContainer/VBoxContainer/HBoxContainer3/CoolButton as CoolButton
@onready var tree_name: TextEdit = $Panel/MarginContainer/VBoxContainer/HBoxContainer2/TreeName
@onready var tree_kind: OptionButton = $Panel/MarginContainer/VBoxContainer/TreeKind
@onready var coords_input: TextEdit = $Panel/MarginContainer/VBoxContainer/CoordsInput
@onready var plantation: OptionButton = $Panel/MarginContainer/VBoxContainer/Plantation
@onready var day_input: TextEdit = $Panel/MarginContainer/VBoxContainer/PlantDate/DayInput
@onready var month_input: OptionButton = $Panel/MarginContainer/VBoxContainer/PlantDate/MonthInput
@onready var year_input: TextEdit = $Panel/MarginContainer/VBoxContainer/PlantDate/YearInput
@onready var delete_btn: CoolButton = $Panel/MarginContainer/VBoxContainer/HBoxContainer3/DeleteBtn
@onready var cut_day_input: TextEdit = $Panel/MarginContainer/VBoxContainer/CutDate/DayInput
@onready var cut_month_input: OptionButton = $Panel/MarginContainer/VBoxContainer/CutDate/MonthInput
@onready var cut_year_input: TextEdit = $Panel/MarginContainer/VBoxContainer/CutDate/YearInput


@export var tree : Dictionary

var tree_node : Node2D

var names : Array[String]
var plantation_names : Array[String]

func _ready() -> void:
	cool_button.btn.button_up.connect(func():
		var args = ChangeArgs.new()
		args.tree = tree
		args.tree_name = tree_name.text
		args.tree_kind = tree_kind.text
		args.coords = coords_input.text
		
		args.plant_date = year_input.text +"-"+str(month_input.get_selected_id()+1).lpad(2, "0") +"-"+day_input.text.lpad(2, "0")
		if !cut_year_input.text.is_empty() and !cut_day_input.text.is_empty() and cut_month_input.get_selected_id()!=-1:
			args.cut_date = cut_year_input.text +"-"+str(cut_month_input.get_selected_id()+1).lpad(2, "0") +"-"+cut_day_input.text.lpad(2, "0")
		args.plantation = plantation.text
		args.sender = self
		query.emit(args)
		)
	delete_btn.btn.button_up.connect(func():
		var args = ChangeArgs.new()
		args.tree = tree
		args.delete=true
		args.sender = self
		query.emit(args)
		)
	tree_kind.clear()
	for tree in names:
		tree_kind.add_item(tree)
	
	plantation.clear()
	for plantation_name in plantation_names:
		plantation.add_item(plantation_name)
	
	tree_name.text = tree["Name"]
	tree_kind.select(tree["TreeID"]-1)
	plantation.select(tree["PlantationID"]-1)
	
	coords_input.text = tree["Coords"]
	
	day_input.text = tree["PlantDate"].right(2)
	month_input.select(int(tree["PlantDate"].substr(5,2))-1) 
	year_input.text = tree["PlantDate"].left(4)
	if tree["CutDate"] != null:
		cut_day_input.text = tree["CutDate"].right(2)
		cut_month_input.select(int(tree["CutDate"].substr(5,2))-1) 
		cut_year_input.text = tree["CutDate"].left(4)

class ChangeArgs:
	var sender : ChangeTreeBox
	var delete : bool = false
	var tree:Dictionary
	var tree_name:String
	var tree_kind:String
	var plantation:String
	var coords:String
	var plant_date:String
	var cut_date:String

func _on_button_button_up() -> void:
	queue_free()
