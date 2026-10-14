@tool
extends Control
class_name Enemy

enum EnemyType {Slime,Elemental,MushroomRat, CursedAsh}
enum ElementType {Water,Fire,Plant,Earth,Life,Death}

@export var enemy_type: EnemyType=EnemyType.Slime:
	set(value):
		enemy_type=value
		_update_graphics()
		_update_element()
		notify_property_list_changed()
@export var element: ElementType
@export_range(1,9) var power: int=1:
	set(value):
		power=value
		_update_graphics()
@onready var enemyRect: TextureRect = $EnemyRect
@onready var enemyValue: Sprite2D= $EnemyRect/Value 

@export var health:int=1
var move_set:Array[Attack]
var turns_quantity:int=len(move_set)
var turn:int=0:
	set(value):
		turn=value%turns_quantity

func execute_turn():
	pass

func _update_graphics()->void:
	if not is_inside_tree() or enemyRect==null:
		return
		
	var enemy_name:String=EnemyType.keys()[enemy_type]
	
	var enemyPath="res://src/sprites/enemies/"+enemy_name+".png"
	if ResourceLoader.exists(enemyPath):
		enemyRect.texture=load(enemyPath)
	if enemyValue:
		enemyValue.frame=clampi(power-1,0,8)

func _update_element()->void:
	match enemy_type:
		EnemyType.Slime:
			element=ElementType.Water
		EnemyType.Elemental:
			element=ElementType.Fire
		EnemyType.MushroomRat:
			element=ElementType.Plant
		EnemyType.CursedAsh:
			element=ElementType.Earth		


func _validate_property(property: Dictionary) -> void:
	if property.name=="element":
		property.usage |=PROPERTY_USAGE_READ_ONLY

func _attach_bihavior()->void:
	var enemy_name:String=EnemyType.keys()[enemy_type]
	var enemyPath:String="res://src/sprites/enemies/"+enemy_name+".gd"
	if ResourceLoader.exists(enemyPath):
		var behavior=load(enemyPath)
		self.set_script(behavior)

func _ready() -> void:
	_update_graphics()

func _total_damage(enemy_attack:Attack,player_attack:Attack)->int:
	var enemy_element:String=enemy_attack.element
	var enemy_damage:int=enemy_attack.damage
	var card_element:String=player_attack.element
	var card_damage:int=player_attack.damage
	if enemy_element=="Water" and card_element=="Fire":
		enemy_damage*=2
	if enemy_element=="Fire" and card_element=="Plant":
		enemy_damage*=2
	if enemy_element=="Plant" and card_element=="Earth":
		enemy_damage*=2
	if enemy_element=="Earth" and card_element=="Water":
		enemy_damage*=2
	
	if card_element=="Water" and enemy_element=="Fire":
		card_damage*=2
	if card_element=="Fire" and enemy_element=="Plant":
		card_damage*=2
	if card_element=="Plant" and enemy_element=="Earth":
		card_damage*=2
	if card_element=="Earth" and enemy_element=="Water":
		card_damage*=2
		
	var total_damage:int=enemy_damage-card_damage
	if total_damage<0:
		total_damage=0
	
	return total_damage
func take_damage(enemy_attack:Attack,player_attack:Attack):
	var damage:int=_total_damage(enemy_attack,player_attack)
	health-=damage
	print(enemy_type," Received Damage! ",damage)
