extends ScrollContainer

func _ready():
	# Ждём один кадр, чтобы контейнер посчитал размеры
	await get_tree().process_frame
	# Прокручиваем в самый низ
	scroll_vertical = 999999
