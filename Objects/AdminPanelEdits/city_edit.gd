extends HBoxContainer

@onready var options: VBoxContainer = %Options
@onready var city_name_edit: TextEdit = $Editing/HBoxContainer/CityNameEdit
@onready var area_edit: TextEdit = $Editing/HBoxContainer/AreaEdit
@onready var submit_change: CoolButton = $Editing/SubmitChange
@onready var new_city_name: TextEdit = $Editing/HBoxContainer2/NewCityName
@onready var new_city_area: TextEdit = $Editing/HBoxContainer2/NewCityArea
@onready var add_new_city_btn: CoolButton = $Editing/AddNewCity
@onready var delete_btn: CoolButton = $Editing/DeleteBtn

@onready var city_scene = preload("res://Objects/name_option.tscn")

var cur_option : NameOption :
	set = set_cur_option

func _ready() -> void:
	submit_change.btn.button_up.connect(submit_city_change)
	add_new_city_btn.btn.button_up.connect(add_new_city)
	delete_btn.btn.button_up.connect(delete_name)
	
	show_cities()

func show_cities():
	Globals.db.query("select name, area from Cities")
	for option in options.get_children():
		option.queue_free()
	for row in Globals.db.query_result:
		var tree_name : NameOption =  city_scene.instantiate()
		options.add_child(tree_name)
		tree_name.text = row["Name"] + "; " + str(row["Area"])
		tree_name.btn.button_up.connect(
			func(): 
				cur_option = tree_name
				print("anon func changed cur_option: " + cur_option.text)
				)
	

func submit_city_change():
	if cur_option == null or cur_option.text == (city_name_edit.text + "; " + area_edit.text) or city_name_edit.text.is_empty() or area_edit.text.is_empty():
		return
	var split = cur_option.text.split(';')
	var city_name = split[0]
	var area = split[1].strip_edges()
	var q = "update Cities set name = \'" + city_name_edit.text + "\', area = " + area_edit.text + " where name = \'" + city_name + "\'"
	Globals.db.query(q)
	 
	print(Globals.db.error_message)
	if(Globals.db.error_message == "not an error"):
		cur_option.text = city_name_edit.text + "; " + area_edit.text

func add_new_city():
	if new_city_name.text.is_empty() or new_city_area.text.is_empty():
		return
	 
	var q = "insert into Cities(Name, Area) values (\'" + new_city_name.text +  "\', " + new_city_area.text + ")"
	Globals.db.query(q)
	 
	print(Globals.db.error_message)
	if(Globals.db.error_message == "not an error"):
		var city : NameOption =  city_scene.instantiate()
		options.add_child(city)
		city.text = new_city_name.text + "; " + new_city_area.text
		city.btn.button_up.connect(
			func(): 
				cur_option = city
				print("anon func changed cur_option: " + cur_option.text)
				)
		new_city_name.clear()
		new_city_area.clear()

func delete_name():
	if cur_option == null:
		return
	 
	Globals.db.query("delete from Cities where name = \'" + cur_option.text.split(';')[0] + "\'")
	 
	if(Globals.db.error_message == "not an error"):
		options.remove_child(cur_option)
		cur_option.queue_free()
		city_name_edit.clear()
		area_edit.clear()

func set_cur_option(new_opt : NameOption):
	if cur_option != null:
		cur_option.btn.set_pressed_no_signal(false)
	cur_option = new_opt
	var split = cur_option.text.split(';')
	city_name_edit.text = split[0]
	area_edit.text = split[1]


