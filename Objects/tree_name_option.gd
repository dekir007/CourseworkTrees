extends PanelContainer
class_name TreeNameOption

@export var text : String :
	set(value):
		if label != null:
			label.text = value
		text = value

@onready var btn: Button = $NamesBtn
@onready var label: Label = $Label

#func _ready() -> void:
	#label.text = text
