extends Control

class_name Player

@onready var health_bar:ColorRect=$HealthBackground/HealthBar
@onready var health_label:Label=$HealthBackground/HealthBar/HealthLabel

@export var max_health:int=20:
	set(value):
		max_health=value
		health=value
		_update_health_ui()
@export var health:int=max_health:
	set(value):
		if value<1:
			health=0
			death()
		else:
			health=value
		
var default_health_bar_size_x:float=0

func _ready() -> void:
	default_health_bar_size_x=health_bar.size.x
	_update_health_ui()

func _update_health_ui():
	if health_bar:
		health_bar.size.x=default_health_bar_size_x*health/max_health
	if health_label:
		health_label.text=str(health)+"/"+str(max_health)

func _total_damage(enemy_attack:Attack,player_attack:Attack)->int:
	var enemy_element:String=enemy_attack.element
	var enemy_damage:int=enemy_attack.damage
	var card_element:String=player_attack.element
	var card_damage:int=player_attack.damage
	
	#if enemy_element>card_element then enemy_damage*=2
	enemy_damage*=GlobalTools.check_element_multiply(card_element,enemy_element)
	#if card_element>enemy_element then card_damage*=2
	card_damage*=GlobalTools.check_element_multiply(enemy_element,card_element)
		
	var total_damage:int=enemy_damage-card_damage
	if total_damage<0:
		total_damage=0
	
	return total_damage
	
func take_damage(enemy_attack:Attack,player_attack:Attack):
	var damage:int=_total_damage(enemy_attack,player_attack)
	health-=damage
	print("The player took damage:", damage)
	_update_health_ui()

func death():
	pass
