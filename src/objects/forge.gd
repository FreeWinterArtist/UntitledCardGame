extends Control

func _ready():
	$AnvilButton.pressed.connect(_on_anvil_pressed)
	$DeleteButton.pressed.connect(_on_delete_pressed)
	$InvButton.pressed.connect(_on_inv_pressed)
	$ExitButton.pressed.connect(_on_exit_pressed)

func _on_anvil_pressed():
	print("Переход в прокачку")
	get_tree().change_scene_to_file("res://src/objects/forge_upgrade.tscn")

func _on_delete_pressed():
	print("Переход в удаление")
	get_tree().change_scene_to_file("res://src/objects/forge_delete.tscn")

func _on_inv_pressed():
	print("Переход в колоду")
	get_tree().change_scene_to_file("res://src/objects/inventory.tscn")

func _on_exit_pressed():
	print("Выход на карту")
	get_tree().change_scene_to_file("res://src/objects/game_map.tscn")
