extends Control

const CONFIG_PATH = "user://settings.cfg"
const SCENE_MENU = "res://src/objects/main_menu.tscn"

@onready var music_slider = $VBoxContainer/MusicRow/MusicSlider
@onready var sound_slider = $VBoxContainer/SoundRow/SoundSlider
@onready var lang_option = $VBoxContainer/LangRow/LangOption
@onready var back_button = $VBoxContainer/BackButton

func _ready():
	# Подключаем сигналы
	music_slider.value_changed.connect(_on_music_changed)
	sound_slider.value_changed.connect(_on_sound_changed)
	lang_option.item_selected.connect(_on_language_changed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Загружаем сохранённые настройки
	load_settings()

func _on_music_changed(value: float):
	var db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(1, db)
	save_settings()

func _on_sound_changed(value: float):
	var db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(2, db)
	save_settings()

func _on_language_changed(index: int):
	TranslationServer.set_locale("ru" if index == 0 else "en")
	save_settings()

func _on_back_pressed():
	get_tree().change_scene_to_file(SCENE_MENU)

func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "music_volume", music_slider.value)
	config.set_value("audio", "sound_volume", sound_slider.value)
	config.set_value("general", "language", lang_option.selected)
	config.save(CONFIG_PATH)

func load_settings():
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return
	music_slider.value = config.get_value("audio", "music_volume", 100.0)
	sound_slider.value = config.get_value("audio", "sound_volume", 100.0)
	lang_option.selected = config.get_value("general", "language", 0)
	_on_music_changed(music_slider.value)
	_on_sound_changed(sound_slider.value)
	_on_language_changed(lang_option.selected)
