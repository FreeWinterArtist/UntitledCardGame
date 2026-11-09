extends Control

@onready var start_button = $CenterContainer/VBoxContainer/StartButton
@onready var options_button = $CenterContainer/VBoxContainer/OptionsButton
@onready var quit_button = $CenterContainer/VBoxContainer/QuitButton

func _ready():
	print("=== Главное меню загружено ===")
	
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
	if options_button:
		options_button.pressed.connect(_on_options_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	print("Нажата кнопка Start")
	get_tree().change_scene_to_file("res://src/objects/game_map.tscn")

func _on_options_pressed():
	print("Нажата кнопка Options")
	get_tree().change_scene_to_file("res://options.tscn")

func _on_quit_pressed():
	print("Нажата кнопка Quit")
	get_tree().quit()
