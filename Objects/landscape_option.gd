extends PanelContainer
class_name LandscapeOption

@export var id : int
@export var city : String :
	set(val):
		city = val
		upd()
@export var date : String:
	set(val):
		date = val
		upd()
@export var population : int:
	set(val):
		population = val
		upd()
@export var greenery_percentage : float:
	set(val):
		greenery_percentage = val
		upd()

@onready var btn: Button = $NamesBtn
@onready var label: Label = $Label

func upd():
	label.text = "%s с населением %s имеет процент озеленения %s%% (дата: %s)" % [city, str(population), str(greenery_percentage), date]
