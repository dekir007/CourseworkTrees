extends HBoxContainer

@onready var options: VBoxContainer = %Options
@onready var plant_edit: TextEdit = $Editing/PlantEdit
@onready var submit_change: CoolButton = $Editing/SubmitChange
@onready var add_new_plant: TextEdit = $Editing/AddNewPlant
@onready var submit_new_plant: CoolButton = $Editing/SubmitNewPlant
@onready var delete_btn: CoolButton = $Editing/DeleteBtn
@onready var selected_city: OptionButton = $Editing/SelectedCity

@onready var plant_name_scene = preload("res://Objects/name_option.tscn")

var cur_option : NameOption :
	set = set_cur_option

func _ready() -> void:
	submit_change.btn.button_up.connect(submit_plant_change)
	submit_new_plant.btn.button_up.connect(add_new_name)
	delete_btn.btn.button_up.connect(delete_name)
	
	show_plantations()

func show_plantations():
	Globals.db.query("select p.name as name, c.name as city from Plantation p join Cities c on p.CityID=c.id")
	for option in options.get_children():
		option.queue_free()
	for row in Globals.db.query_result:
		var tree_name : NameOption =  plant_name_scene.instantiate()
		options.add_child(tree_name)
		tree_name.text = row["name"] + "; " + row["city"]
		tree_name.btn.button_up.connect(
			func(): 
				cur_option = tree_name
				print("anon func changed cur_option: " + cur_option.text)
				)
	Globals.db.query("select name from Cities")
	selected_city.clear()
	for row in Globals.db.query_result:
		selected_city.add_item(row["Name"])
	

func submit_plant_change():
	if cur_option == null or cur_option.text == plant_edit.text or plant_edit.text.is_empty():
		return
	var split = cur_option.text.split(';')
	var plant_name = split[0]
	var city_name = split[1].strip_edges()
	var q = "update Plantation set name = \'" + plant_edit.text + "\' where name = \'" + plant_name + "\'"
	Globals.db.query(q)
	 
	print(Globals.db.error_message)
	if(Globals.db.error_message == "not an error"):
		cur_option.text = plant_edit.text + "; " + city_name

func add_new_name():
	if add_new_plant.text.is_empty() or selected_city.text.is_empty():
		return
	 
	var q = "insert into Plantation(Name, CityID) values (\'" + add_new_plant.text +  "\', (select id from Cities where name = \'" + selected_city.text +"\'))"
	Globals.db.query(q)
	 
	print(Globals.db.error_message)
	if(Globals.db.error_message == "not an error"):
		var tree_name : NameOption =  plant_name_scene.instantiate()
		options.add_child(tree_name)
		tree_name.text = add_new_plant.text + "; " + selected_city.text
		tree_name.btn.button_up.connect(
			func(): 
				cur_option = tree_name
				print("anon func changed cur_option: " + cur_option.text)
				)
		add_new_plant.clear()

func delete_name():
	if cur_option == null:
		return
	 
	Globals.db.query("delete from Plantation where name = \'" + cur_option.text.split(';')[0] + "\'")
	 
	if(Globals.db.error_message == "not an error"):
		options.remove_child(cur_option)
		cur_option.queue_free()
		plant_edit.clear()

func set_cur_option(new_opt : NameOption):
	if cur_option != null:
		cur_option.btn.set_pressed_no_signal(false)
	cur_option = new_opt
	plant_edit.text = cur_option.text.split(';')[0]
