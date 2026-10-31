extends Node

enum ElementType {Water,Fire,Plant,Earth,Life,Death}

func check_element_multiply(beaten_element:String,beat_element:String)->int:
	var multiplier:int=1
	
	if beat_element=="Water" and beaten_element=="Fire" or\
	beat_element=="Fire" and beaten_element=="Plant" or\
	beat_element=="Plant" and beaten_element=="Earth"or\
	beat_element=="Earth" and beaten_element=="Water":
		multiplier*=2
		
	return multiplier	
