extends Control

@onready var cool_button: CoolButton = $UI/CoolButton

func _ready() -> void:
	cool_button.btn.button_up.connect(func():
		get_tree().change_scene_to_file("res://Scenes/admin_panel.tscn")
		)
