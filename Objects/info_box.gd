extends Control
class_name InfoBox

@onready var cool_button: CoolButton = $PanelContainer/MarginContainer/VBoxContainer/CoolButton as CoolButton
@onready var label: Label = $PanelContainer/MarginContainer/VBoxContainer/Label

var text : String

func _ready() -> void:
	label.text = text
	cool_button.btn.button_up.connect(queue_free)


func _on_timer_timeout() -> void:
	queue_free()
