extends Control

const CONFIG_PATH = "user://settings.cfg"
const SCENE_MENU = "res://src/objects/main_menu.tscn"

@onready var music_slider = $VBoxContainer/MusicRow/MusicSlider
@onready var sound_slider = $VBoxContainer/SoundRow/SoundSlider
@onready var lang_option = $VBoxContainer/LangRow/LangOption
@onready var back_button = $VBoxContainer/BackButton

func _ready():
	print("=== Настройки загружены ===")
	print("MusicSlider: ", music_slider)
	print("SoundSlider: ", sound_slider)
	print("LangOption: ", lang_option)
	print("BackButton: ", back_button)
	
	# Безопасное подключение сигналов (если узел найден)
	if music_slider:
		music_slider.value_changed.connect(_on_music_changed)
	if sound_slider:
		sound_slider.value_changed.connect(_on_sound_changed)
	if lang_option:
		lang_option.item_selected.connect(_on_language_changed)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	# Загружаем сохранённые настройки
	load_settings()

func _on_music_changed(value: float):
	var db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(1, db) # 1 - индекс шины Music
	save_settings()

func _on_sound_changed(value: float):
	var db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(2, db) # 2 - индекс шины SFX
	save_settings()

func _on_language_changed(index: int):
	TranslationServer.set_locale("ru" if index == 0 else "en")
	save_settings()

func _on_back_pressed():
	print("Нажата кнопка Назад")
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
		print("Файл настроек не найден, используем дефолтные.")
		return
		
	if music_slider:
		music_slider.value = config.get_value("audio", "music_volume", 100.0)
	if sound_slider:
		sound_slider.value = config.get_value("audio", "sound_volume", 100.0)
	if lang_option:
		lang_option.selected = config.get_value("general", "language", 0)
	
	# Применяем настройки сразу при загрузке
	if music_slider: _on_music_changed(music_slider.value)
	if sound_slider: _on_sound_changed(sound_slider.value)
	if lang_option: _on_language_changed(lang_option.selected)
