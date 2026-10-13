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
@onready var cardRect: TextureRect = $CardRect
@onready var cardValue: Sprite2D= $CardRect/Value 

var is_dragging: bool = false;

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

func _on_mouse_hold(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_dragging=true;

func _on_mouse_release(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		if not event.is_pressed():
			is_dragging=false;
