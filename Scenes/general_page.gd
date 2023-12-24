extends Control

@onready var tables: ItemList = %Tables
@onready var output: RichTextLabel = %Output
@onready var criterion: OptionButton = $"HSplitContainer/Right/MarginContainer/VBoxContainer/Сriterion"
@onready var line_edit: LineEdit = $HSplitContainer/Right/MarginContainer/VBoxContainer/LineEdit

var Tables = {
	Cities = "Посмотреть города",
	Plantation = "Посмотреть насаждения",
	Trees = "Посмотреть деревья",
}

var criterion_to_column_name = {
	"Вид дерева" = "TreeID",
	"Номер насаждения" = "PlantationID",
	"Координаты" = "Coords",
	"Дата посадки" = "PlantDate",
	"Дата вырубки" = "CutDate",
}

func _ready() -> void:
	for table in Tables.values():
		tables.add_item(table)


func _on_tables_item_selected(index: int) -> void:
	 
	match Tables.find_key(tables.get_item_text(index)):
		"Cities":
			Globals.db.query("select * from cities")
			output.clear()
			output.append_text("[b]Города[/b]\n")
			for row in Globals.db.query_result:
				output.append_text("[b]"+str(row["ID"]) +". Название: " + row["Name"] + "[/b]\nПлощадь: "+str(row["Area"]) + "\n")
		"Plantation":
			Globals.db.query("select p.id ID, p.name Name, c.name Город from Plantation p join Cities c on c.id=p.cityid")
			output.clear()
			output.append_text("[b]Насаждения[/b]\n")
			for row in Globals.db.query_result:
				output.append_text("[b]"+str(row["ID"]) +". Название: " + row["Name"] + "[/b]\nГород: "+str(row["Город"]) + "\n")
		
		"Trees":
			Globals.db.query("select t.id ID, t.Name Name, tn.name TreeName, p.name Plantation, t.coords Coords, PlantDate, CutDate, tp.Photo Photo from Trees t left outer join treenames tn on t.treeid=tn.id left outer join Plantation p on p.ID=t.PlantationID left outer join TreePhotos tp on tp.ID=t.ID order by t.id, t.plantationid, plantdate")
			#Globals.db.query("select * from trees")
			output.clear()
			output.append_text("[b]Деревья[/b]\n")
			for row in Globals.db.query_result:
				# слишком сложно, хз как добавить
				#if row["Photo"] != null:
					#var ph = Image.new()
					#var a = row["Photo"]
					#if a is PackedByteArray:
						#ph.load_png_from_buffer(row["Photo"])
						#var tex = ImageTexture.create_from_image(ph)
				output.append_text("[b]"+str(row["ID"]) +". Название: " + str(row["Name"]) + "[/b]\nВид дерева: "+str(row["TreeName"]) + "\nНасаждение: "+str(row["Plantation"]) + "\nКоординаты: "+str(row["Coords"]) + "\nДата посадки: "+str(row["PlantDate"]) + "\nДата вырубки: "+str(row["CutDate"] if row["CutDate"] != null else "Не вырублено") + "\nКартинка: [img=200x200]res://Assets/pine-tree.png[/img]\n" )
		
	#Globals.db.query("SELECT name FROM PRAGMA_TABLE_INFO('" + tables.get_item_text(index) + "')")
	 
	print(Globals.db.query_result.size())
	


func _on_button_pressed() -> void:
	if(criterion.get_selected_id() == -1 or criterion.get_selected_id() >= criterion.item_count):
		return
	 
	var criteria = criterion_to_column_name[criterion.get_item_text(criterion.get_selected_id())]
	var quotas = criteria != "PlantDate" and criteria != "CutDate" and criteria != "Coords"
	var info_search = ("" if quotas else "\'") + line_edit.text + ("" if quotas else "\'")
	info_search = info_search.strip_escapes().strip_edges().replace(" ", ";")
	Globals.db.query("select t.id ID, t.Name Name, tn.name TreeName, p.name Plantation, t.coords Coords, PlantDate, CutDate from Trees t left outer join treenames tn on t.treeid=tn.id left outer join Plantation p on p.ID=t.PlantationID where " + criteria + " = " + info_search + " order by t.id, t.plantationid, plantdate ")
	print(Globals.db.query_result)
	print(Globals.db.error_message)
	 
	output.clear()
	if(Globals.db.error_message != "not an error"):
		output.append_text("[b]Ошибка! "+Globals.db.error_message+"[/b]\n")
	else:
		if Globals.db.query_result.size() == 0:
			output.append_text("Нет результов")
		for row in Globals.db.query_result:
			output.append_text("[b]"+str(row["ID"]) +". Название: " + row["Name"] + "[/b]\nВид дерева: "+str(row["TreeName"]) + "\nНасаждение: "+str(row["Plantation"]) + "\nКоординаты: "+str(row["Coords"]) + "\nДата посадки: "+str(row["PlantDate"]) + "\nДата вырубки: "+str(row["CutDate"] if row["CutDate"] != null else "Не вырублено") + "\n")
			


func _on_line_edit_gui_input(event: InputEvent) -> void:
	if event.is_pressed() and event is InputEventKey and event.keycode == KEY_ENTER:
		_on_button_pressed()


func _on_exit_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/admin_panel.tscn")
