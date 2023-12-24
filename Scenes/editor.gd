extends Node2D
class_name Editor

const ADD_TREE_QUERY_BOX = preload("res://Objects/add_tree_query_box.tscn")
const TREE_SILHOUETTE = preload("res://Assets/tree-silhouette.png")
const INFO_BOX = preload("res://Objects/info_box.tscn")
const TREE = preload("res://Objects/tree.tscn")
const AREA_2D = preload("res://Objects/area_2d.tscn")

@export var cityid : int = 1

@onready var tmp: Node2D = $tmp
@onready var polygons: Node2D = $Polygons
@onready var photo: Sprite2D = $Photo

var tree_kind_names : Array[String]
var plantation_names : Array[String]

var plantation_polygons : Dictionary # key = num, val = polygon2d

func _ready() -> void:
	cityid = ProjectSettings.get_setting("global/CityID")
	update_tree_kind_names()
	update_plantation_names()
	
	plant_trees()
	print(plantation_polygons)

func _process(_delta: float) -> void:
	$Label.text = str(get_global_mouse_position())
	$Label.global_position = (get_global_mouse_position()) + Vector2(10,0)

func update_tree_kind_names():
	Globals.db.query("select Name from TreeNames")
	 
	tree_kind_names.clear()
	for row in Globals.db.query_result:
		tree_kind_names.append(row["Name"])

func update_plantation_names():
	Globals.db.query("select Name from Plantation where CityID = " + str(cityid))
	 
	plantation_names.clear()
	for row in Globals.db.query_result:
		plantation_names.append(row["Name"])

func plant_trees():
	Globals.db.query("select t.id ID, t.Name Name, t.TreeID TreeID, t.PlantationID PlantationID , t.Coords Coords, t.PlantDate PlantDate, t.CutDate CutDate from trees t join Plantation p on p.ID=t.PlantationID where p.CityID=" + str(cityid) + " order by PlantationID") #("select * from trees order by PlantationID") 
	if Globals.db.query_result.size() == 0:
		return
	var pl = Globals.db.query_result[0]["PlantationID"]
	
	var coords : Array[Vector2] = []
	for row in Globals.db.query_result:
		var tree = TREE.instantiate()
		tree.tree = row
		tmp.add_child(tree)
		
		if pl != row["PlantationID"]:
			if coords.size() > 2:
				var polygon = Polygon2D.new()
				polygon.name = "Plantation " + str(pl)
				polygon.polygon = Geometry2D.convex_hull(coords.duplicate())
				polygon.modulate.a = 0.5
				coords.clear()
				polygons.add_child(polygon)
				plantation_polygons[pl] = polygon
			pl = row["PlantationID"]
			coords.clear()
		var split = row["Coords"].split(';')
		coords.append(Vector2(int(split[0]), int(split[1])))
		if row == Globals.db.query_result.back():
			if coords.size() > 2:
				var polygon = Polygon2D.new()
				polygon.name = "Plantation " + str(pl)
				polygon.polygon = Geometry2D.convex_hull(coords.duplicate()) #hull.convexHull(coords.duplicate())
				polygon.modulate.a = 0.5
				coords.clear()
				polygons.add_child(polygon)
				plantation_polygons[pl] = polygon
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.double_click and event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_click = get_global_mouse_position()
			var query_box = ADD_TREE_QUERY_BOX.instantiate()
			query_box.query.connect(handle_query_box)
			query_box.global_position = mouse_click
			query_box.names = tree_kind_names
			query_box.plantation_names = plantation_names
			var area = AREA_2D.instantiate()
			area.global_position = mouse_click
			add_child(area)
			area.area_entered.connect(
				func(ar): 
					print("area entered ", ar.get_parent().tree)
					query_box.trees_nearby.append(ar.get_parent().tree)
					)
			query_box.tree_exiting.connect(area.queue_free)
			tmp.add_child(query_box)

func handle_query_box(args : AddTreeQueryBox.TreeArgs):
	print(args.tree_name, args.coords, args.plantation, args.tree_kind)
	
	# Globals.db adding
	if args.tree_name.is_empty():
		args.tree_name = "Дерево " + args.coords
	
	var q = "insert into Trees(Name, TreeID, PlantationID, Coords, PlantDate) values(\"" + args.tree_name + "\",(select id from treenames where name = \"" + args.tree_kind + "\")" + ", (select id from Plantation where name =\"" + args.plantation + "\"),\"" + args.coords + "\",\"" + args.plant_date + "\")"
	Globals.db.query(q)
	# 
	if Globals.db.error_message != "not an error":
		show_info_box(Globals.db.error_message)
		return
	
	var tree_nearby_ids = args.sender.trees_nearby.map(func(x): return str(x["TreeID"]))
	# удаляем бокс, забираем новые данные
	args.sender.queue_free()
	
	Globals.db.query("select last_insert_rowid()")
	var id = Globals.db.query_result[0].values()[0]
	Globals.db.query("select * from trees where id = " + str(id))
	var row = Globals.db.query_result[0].duplicate()
	var tree_kind_id = str(row["TreeID"])
	
	# садим дерево
	var tree = TREE.instantiate()
	tree.tree = row
	tmp.add_child(tree)
	
	# обновляем полигон
	
		
	# если уже есть
	if plantation_polygons.has(row["PlantationID"]):
		var pl : Polygon2D = plantation_polygons[row["PlantationID"]]
		#pl.name = "Plantation " + str(row[0]["PlantationID"])
		var points = pl.polygon.duplicate()
		var split = row["Coords"].split(';')
		points.append(Vector2(int(split[0]), int(split[1])))
		pl.polygon = Geometry2D.convex_hull(points)# hull.convexHull(points)
	else: # делаем новый
		q = "select * from trees where plantationid = " + str(row["PlantationID"])
		Globals.db.query(q)
		if Globals.db.query_result.size() >= 3:
			var points :Array[Vector2] = []
			for tree_row in Globals.db.query_result:
				var split = tree_row["Coords"].split(';')
				points.append(Vector2(int(split[0]), int(split[1])))
			var polygon = Polygon2D.new()
			polygon.name = "Plantation " + str(row["PlantationID"])
			polygon.modulate.a = 0.5
			polygon.polygon = Geometry2D.convex_hull(points) #hull.convexHull(points)
			polygons.add_child(polygon)
			plantation_polygons[row["PlantationID"]] = polygon
	
	
	#tree_nearby_ids = "(" + ", ".join(tree_nearby_ids) + ")" #1 (1,4,4)
	print(tree_nearby_ids)
	var good = 0
	var neut = 0
	var bad = 0
	for each_id in tree_nearby_ids:
		if each_id == tree_kind_id:
			neut += 1
			continue
		Globals.db.query("select Compatibility from TreesCompatibility where (tree1 = %s and tree2 = %s) or (tree2 = %s and tree1 = %s)" % [tree_kind_id, each_id, tree_kind_id, each_id])
		var v = Globals.db.query_result[0].values()
		var compat = Globals.db.query_result[0].values()[0]
		if compat == 1:
			good += 1
		elif compat == 0:
			neut += 1
		elif compat == -1:
			bad += 1
	var messenge = "Успешно добавлено\nХороших соседей: %s\nНейтральных: %s\nПлохих: %s" % [good,neut,bad]
	
	show_info_box(messenge)
	

func handle_change_tree_box(args : ChangeTreeBox.ChangeArgs):
	if args.delete:
		Globals.db.query("delete from trees where id = " + str(args.tree["ID"]))
		if Globals.db.error_message != "not an error":
			show_info_box(Globals.db.error_message)
		else:
			show_info_box("Успешно удалено")
			args.sender.tree_node.queue_free()
			args.sender.queue_free()
			if plantation_polygons.has(args.tree["PlantationID"]):
				var poly = plantation_polygons[args.tree["PlantationID"]] as Polygon2D
				var q = "select * from trees where plantationid = " + str(args.tree["PlantationID"])
				Globals.db.query(q)
				if Globals.db.query_result.size() >= 3:
					var points :Array[Vector2] = []
					for tree_row in Globals.db.query_result:
						var split = tree_row["Coords"].split(';')
						points.append(Vector2(int(split[0]), int(split[1])))
					plantation_polygons[args.tree["PlantationID"]].queue_free()
					var polygon = Polygon2D.new()
					# TODO doesnt work every time
					polygon.name = "Plantation " + str(args.tree["PlantationID"])
					polygon.modulate.a = 0.5
					polygon.polygon = Geometry2D.convex_hull(points) #hull.convexHull(points)
					polygons.add_child(polygon)
					plantation_polygons[args.tree["PlantationID"]] = polygon
		return
	
	var q = "update trees set Name = \""+args.tree_name+"\", TreeID = (select id from treenames where name = \"" + args.tree_kind + "\")" + ", PlantationID = (select id from Plantation where name =\"" + args.plantation + "\"),Coords = \"" + args.coords + "\", PlantDate = \"" + args.plant_date + "\"" + (", CutDate = \"" + args.cut_date + "\"" if !args.cut_date.is_empty() else "") + " where id = " + str(args.tree["ID"])
	print(q)
	 
	Globals.db.query(q)
	if Globals.db.error_message != "not an error":
			show_info_box(Globals.db.error_message)
	else:
		show_info_box("Успешно изменено")
		Globals.db.query("select * from trees where id = " + str(args.tree["ID"]))
		args.sender.tree_node.tree = Globals.db.query_result[0]
		args.sender.queue_free()
	

func show_info_box(text:String, pos:Vector2 = get_global_mouse_position()):
	var info_box = INFO_BOX.instantiate()
	info_box.text = text
	info_box.global_position = pos
	tmp.add_child(info_box)
