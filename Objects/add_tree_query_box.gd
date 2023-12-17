extends Control
class_name AddTreeQueryBox

signal query(tree_args : TreeArgs)

@onready var cool_button: CoolButton = $Panel/MarginContainer/VBoxContainer/CoolButton as CoolButton
@onready var tree_name: TextEdit = $Panel/MarginContainer/VBoxContainer/HBoxContainer2/TreeName
@onready var tree_kind: OptionButton = $Panel/MarginContainer/VBoxContainer/TreeKind
@onready var coords_input: TextEdit = $Panel/MarginContainer/VBoxContainer/CoordsInput
@onready var plantation: OptionButton = $Panel/MarginContainer/VBoxContainer/Plantation
@onready var day_input: TextEdit = $Panel/MarginContainer/VBoxContainer/HBoxContainer/DayInput
@onready var month_input: OptionButton = $Panel/MarginContainer/VBoxContainer/HBoxContainer/MonthInput
@onready var year_input: TextEdit = $Panel/MarginContainer/VBoxContainer/HBoxContainer/YearInput

var names : Array[String]
var plantation_names : Array[String]

func _ready() -> void:
	cool_button.btn.button_up.connect(func():
		var args = TreeArgs.new()
		args.tree_name = tree_name.text
		args.tree_kind = tree_kind.text
		args.coords = coords_input.text
		
		args.plant_date = year_input.text +"-"+str(month_input.get_selected_id()+1).lpad(2, "0") +"-"+day_input.text.lpad(2, "0")
		args.plantation = plantation.text
		args.sender = self
		query.emit(args)
		)
	
	tree_kind.clear()
	for tree in names:
		tree_kind.add_item(tree)
	
	plantation.clear()
	for plantation_name in plantation_names:
		plantation.add_item(plantation_name)
	
	coords_input.text = str(int(global_position.x))+";"+str(int(global_position.y))
	
	var date = Time.get_date_dict_from_system()
	day_input.text = str(date["day"])
	month_input.select(date["month"] - 1) 
	year_input.text = str(date["year"])

class TreeArgs:
	var sender : AddTreeQueryBox
	var tree_name:String
	var tree_kind:String
	var plantation:String
	var coords:String
	var plant_date:String

func _on_button_button_up() -> void:
	queue_free()
