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

var card_tween:Tween
var is_picked_up:bool=false

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
	
	max_y=size.y/2
	if not Engine.is_editor_hint():
		start_y=global_position.y
		is_start_y_set=true


func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		if event.is_pressed() and !is_picked_up:
			is_picked_up=true
			move_card_up()
			if get_parent() and get_parent().has_method("set_active_card"):
				get_parent().set_active_card(self)
		elif event.is_pressed() and is_picked_up:
			is_picked_up=false
			move_card_down()
			if get_parent() and get_parent().has_method("set_active_card")\
			 and "active_card" in get_parent() and get_parent().active_card==self:
				get_parent().set_active_card(null)

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		if event.is_pressed() and is_picked_up:
			var local_mouse_position:Vector2=get_local_mouse_position()
			if not Rect2(Vector2.ZERO,size).has_point(local_mouse_position):
				is_picked_up=false
				move_card_down()
				if get_parent() and get_parent().has_method("set_active_card")\
				and "active_card" in get_parent() and get_parent().active_card==self:
					get_parent().set_active_card(null)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

func move_card_up():
	if card_tween and card_tween.is_running():
		card_tween.kill()
	var tween:Tween=create_tween()
	
	tween.tween_property(self,"global_position:y",start_y-max_y,0.5)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)
func move_card_down():
	if card_tween and card_tween.is_running():
		card_tween.kill()
	var tween:Tween=create_tween()
	
	tween.tween_property(self,"global_position:y",start_y,0.5)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)
