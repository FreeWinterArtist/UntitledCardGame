extends Control

@onready var start_button = $CenterContainer/VBoxContainer/StartButton
@onready var options_button = $CenterContainer/VBoxContainer/OptionsButton
@onready var quit_button = $CenterContainer/VBoxContainer/QuitButton

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	print("Нажата кнопка Start")
	get_tree().change_scene_to_file("res://src/objects/game_map.tscn")

func _on_options_pressed():
	print("Нажата кнопка Options")

func _on_quit_pressed():
	print("Нажата кнопка Quit")
	get_tree().quit()
