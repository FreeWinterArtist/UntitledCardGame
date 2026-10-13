extends Node2D

func _ready():
	print("Карта загружена")
	print("RoomsContainer: ", $ScrollContainer/RoomsContainer)
	print("UI: ", $UI)
	print("HintLabel: ", $UI/HintLabel)
	print("BackButton: ", $UI/BackButton)


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://src/objects/main_menu.tscn")
