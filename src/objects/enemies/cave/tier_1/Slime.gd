@tool
extends Enemy

func _init_move_set() -> void:
	move_set = [
		Attack.new(level, GlobalTools.ElementType.keys()[GlobalTools.ElementType.Water]),
		Attack.new(roundi(level * 1.5), GlobalTools.ElementType.keys()[GlobalTools.ElementType.Water]),
		Attack.new(roundi(level * 0.5), GlobalTools.ElementType.keys()[GlobalTools.ElementType.Earth])
	]
	
	if move_set.size() > 0:
		update_turn_data(move_set[0], 0)
	
	max_health=round(4.5*level)

func _update_graphics() -> void:
	if not enemy_rect: return
	var path = "res://src/sprites/enemies/Slime.png"
	if ResourceLoader.exists(path):
		enemy_rect.texture = load(path)
		pivot_offset=Vector2(size.x/2,size.y/2)
