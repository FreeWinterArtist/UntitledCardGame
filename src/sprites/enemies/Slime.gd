extends Enemy

var local_move_set:Array
func _ready() -> void:
	super._ready()
	
	move_set=[
		Attack.new(power,ElementType.keys()[ElementType.Water]),
		Attack.new(round(power*1.5),ElementType.keys()[ElementType.Water]),
		Attack.new(round(power*0.5),ElementType.keys()[ElementType.Earth])
		]
	turns_quantity=move_set.size()
	turn=0
