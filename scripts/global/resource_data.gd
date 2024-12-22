extends Node

var item_data : Dictionary

func _ready() -> void:
	var repair_kit = load("res://resources/repair_kit.tres")
	var med_kit = load("res://resources/med_kit.tres")
	var bandage = load("res://resources/bandage.tres")
	var food_1 = load("res://resources/food_1.tres")
	var fuel = load("res://resources/fuel.tres")
	var basic_helmet = load("res://resources/basic_helmet.tres")
	var basic_vest = load("res://resources/basic_vest.tres")
	var basic_boots = load("res://resources/basic_boots.tres")
	var intermediate_helmet = load("res://resources/intermediate_helmet.tres")
	var intermediate_vest = load("res://resources/intermediate_vest.tres")
	var intermediate_boots = load("res://resources/intermediate_boots.tres")
	var weapon_1 = load("res://resources/weapon_1.tres")
	item_data = {
		repair_kit.itemname : repair_kit,
		med_kit.itemname : med_kit,
		bandage.itemname : bandage, 
		food_1.itemname : food_1,
		fuel.itemname : fuel, 
		basic_helmet.itemname:  basic_helmet,
		basic_vest.itemname : basic_vest, 
		basic_boots.itemname : basic_boots,
		intermediate_helmet.itemname : intermediate_helmet,
		intermediate_vest.itemname : intermediate_vest,
		intermediate_boots.itemname : intermediate_boots,
		weapon_1.itemname : weapon_1,
		}
	print(repair_kit.itemname)
	var item_name = "Bandage"
	print(item_data[item_name].stacksize)
