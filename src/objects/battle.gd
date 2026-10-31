extends Control

class_name Battle

var turn: int=0
var active_card: Card=null
var active_enemy: Enemy=null
var living_enemies:int=0

var player:Player

func _ready()->void:
	for i in get_children():
		if i is Player:
			player=i
	var enemies:Array[Node]=get_tree().get_nodes_in_group("enemies")
	living_enemies=len(enemies)
	CardGlobalTools.card_picked.connect(_on_card_picked)

func set_active_card(new_card:Card)->void:
	if active_card==new_card:
		active_card.is_picked_up=false
		active_card.move_card_down()
		active_card=null
		return
	
	if active_card:
		active_card.is_picked_up=false 
		active_card.move_card_down()
	
	active_card=new_card
	if active_card:
		active_card.is_picked_up=true
		active_card.move_card_up()
	
	_check_combat_trigger()
		
func set_active_enemy(new_enemy:Enemy)->void:
	if !new_enemy.is_alive:return
	
	if active_enemy==new_enemy:
		active_enemy.is_picked_up=false
		active_enemy.zoom_out()
		active_enemy=null
		return
	
	if active_enemy:
		active_enemy.is_picked_up=false 
		active_enemy.zoom_out()
	
	active_enemy=new_enemy
	if active_enemy:
		var _turn=turn%len(active_enemy.move_set)
		active_enemy.is_picked_up=true
		active_enemy.update_turn_data(active_enemy.move_set[_turn],turn)
		active_enemy.zoom_in()
	
	_check_combat_trigger()

func _check_combat_trigger():
	if active_card and active_enemy:
		var _turn = turn % len(active_enemy.move_set)
		if turn % 2 == 0:
			active_enemy.take_damage(active_enemy.move_set[_turn], active_card.card_attack)
			if active_enemy.health < 1:
				living_enemies -= 1
				print("The enemy is dead")
			if living_enemies == 0:
				print("All enemies are dead")
			
			turn += 1
			_turn = turn % len(active_enemy.move_set)
			active_enemy.update_turn_data(active_enemy.move_set[_turn], turn)
		elif turn % 2 == 1:
			player.take_damage(active_enemy.move_set[_turn], active_card.card_attack)
			
			turn += 1
			_turn = turn % len(active_enemy.move_set)
			active_enemy.update_turn_data(active_enemy.move_set[_turn], turn)
		var _used_card:Card=active_card
		_after_card_is_used()
		CardGlobalTools.card_is_used.emit(_used_card)
		_reset_enemy_selection()


func _input(event:InputEvent)->void:
	if event is InputEventMouseButton and event.button_index== MOUSE_BUTTON_LEFT and event.is_pressed():
		await get_tree().process_frame
		
		var is_card_selected:bool=false
		if active_card and Rect2(Vector2.ZERO,active_card.size,).has_point(active_card.get_local_mouse_position()):
			is_card_selected=true
		
		var is_enemy_selected:bool=false
		if active_enemy and Rect2(Vector2.ZERO,active_enemy.size,).has_point(active_enemy.get_local_mouse_position()):
			is_enemy_selected=true
		
		if !is_card_selected and !is_enemy_selected:
			_reset_selection()

func _on_card_picked(new_card:Card):
	set_active_card(new_card)

func _reset_selection()->void:
	_reset_card_selection()
	_reset_enemy_selection()

func _after_card_is_used()->void:
	if active_card:
		active_card.is_picked_up=false
		active_card=null

func _reset_card_selection()->void:
	if active_card:
		active_card.is_picked_up=false
		active_card.move_card_down()
		active_card=null

func _reset_enemy_selection()->void:
	if active_enemy:
		var _turn=turn%len(active_enemy.move_set)
		active_enemy.update_turn_data(active_enemy.move_set[_turn],turn)
		active_enemy.is_picked_up=false
		active_enemy.zoom_out()
		active_enemy=null
