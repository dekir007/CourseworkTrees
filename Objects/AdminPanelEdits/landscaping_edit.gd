extends HBoxContainer

@onready var options: VBoxContainer = %Options
@onready var selected_city_edit: OptionButton = $Editing/SelectedCityEdit
@onready var pop_edit: TextEdit = $Editing/PopEdit
@onready var percentage_edit: TextEdit = $Editing/HBoxContainer/PercentageEdit
@onready var calc_percent_btn: = $Editing/HBoxContainer/CalcPercentBtn as CoolButton
@onready var day_input: TextEdit = $Editing/DateInput/DayInput
@onready var month_input: OptionButton = $Editing/DateInput/MonthInput
@onready var year_input: TextEdit = $Editing/DateInput/YearInput
@onready var submit_change: = $Editing/SubmitChange as CoolButton
@onready var add_new_landscape_btn: = $Editing/AddNewLandscape as CoolButton
@onready var delete_btn: = $Editing/DeleteBtn as CoolButton


@onready var landscape_scene = preload("res://Objects/landscape_option.tscn")

var cur_option : LandscapeOption :
	set = set_cur_option

func _ready() -> void:
	calc_percent_btn.btn.button_up.connect(calc_percent)
	submit_change.btn.button_up.connect(submit_landscape_edit)
	add_new_landscape_btn.btn.button_up.connect(add_new_landscape)
	delete_btn.btn.button_up.connect(delete_landscape)
	
	show_landscaping()

func show_landscaping():
	Globals.db.query("select *, cl.ID as clID from CityLandscaping cl join Cities c on c.ID=cl.CityID")
	for option in options.get_children():
		option.queue_free()
	for row in Globals.db.query_result:
		var landscape : =  landscape_scene.instantiate() as LandscapeOption
		options.add_child(landscape)
		landscape.id = row["clID"]
		landscape.city = row["Name"]
		landscape.population = row["Population"]
		landscape.date = row["Date"]
		landscape.greenery_percentage = row["GreeneryPercentage"]
		landscape.btn.button_up.connect(
			func(): 
				cur_option = landscape
				print("anon func changed cur_option: " + cur_option.label.text)
				)
	
	Globals.db.query("select name from Cities")
	selected_city_edit.clear()
	for row in Globals.db.query_result:
		selected_city_edit.add_item(row["Name"])
	selected_city_edit.select(-1)

func calc_percent():
	pass

func submit_landscape_edit():
	if (cur_option == null 
		or selected_city_edit.get_selected_id() == -1 
		or pop_edit.text.is_empty()
		or percentage_edit.text.is_empty()
		or day_input.text.is_empty()
		or month_input.get_selected_id() == -1
		or year_input.text.is_empty()):
		return
	var q = "update CityLandscaping set CityID = (select id from Cities where name = \'"+ selected_city_edit.text +"\'), date = \'" + get_input_date() + "\', population = " + str(pop_edit.text) + ", GreeneryPercentage = " + str(percentage_edit.text) + " where id = " + str(cur_option.id)
	Globals.db.query(q)
	
	print(Globals.db.error_message)
	if(Globals.db.error_message == "not an error"):
		cur_option.city = selected_city_edit.text
		cur_option.greenery_percentage = float(percentage_edit.text)
		cur_option.population = int(pop_edit.text)
		cur_option.date = get_input_date()

func add_new_landscape():
	if (selected_city_edit.get_selected_id() == -1 
		or pop_edit.text.is_empty()
		or percentage_edit.text.is_empty()
		or day_input.text.is_empty()
		or month_input.get_selected_id() == -1
		or year_input.text.is_empty()):
		return
	
	var q = "insert into CityLandscaping(CityID, Date, Population, GreeneryPercentage) values ((select id from Cities where name = \'"+ selected_city_edit.text +"\'), \'" + get_input_date() + "\', " + str(pop_edit.text) + ", " + str(percentage_edit.text) + ")"
	Globals.db.query(q)
	
	if(Globals.db.error_message == "not an error"):
		var landscape : =  landscape_scene.instantiate() as LandscapeOption
		options.add_child(landscape)
		Globals.db.query("select last_insert_rowid()")
		landscape.id = Globals.db.query_result[0].values()[0]
		landscape.city = selected_city_edit.text
		landscape.population = int(pop_edit.text)
		landscape.date = get_input_date()
		landscape.greenery_percentage = float(percentage_edit.text)
		landscape.btn.button_up.connect(
			func(): 
				cur_option = landscape
				print("anon func changed cur_option: " + cur_option.label.text)
				)
		cur_option = null
	
	

func delete_landscape():
	if cur_option == null:
		return
	 
	Globals.db.query("delete from CityLandscaping where id = " + str(cur_option.id))
	 
	if(Globals.db.error_message == "not an error"):
		options.remove_child(cur_option)
		cur_option.queue_free()
		cur_option = null
		#city_name_edit.clear()
		#area_edit.clear()

func get_input_date():
	return year_input.text +"-"+str(month_input.get_selected_id()+1).lpad(2, "0") +"-"+day_input.text.lpad(2, "0")

func set_cur_option(new_opt : LandscapeOption):
	if cur_option != null:
		cur_option.btn.set_pressed_no_signal(false)
	if new_opt == null:
		pop_edit.clear()
		selected_city_edit.select(-1)
		percentage_edit.clear()
		day_input.clear()
		month_input.select(0)
		year_input.clear()
	else:
		cur_option = new_opt
		pop_edit.text = str(cur_option.population)
		# костыль
		for i in range(0, selected_city_edit.get_popup().item_count):
			if selected_city_edit.get_item_text(i) == cur_option.city:
				selected_city_edit.select(i)
				break
		
		percentage_edit.text = str(cur_option.greenery_percentage)
		day_input.text = cur_option.date.right(2)
		month_input.select(int(cur_option.date.substr(5,2))-1) 
		year_input.text = cur_option.date.left(4)
