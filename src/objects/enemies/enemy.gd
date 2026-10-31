@tool
extends Control
class_name Enemy

@export var level: int=1:
	set(value):
		level=value
		_update_graphics()
		update_level()

var scale_tween:Tween
var is_picked_up:bool=false

@onready var enemy_rect: TextureRect = $EnemyRect
@onready var enemy_level: Label= $EnemyRect/LevelBackground/Level
@onready var act_rect: TextureRect=$TurnData/Act
@onready var element_rect: TextureRect=$TurnData/Element 
@onready var power_rect: Label=$TurnData/Act/Power 
@onready var HP:Label=$EnemyRect/HPBackground/HP
@onready var HP_bar:ColorRect=$EnemyRect/HPBackground/HPBar
@onready var turn_data:HBoxContainer=$TurnData

@export var max_health:int=1:
	set(value):
		max_health=value
		health=value
		update_enemy_health()
@export var health:int=1:
	set(value):
		if value<1:
			health=0
			death()
		else:
			health=value
var default_HP_bar_size_x:float=0
var is_alive:bool=true

var move_set:Array[Attack]

func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if get_parent() and get_parent().has_method("set_active_enemy"):
			get_parent().set_active_enemy(self)

func _update_graphics()->void:
	pass

func _ready() -> void:
	default_HP_bar_size_x=HP_bar.size.x
	_update_graphics()
	_init_move_set()

func _total_damage(enemy_attack:Attack,player_attack:Attack)->int:
	var enemy_element:String=enemy_attack.element
	var enemy_damage:int=enemy_attack.damage
	var card_element:String=player_attack.element
	var card_damage:int=player_attack.damage
	
	#if enemy_element>card_element then enemy_damage*=2
	enemy_damage*=GlobalTools.check_element_multiply(card_element,enemy_element)
	#if card_element>enemy_element then card_damage*=2
	card_damage*=GlobalTools.check_element_multiply(enemy_element,card_element)
		
	var total_damage:int=card_damage-enemy_damage
	if total_damage<0:
		total_damage=0
	
	return total_damage

func take_damage(enemy_attack:Attack,player_attack:Attack):
	var damage:int=_total_damage(enemy_attack,player_attack)
	health-=damage
	print("The enemy took damage:", damage)
	update_enemy_health()

func death():
	is_alive=false
	if turn_data:
		turn_data.visible=false
	self.modulate.a=0.5

func update_level()->void:
	if !enemy_level: enemy_level= $EnemyRect/LevelBackground/Level
	enemy_level.text=str(level)
func update_enemy_health()->void:
	if !HP:return
	HP.text=str(health)+"/"+str(max_health)
	if !HP_bar:return
	HP_bar.size.x=default_HP_bar_size_x*health/max_health
func update_turn_data(enemy_attack:Attack,turn:int)->void:
	if not is_inside_tree(): return
	update_Act_Rect(turn)
	update_element_Rect(enemy_attack.element)
	update_act_power(enemy_attack.damage)
func update_Act_Rect(turn)->void:
	if !act_rect: return
	var path:String="res://src/sprites/type/Sword.png" if turn%2==1 else\
	"res://src/sprites/type/Shield.png"
	if ResourceLoader.exists(path):
		act_rect.texture = load(path)
func update_element_Rect(_element: String)->void:
	if !element_rect: return 
	var path:String="res://src/sprites/elements/"+_element+".png"
	if ResourceLoader.exists(path):
		element_rect.texture=load(path)
func update_act_power(damage: int) -> void:
	if !power_rect: return
	power_rect.text=str(damage)
	
func zoom_in():
	if scale_tween and scale_tween.is_running():
		scale_tween.kill()
	var tween:Tween=create_tween()
	
	tween.tween_property(self,"scale",Vector2(1.2,1.2),0.5)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)
func zoom_out():
	if scale_tween and scale_tween.is_running():
		scale_tween.kill()
	var tween:Tween=create_tween()
	
	tween.tween_property(self,"scale",Vector2(1,1),0.5)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)

func _init_move_set()->void:
	pass
