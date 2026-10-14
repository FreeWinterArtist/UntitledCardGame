extends Node2D

# ============ ПУТИ К СЦЕНАМ ============
const SCENE_BATTLE = "res://src/objects/battle.tscn"
const SCENE_FORGE  = "res://src/objects/forge.tscn"
const SCENE_CHEST  = "res://src/objects/chest.tscn"
const SCENE_MENU   = "res://src/objects/main_menu.tscn"

# ============ УЗЛЫ ============
@onready var rooms_container = $UI/ScrollContainer/MarginContainer/RoomsContainer
@onready var back_button = $UI/BackButton

# ============ СТАРТ ============
func _ready():
	print("=== GameMap запущена ===")
	print("RoomsContainer: ", rooms_container)
	print("BackButton: ", back_button)
	
	# Кнопка "Назад"
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)
	else:
		print("ВНИМАНИЕ: BackButton не найден по пути $UI/BackButton")
	
	# Рандом для комнат 3, 6, 8, 10
	var room_scenes = generate_rooms()
	
	# Подключаем все кнопки
	if rooms_container:
		var buttons = rooms_container.get_children()
		print("Найдено кнопок: ", buttons.size())
		
		for node in buttons:
			# Если кнопка внутри MarginContainer — берём кнопку внутри
			var actual_button = node
			if node is MarginContainer:
				actual_button = node.get_child(0)
			
			# Определяем номер комнаты ИЗ ИМЕНИ узла
			var room_number = _get_room_number_from_name(actual_button.name)
			if room_number == -1:
				print("Не удалось определить номер для: ", actual_button.name)
				continue
			
			if room_scenes.has(room_number):
				actual_button.pressed.connect(
					_on_room_pressed.bind(room_scenes[room_number], room_number)
				)
				print("Кнопка %s -> комната %d" % [actual_button.name, room_number])
	else:
		print("ОШИБКА: RoomsContainer не найден")

# ============ ОПРЕДЕЛЕНИЕ НОМЕРА ИЗ ИМЕНИ ============
func _get_room_number_from_name(node_name: String) -> int:
	# Ищем цифры в имени: "Roomweak3" -> 3, "Room3" -> 3, "@Button@5" -> 5
	var digits = ""
	for c in node_name:
		if c >= "0" and c <= "9":
			digits += c
	if digits == "":
		return -1
	return int(digits)

# ============ ГЕНЕРАЦИЯ КАРТЫ ============
func generate_rooms() -> Dictionary:
	var rooms = {
		1: SCENE_BATTLE,   # слабая
		2: SCENE_BATTLE,   # слабая
		3: null,           # рандом: кузница или сундук
		4: SCENE_BATTLE,   # средняя
		5: SCENE_BATTLE,   # средняя
		6: null,           # рандом: кузница или сундук
		7: SCENE_BATTLE,   # сложная
		8: null,           # рандом: кузница или сундук
		9: SCENE_BATTLE,   # сложная
		10: null,          # рандом: кузница или сундук
		11: SCENE_BATTLE,  # босс
	}
	
	# Пул: 2 кузницы + 2 сундука (поровну!)
	var random_pool = [
		SCENE_FORGE, SCENE_FORGE,
		SCENE_CHEST, SCENE_CHEST,
	]
	random_pool.shuffle()
	
	# Заполняем слоты 3, 6, 8, 10
	var slots = [3, 6, 8, 10]
	for i in range(slots.size()):
		rooms[slots[i]] = random_pool[i]
	
	# Отладочный вывод
	print("=== Карта сгенерирована ===")
	for i in range(1, 12):
		print("Комната %d: %s" % [i, rooms[i]])
	
	return rooms

# ============ ОБРАБОТЧИКИ ============
func _on_room_pressed(scene_path: String, room_number: int):
	# Определяем название комнаты по пути
	var room_name = "Неизвестно"
	if scene_path == SCENE_BATTLE:
		room_name = "Бой"
	elif scene_path == SCENE_FORGE:
		room_name = "Кузница"
	elif scene_path == SCENE_CHEST:
		room_name = "Сундук"
	
	# Если это босс (комната 11) — пишем отдельно
	if room_number == 11:
		room_name = "БОСС"
	
	print(">>> Открывается комната %d: %s (%s)" % [room_number, room_name, scene_path])
	get_tree().change_scene_to_file(scene_path)

func _on_back_button_pressed():
	print(">>> Возврат в главное меню")
	get_tree().change_scene_to_file(SCENE_MENU)
