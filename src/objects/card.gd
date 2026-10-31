@tool
class_name Card
extends Control


@export var element: GlobalTools.ElementType=GlobalTools.ElementType.Fire:
	set(value):
		element=value
		_update_graphics()
@export var power: int=1:
	set(value):
		power=value
		_update_graphics()
@export var cardEnemy: Enemy
@onready var cardRect: TextureRect = $CardRect
@onready var cardValue: Sprite2D= $CardRect/Value 
var card_attack: Attack

var card_tween:Tween
var is_picked_up:bool=false

var start_y:float=0.0
var max_y:float=0.0
var is_start_y_set:bool=false

func _update_graphics()->void:
	if not is_inside_tree() or cardRect==null:
		return
	var element_name:String=GlobalTools.ElementType.keys()[element]
	
	var cardPath="res://src/sprites/cards/"+element_name+".png"
	if ResourceLoader.exists(cardPath):
		cardRect.texture=load(cardPath)
	if cardValue:
		cardValue.frame=clampi(power-1,0,8)
		
	card_attack=Attack.new(power,element_name)


func _ready() -> void:
	_update_graphics()
	
	max_y=size.y/2
	if not Engine.is_editor_hint():
		start_y=global_position.y
		is_start_y_set=true


func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		CardGlobalTools.card_picked.emit(self)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

# Измените методы внутри скрипта Card:

func move_card_up():
	# ИСПРАВЛЕНИЕ: Убиваем именно сохраненный в классе твин
	if card_tween and card_tween.is_running():
		card_tween.kill()
		
	card_tween = create_tween()
	# ИСПРАВЛЕНИЕ: Работаем через локальный position, так как картой управляет менеджер Control
	card_tween.tween_property(self, "position:y", start_y - max_y, 0.5)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)

func move_card_down():
	# ИСПРАВЛЕНИЕ: Убиваем именно сохраненный в классе твин
	if card_tween and card_tween.is_running():
		card_tween.kill()
		
	card_tween = create_tween()
	# ИСПРАВЛЕНИЕ: Возвращаем строго на start_y, который ей насчитал CardManager
	card_tween.tween_property(self, "position:y", start_y, 0.5)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)
