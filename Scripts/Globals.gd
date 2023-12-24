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

func get_backgrounds(city_id:int) -> Array:
	db.query("SELECT ID, Background FROM Backgrounds WHERE CityID = " + str(city_id) + ";")
	await  get_tree().create_timer(1).timeout
	if db.error_message != "not an error":
		return []
	var pics = []
	for row in db.query_result:
		if row["Background"] == null:
			continue
		var ph = Image.new()
		var a = row["Background"]
		#if a is String:
			#a = a.to_utf8_buffer()
		if a is PackedByteArray:
			ph.load_png_from_buffer(a)
			ph.save_png("res://Cache/background-" + str(row["ID"]) + "-"+str(city_id))
			pics.append(ImageTexture.create_from_image(ph))
	return pics
