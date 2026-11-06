extends Control

class_name Battle


var turn: int=0
var active_card: Card=null
var active_enemy: Enemy=null
var enemies:Array[Enemy]=[]
var living_enemies:int=0
var is_acting:bool=false

var player:Player

func _ready()->void:
	_create_enemies(1)
	for i in get_children():
		if i is Player:
			player=i
	CardGlobalTools.card_picked.connect(_on_card_picked)
	EnemyGlobalTools.enemy_picked.connect(_on_enemy_picked)

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
	if !new_enemy.is_alive or is_acting or new_enemy.is_turn_taken:return
	
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
		is_acting=true
		if active_card.card_tween and active_card.card_tween.is_running():
			await active_card.card_tween.finished
		if active_enemy.scale_tween and active_enemy.scale_tween.is_running():
			await active_enemy.scale_tween.finished
		
		var _turn = turn % len(active_enemy.move_set)
		if turn % 2 == 0:
			active_enemy.take_damage(active_enemy.move_set[_turn], active_card.card_attack)
			if active_enemy.health < 1:
				living_enemies -= 1
				print("The enemy is dead")
			if living_enemies == 0:
				print("All enemies are dead")
				
		elif turn % 2 == 1:
			player.take_damage(active_enemy.move_set[_turn], active_card.card_attack)
			
		active_enemy.is_turn_taken=true
		if active_enemy.damage_tween.is_running():
			await active_enemy.damage_tween.finished
		active_enemy.set_exhausted_status()
		
		var are_enemies_turns_taken:bool=true
		for _enemy in enemies:
			if !_enemy.is_alive:
				_enemy.is_turn_taken=true
		for _enemy in enemies:
			if !_enemy.is_turn_taken:
				are_enemies_turns_taken=false
				_turn = (turn+1) % len(active_enemy.move_set)
				active_enemy.update_turn_data(active_enemy.move_set[_turn], turn)
				break
		print("enemy turns are taken:", are_enemies_turns_taken)
		
		if are_enemies_turns_taken:
			turn += 1
			for _enemy in enemies:
				_turn = turn % len(_enemy.move_set)
				_enemy.is_turn_taken=false
				_enemy.set_exhausted_status()
				_enemy.update_turn_data(_enemy.move_set[_turn],turn)
		
		var _used_card:Card=active_card
		_after_card_is_used()
		CardGlobalTools.card_is_used.emit(_used_card)
		_reset_enemy_selection()
		is_acting=false


func _input(event:InputEvent)->void:
	if is_acting:return
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
			
func _create_enemies(tier:int)->void:
	var enemy_amount:int=randi_range(2,2)
	for i in range(enemy_amount):
		var new_enemy=EnemyGlobalTools.spawn_enemy_by_tier(tier)
		add_child(new_enemy)
		print(new_enemy.position)
		enemies.append(new_enemy)
	living_enemies=enemies.size()
	_update_enemy_ui()
	
func _update_enemy_ui()->void:
	var enemies_count = enemies.size()
	
	if enemies_count == 0:
		return
	
	var screen_width = get_viewport_rect().size.x
	
	var enemy_width:float=128.0
	
	# Суммарная ширина всех карт на экране
	var total_enemies_width = enemies_count * enemy_width
	
	# Свободное пространство, которое нужно разделить на отступы
	var remaining_space = screen_width - total_enemies_width
	
	# Количество промежутков (отступов). 
	# По условию: отступ слева + промежутки между картами + отступ справа = card_count + 1
	var gap = remaining_space / (enemies_count + 1)
	
	# Раскладываем карты по местам
	for i in range(enemies_count):
		enemies[i].show()
		var enemy_x = gap + i * (enemy_width + gap)
		
		var enemy_y = get_viewport_rect().size.y/2-200
		
		enemies[i].position = Vector2(enemy_x, enemy_y)

func _on_card_picked(new_card:Card):
	if is_acting:return
	set_active_card(new_card)
	
func _on_enemy_picked(new_enemy):
	if is_acting: return
	set_active_enemy(new_enemy)

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
