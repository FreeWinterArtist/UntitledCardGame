extends Control

class_name CardManager

@onready var card_scene: PackedScene = preload("res://src/objects/card.tscn")

var hand: Array[Card] = []
var deck: Array[Card] = []
var discard_pile: Array[Card] = []

var card_width: float

func _ready() -> void:
	CardGlobalTools.card_is_used.connect(_on_card_used)
	# ИСПРАВЛЕНИЕ: Инстанцируем сцену, чтобы узнать реальный размер карты
	var template_card = card_scene.instantiate()
	card_width = template_card.size.x
	template_card.queue_free() # Удаляем шаблон, он больше не нужен
	
	deck = create_array_of_random_cards(7)
	move_random_cards_from_deck()

func update_hand_ui():
	var card_count = hand.size()
	
	if card_count == 0:
		return
		
	# Получаем текущую ширину экрана
	var screen_width = get_viewport_rect().size.x
	
	# Суммарная ширина всех карт на экране
	var total_cards_width = card_count * card_width
	
	# Свободное пространство, которое нужно разделить на отступы
	var remaining_space = screen_width - total_cards_width
	
	# Количество промежутков (отступов). 
	# По условию: отступ слева + промежутки между картами + отступ справа = card_count + 1
	var gap = remaining_space / (card_count + 1)
	
	# Раскладываем карты по местам
	for i in range(card_count):
		if hand[i].card_tween and hand[i].card_tween.is_running():
			hand[i].card_tween.kill()
		hand[i].show()
		hand[i].scale=Vector2.ONE
		var card_x = gap + i * (card_width + gap)
		
		var card_y = get_viewport_rect().size.y - hand[i].get_rect().size.y*1.3
		hand[i].start_y=card_y
		
		hand[i].position = Vector2(card_x, card_y)


func move_random_cards_from_deck() -> void:
	check_deck()
	var cards_to_draw = min(4, deck.size())
	for i in range(cards_to_draw):
		var _picked_card: Card = deck[randi_range(0, deck.size() - 1)]
		hand.append(_picked_card)
		deck.erase(_picked_card)
		
	update_hand_ui()

func create_array_of_random_cards(amount: int) -> Array[Card]:
	var array: Array[Card] = []
	for i in range(amount):
		array.append(pick_random_card(1, 2))
	return array

func pick_random_card(min_power: int, max_power: int) -> Card:
	var _power: int = randi_range(min_power, max_power)
	var _element: GlobalTools.ElementType
	match randi_range(0, 3):
		0: _element = GlobalTools.ElementType.Water
		1: _element = GlobalTools.ElementType.Fire
		2: _element = GlobalTools.ElementType.Plant
		3: _element = GlobalTools.ElementType.Earth
		
	var _created_card: Card = card_scene.instantiate()
	_created_card.power = _power
	_created_card.element = _element
	
	add_child(_created_card)
	_created_card.hide()
	return _created_card

func _on_card_used(_card: Card):
	if _card in hand:
		hand.erase(_card)
	
	if not _card in discard_pile:
		_card.hide()
		_card.position.y=get_viewport_rect().size.y+100
		discard_pile.append(_card)
	if hand.size()<1:
		move_random_cards_from_deck()
	else:
		update_hand_ui()


func check_deck():
	if deck.size() == 0:
		if discard_pile.size() == 0:
			return
			
		deck = discard_pile.duplicate()
		discard_pile.clear()
		deck.shuffle()
