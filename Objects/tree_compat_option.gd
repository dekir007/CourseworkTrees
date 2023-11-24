extends PanelContainer
class_name TreeCompatOption

@export var tree1 : String:
	set(value):
		tree1 = value
		if label!=null:
			label.text = "Совместимость " + tree1 + " и " + tree2 + " = " + str(compat)
@export var tree2 : String:
	set(value):
		tree2 = value
		if label!=null:
			label.text = "Совместимость " + tree1 + " и " + tree2 + " = " + str(compat)
@export var compat : float :
	set(value):
		compat = value
		if label!=null:
			label.text = "Совместимость " + tree1 + " и " + tree2 + " = " + str(compat)

@onready var label: Label = $Label
@onready var btn: Button = $Button

func _ready() -> void:
	label.text = "Совместимость " + tree1 + " и " + tree2 + " = " + str(compat)
