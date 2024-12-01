extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioPlayer.play_music_level()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_singleplayer_pressed() -> void:
	print("Singleplayer pressed.")
	var loadingScreen = load("res://Scenes/loading.tscn")
	get_tree().change_scene_to_packed(loadingScreen)


func _on_multiplayer_pressed() -> void:
	print("Multiplayer pressed.")
	#get_tree().change_scene_to_file("res://Multiplayer/Scenes/host_and_join.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
