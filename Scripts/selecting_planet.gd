extends Control

@export var casley_ores_necessary: int = 30
@export var lungyos_ores_necessary: int = 120

@onready var scroll_container: CardScroller = $ScrollContainer
@onready var card_info: Control = $CardInfo
@onready var tip_label: Label = $TipLabel

var casley_enough: bool = false
var lungyos_enough: bool = false

func _ready():
	card_info.enter_planet.disabled = true
	card_info.enter_planet.text = "Start Game"
	

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		
		# Mostra o Card
		if event.is_action_pressed("select") and scroll_container.card_current_index == 0:
			card_info.show()
			change_planet_name()
			change_planet_description()
			enable_planet_button()
			
			tip_label.hide()
			scroll_container.arkana_label.hide()
			scroll_container.casley_label.hide()
			scroll_container.lungyos_label.hide()
			
		if event.is_action_pressed("select") and scroll_container.card_current_index == 1:
			card_info.show()
			change_planet_name()
			change_planet_description()
			enable_planet_button()
			
			tip_label.hide()
			scroll_container.arkana_label.hide()
			scroll_container.casley_label.hide()
			scroll_container.lungyos_label.hide()
			
		if event.is_action_pressed("select") and scroll_container.card_current_index == 2:
			card_info.show()
			change_planet_name()
			change_planet_description()
			enable_planet_button()
			
			tip_label.hide()
			scroll_container.arkana_label.hide()
			scroll_container.casley_label.hide()
			scroll_container.lungyos_label.hide()
		
		# Esconde o Card
		if event.is_action_pressed("ui_cancel") and scroll_container.card_current_index == 0:
			card_info.hide()
			tip_label.show()
			scroll_container.arkana_label.show()
			scroll_container.casley_label.show()
			scroll_container.lungyos_label.show()
			
		if event.is_action_pressed("ui_cancel") and scroll_container.card_current_index == 1:
			card_info.hide()
			tip_label.show()
			scroll_container.arkana_label.show()
			scroll_container.casley_label.show()
			scroll_container.lungyos_label.show()
			
		if event.is_action_pressed("ui_cancel") and scroll_container.card_current_index == 2:
			card_info.hide()
			tip_label.show()
			scroll_container.arkana_label.show()
			scroll_container.casley_label.show()
			scroll_container.lungyos_label.show()
		
		# Muda o nome do Planeta quando passa para o lado
		if event.is_action_pressed("move_right"):
			change_planet_name()
			change_planet_description()
			enable_planet_button()
			if card_info.is_visible_in_tree():
				scroll_container.arkana_label.hide()
				scroll_container.casley_label.hide()
				scroll_container.lungyos_label.hide()
			
		if event.is_action_pressed("move_left"):
			change_planet_name()
			change_planet_description()
			enable_planet_button()
			if card_info.is_visible_in_tree():
				scroll_container.arkana_label.hide()
				scroll_container.casley_label.hide()
				scroll_container.lungyos_label.hide()
				
		

# Muda o nome do Planeta no Card
func change_planet_name():
	if scroll_container.card_current_index < 1:
		card_info.planet_name.text = "Arkana"
	if scroll_container.card_current_index > 0 and scroll_container.card_current_index < 2:
		card_info.planet_name.text = "Casley"
	if scroll_container.card_current_index > 1:
		card_info.planet_name.text = "Lungyos"
	
# Muda a descrição do Planeta no Card
func change_planet_description():
	if scroll_container.card_current_index < 1:
		card_info.planet_description.set("theme_override_font_sizes/font_size", 12)
		card_info.planet_description.text = "Green planet, mostly inhabited by green life, it's inhospit ambience as well as the very large variety of unknown types of plants have awarded this particular planet, a category B. 
		
		You must not venture there unless strictly necessary. You might want to watch out for strange plants on your path, they can be very tricky and dangerous.
		
		!!!NOT TOXIC!!! 
		As far as we know at least..."
	if scroll_container.card_current_index > 0 and scroll_container.card_current_index < 2:
		card_info.planet_description.set("theme_override_font_sizes/font_size", 10)
		card_info.planet_description.text = "Casley is a desert planet that belongs to the A2SHC Galaxy, a well known galaxy with two suns that coexists in their own gravity field, it's also the galaxy that the first generation of Lizantropian Space Explorers (the LSE for short) have found.
		
		Casley is a Purple-Orange planet with two moons:
		
		- Selena, a blue-orange moon, the biggest of the two, it's mostly covered in sand and the most known fact about it is that the blue part is the desert and the orange part is a small ocean. 
		
		Cientists have yet to find the answer for this strange phenomenon.
		
		- Mixillia, small grey moon that have no known feature, it's mostly made out of iron and carbon and is rock solid. Cientists have also thought it to be a big asteroid for many years.
		"
	if scroll_container.card_current_index > 1:
		card_info.planet_description.set("theme_override_font_sizes/font_size", 12)
		card_info.planet_description.text = "Lungyos is a blue planet inside an enormous ring, it's completely covered in water, it also has unknown mysterious sea creatures, they are very dangerous and the few that came back alive from venturing it's waters never talked about what they saw there, for they don't want to relive their traumas.
		
		If you have thalassophobia that might not be the place you wanna visit.
		
		Category: A+
		
		Water is life, but here, it's also ALIVE! Be extremely careful."
	

# Ativa ou desativa o botão para iniciar o level
func enable_planet_button():
	if scroll_container.card_current_index < 1:
		card_info.enter_planet.disabled = false
		card_info.enter_planet.text = "Start Game"
	if scroll_container.card_current_index > 0 and scroll_container.card_current_index < 2 and check_enough_ores():
		card_info.enter_planet.disabled = true
	if scroll_container.card_current_index > 1 and check_enough_ores():
		card_info.enter_planet.disabled = true

# Checa se o player tem material necessário para ativar o botão
func check_enough_ores():
	var casley_ores_left: int = casley_ores_necessary - Ores.ore_quantity
	var lungyos_ores_left: int = lungyos_ores_necessary - Ores.ore_quantity
	
	if Ores.ore_quantity >= casley_ores_necessary and scroll_container.card_current_index > 0 and scroll_container.card_current_index < 2:
		print("casley ores necessary = %s" %casley_ores_necessary)
		casley_enough = true
		print("Player has enough ores")
		print(Ores.ore_quantity)
		card_info.enter_planet.disabled = false
		card_info.enter_planet.text = "Start Game"
		

	if Ores.ore_quantity >= lungyos_ores_necessary and scroll_container.card_current_index > 1:
		print("lungyos ores necessary = %s"%lungyos_ores_necessary)
		lungyos_enough = true
		print("Player has enough ores")
		print(Ores.ore_quantity)
		card_info.enter_planet.disabled = false
		card_info.enter_planet.text = "Start Game"
		

	if casley_enough != true and scroll_container.card_current_index > 0 and scroll_container.card_current_index < 2:
		print("need more ores")
		card_info.enter_planet.disabled = true
		card_info.enter_planet.text = "You must find %s more ores" %casley_ores_left
	if lungyos_enough != true and scroll_container.card_current_index > 1:
		print("need more ores")
		card_info.enter_planet.disabled = true
		card_info.enter_planet.text = "You must find %s more ores" %lungyos_ores_left


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Mothership.tscn")
