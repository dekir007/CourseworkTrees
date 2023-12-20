extends Node

var db : SQLite

func _ready() -> void:
	db = SQLite.new()
	db.path = "res://trees.sqlite"
	db.foreign_keys = true
	db.open_db()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		db.close_db()
		get_tree().quit()
