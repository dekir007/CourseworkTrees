extends PanelContainer
class_name NameOption

@export var text : String :
	set(value):
		if label != null:
			label.text = value
		text = value

@onready var btn: Button = $NamesBtn
@onready var label: Label = $Label
