extends Control

class_name Battle

var turn: int=0:
	set(value):
		turn=value%2
var active_card: Card=null
var active_enemy_attack:Attack=null

func set_active_card(card:Card):
	active_card=card
	print(active_card)
