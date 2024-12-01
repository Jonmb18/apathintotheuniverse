extends Control

@onready var LogoMusic = $LogoMusic
@onready var Logo = $AnimationPlayer/FrenziesLogo

# Quando a animação termina, ele joga para a cena do menu principal
func _on_animation_player_animation_finished(_anim_name: String) -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
