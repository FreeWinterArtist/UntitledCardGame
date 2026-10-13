@tool
class_name Card
extends Control

enum ElementType {Water,Fire,Plant,Earth,Life,Death}

@export var element: ElementType=ElementType.Fire:
	set(value):
		element=value
		_update_graphics()
@export_range(1,9) var power: int=1:
	set(value):
		power=value
		_update_graphics()
@export var cardEnemy: Enemy
@onready var cardRect: TextureRect = $CardRect
@onready var cardValue: Sprite2D= $CardRect/Value 

var is_dragging: bool = false;
var drag_offset: Vector2=Vector2.ZERO
var start_y:float=0.0
var max_y:float=0.0
var is_start_y_set:bool=false

func _update_graphics()->void:
	if not is_inside_tree() or cardRect==null:
		return
	var element_name:String=ElementType.keys()[element]
	
	var cardPath="res://src/sprites/cards/"+element_name+".png"
	if ResourceLoader.exists(cardPath):
		cardRect.texture=load(cardPath)
	if cardValue:
		cardValue.frame=clampi(power-1,0,8)


func _ready() -> void:
	_update_graphics()
	
	max_y=size.y
	if not Engine.is_editor_hint():
		start_y=global_position.y
		is_start_y_set=true


func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_dragging=true;
			drag_offset=get_global_mouse_position()-global_position
			
			if not is_start_y_set or start_y==0.0:
				start_y=global_position.y
				is_start_y_set=true
		else:
			is_dragging=false;

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		if not event.is_pressed():
			is_dragging=false;

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if is_dragging:
		var new_position: Vector2=get_global_mouse_position()-drag_offset
		var screen_size: Vector2=get_viewport_rect().size
		new_position.x=global_position.x
		new_position.y=clamp(new_position.y,start_y-max_y,start_y)
		
		global_position=new_position
