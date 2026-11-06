extends Node

signal enemy_picked(this_enemy:Enemy)

# Указываем пути к папкам, где лежат враги
var enemy_folders: Array[String] = [
	"res://src/objects/enemies/cave/tier_1/",
	"res://src/objects/enemies/cave/tier_2/",
	"res://src/objects/enemies/cave/bosses/"
]

var enemy_pool: Dictionary = {
	1: [] as Array[PackedScene], # Массив для Тира 1
	2: [] as Array[PackedScene], # Массив для Тира 2
	3: [] as Array[PackedScene]  # Массив для Тира 3 (например, Боссы)
}

func _ready() -> void:
	# Загружаем папки в соответствующие тиры
	_load_tier_from_folder("res://src/objects/enemies/cave/tier_1/", 1)
	_load_tier_from_folder("res://src/objects/enemies/cave/tier_2/", 2)
	_load_tier_from_folder("res://src/objects/enemies/cave/bosses/", 3)

# Техническая функция сканирования конкретной папки в конкретный тир
func _load_tier_from_folder(folder_path: String, tier: int) -> void:
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and (file_name.ends_with(".tscn") or file_name.ends_with(".remap")):
				var clean_name = file_name.replace(".remap", "")
				var enemy_scene = load(folder_path + clean_name)
				if enemy_scene is PackedScene:
					# Добавляем именно в массив нужного тира внутри словаря
					enemy_pool[tier].append(enemy_scene)
			file_name = dir.get_next()
		dir.list_dir_end()

# 2. ФУНКЦИЯ ВЫБОРА: Передаем нужный тир в качестве аргумента
func spawn_enemy_by_tier(tier: int) -> Node:
	# Проверяем, есть ли такой тир и не пуст ли он
	if not enemy_pool.has(tier) or enemy_pool[tier].is_empty():
		print("Ошибка: Нет врагов для тира ", tier)
		return null
		
	# Выбираем случайного врага ИМЕННО из этого тира
	var random_scene: PackedScene = enemy_pool[tier].pick_random()
	var enemy_instance = random_scene.instantiate()
	
	return enemy_instance
