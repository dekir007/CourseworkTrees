extends Camera2D

@export var clamp_viewport : bool = true

@export var clamp_sprite : bool = true
@export var sprite : Sprite2D

@export var mouse_index_to_move : MouseButton = MOUSE_BUTTON_LEFT

var zoom_speed := 15

@onready var viewport_size = get_viewport_rect().size
@onready var half_viewport_size = viewport_size / 2

var sprite_rect : Rect2
var half_sprite_size : Vector2

func _ready() -> void:
	print(viewport_size)
	if clamp_sprite:
		sprite_rect = sprite.get_rect()
		half_sprite_size = sprite_rect.size / 2 * sprite.scale
		print(half_sprite_size)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("zoom_up"):
		zoom = clamp(zoom + Vector2(delta,delta) * zoom_speed, Vector2(0.1,0.1), Vector2(2,2))

	elif Input.is_action_just_pressed("zoom_down"):
		zoom = clamp(zoom - Vector2(delta,delta) * zoom_speed, Vector2(0.1,0.1), Vector2(2,2))

var mouse_start_pos : Vector2
var screen_start_position : Vector2

var dragging = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == event.button_index&(mouse_index_to_move | MOUSE_BUTTON_MIDDLE) and !event.double_click:
			mouse_start_pos = event.position
			screen_start_position = position
			dragging = true
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		#print(get_screen_center_position(), position, zoom)
		var pos = (mouse_start_pos - event.position) / zoom + screen_start_position
		if clamp_viewport:
		# clamp camera posisition!
			position.x = clamp(pos.x, half_viewport_size.x/zoom.x, viewport_size.x - half_viewport_size.x/zoom.x)
			position.y = clamp(pos.y, half_viewport_size.y/zoom.y, viewport_size.y - half_viewport_size.y/zoom.y)
		elif clamp_sprite:
			print("x: ", sprite.position.x - half_sprite_size.x + half_viewport_size.x/zoom.x, " ", sprite.position.x + half_sprite_size.x + viewport_size.x - half_viewport_size.x/zoom.x)
			print("y: ", sprite.position.y - half_sprite_size.y + half_viewport_size.y/zoom.y, sprite.position.y + half_sprite_size.y +  viewport_size.y - half_viewport_size.y/zoom.y)
			position.x = clamp(pos.x, sprite.position.x - half_sprite_size.x + half_viewport_size.x/zoom.x, sprite.position.x + half_sprite_size.x - half_viewport_size.x/zoom.x)
			position.y = clamp(pos.y, sprite.position.y - half_sprite_size.y + half_viewport_size.y/zoom.y, sprite.position.y + half_sprite_size.y - half_viewport_size.y/zoom.y)
		else:
			position = pos
