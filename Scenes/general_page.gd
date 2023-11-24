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

var db := SQLite.new()

func _ready() -> void:
	db.path = "E:\\DataBases\\trees.sqlite"
	for table in Tables.values():
		tables.add_item(table)


func _on_tables_item_selected(index: int) -> void:
	db.open_db()
	match Tables.find_key(tables.get_item_text(index)):
		"Cities":
			db.query("select * from cities")
			output.clear()
			output.append_text("[b]Города[/b]\n")
			for row in db.query_result:
				output.append_text("[b]"+str(row["ID"]) +". Название: " + row["Name"] + "[/b]\nПлощадь: "+str(row["Area"]) + "\n")
		"Plantation":
			db.query("select p.id ID, p.name Name, c.name Город from Plantation p join Cities c on c.id=p.cityid")
			output.clear()
			output.append_text("[b]Насаждения[/b]\n")
			for row in db.query_result:
				output.append_text("[b]"+str(row["ID"]) +". Название: " + row["Name"] + "[/b]\nГород: "+str(row["Город"]) + "\n")
		
		"Trees":
			db.query("select t.id ID, t.Name Name, tn.name TreeName, p.name Plantation, t.coords Coords, PlantDate, CutDate from Trees t left outer join treenames tn on t.treeid=tn.id left outer join Plantation p on p.ID=t.PlantationID order by t.id, t.plantationid, plantdate")
			#db.query("select * from trees")
			output.clear()
			output.append_text("[b]Деревья[/b]\n")
			for row in db.query_result:
				#output.append_text(str(row)+"\n")
				output.append_text("[b]"+str(row["ID"]) +". Название: " + row["Name"] + "[/b]\nВид дерева: "+str(row["TreeName"]) + "\nНасаждение: "+str(row["Plantation"]) + "\nКоординаты: "+str(row["Coords"]) + "\nДата посадки: "+str(row["PlantDate"]) + "\nДата вырубки: "+str(row["CutDate"] if row["CutDate"] != null else "Не вырублено") + "\n")
		
	#db.query("SELECT name FROM PRAGMA_TABLE_INFO('" + tables.get_item_text(index) + "')")
	db.close_db()
	print(db.query_result.size())
	


func _on_button_pressed() -> void:
	if(criterion.get_selected_id() == -1 or criterion.get_selected_id() >= criterion.item_count):
		return
	db.open_db()
	var criteria = criterion_to_column_name[criterion.get_item_text(criterion.get_selected_id())]
	var quotas = criteria != "PlantDate" and criteria != "CutDate" and criteria != "Coords"
	var info_search = ("" if quotas else "\'") + line_edit.text + ("" if quotas else "\'")
	info_search = info_search.strip_escapes().strip_edges().replace(" ", ";")
	db.query("select t.id ID, t.Name Name, tn.name TreeName, p.name Plantation, t.coords Coords, PlantDate, CutDate from Trees t left outer join treenames tn on t.treeid=tn.id left outer join Plantation p on p.ID=t.PlantationID where " + criteria + " = " + info_search + " order by t.id, t.plantationid, plantdate ")
	print(db.query_result)
	print(db.error_message)
	db.close_db()
	output.clear()
	if(db.error_message != "not an error"):
		output.append_text("[b]Ошибка! "+db.error_message+"[/b]\n")
	else:
		if db.query_result.size() == 0:
			output.append_text("Нет результов")
		for row in db.query_result:
			output.append_text("[b]"+str(row["ID"]) +". Название: " + row["Name"] + "[/b]\nВид дерева: "+str(row["TreeName"]) + "\nНасаждение: "+str(row["Plantation"]) + "\nКоординаты: "+str(row["Coords"]) + "\nДата посадки: "+str(row["PlantDate"]) + "\nДата вырубки: "+str(row["CutDate"] if row["CutDate"] != null else "Не вырублено") + "\n")
			


func _on_line_edit_gui_input(event: InputEvent) -> void:
	if event.is_pressed() and event is InputEventKey and event.keycode == KEY_ENTER:
		_on_button_pressed()


func _on_exit_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/admin_panel.tscn")
