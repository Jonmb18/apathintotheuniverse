extends Control

@onready var StartingSFX = $StartGameSFX
@onready var BlinkScreen = $BlinkScreen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioPlayer.play_music_level()
	get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func sfx_player():
	StartingSFX.volume_db = 12
	StartingSFX.pitch_scale = 4
	
	AudioPlayer.volume_db = -30.0
	StartingSFX.play(true)

func _on_start_pressed() -> void:
	print("Starting game.")
	$AnimationPlayer.play("Spaceship")
	
	await $AnimationPlayer.animation_finished
	StartingSFX.stop()
	AudioPlayer.volume_db = -16.0
	get_tree().change_scene_to_file("res://Scenes/play_menu.tscn")
	


func _on_options_pressed() -> void:
	print("Loading options menu")
	get_tree().change_scene_to_file("res://UI/Options/options.tscn")


func _on_quit_pressed() -> void:
	print("Quiting game.")
	get_tree().quit()
