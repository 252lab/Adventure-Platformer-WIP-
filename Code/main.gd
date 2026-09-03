extends Node2D
@onready var fade: ColorRect = $Fade

# setting what level the player is on 
var level = 1

# defining variaable in global scope
var current_level_root = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# setting up the fade effect
	fade.modulate.a = 1.0
	
	# setting up the level
	current_level_root = get_node("LevelRoot")
	
	await _setup_level(current_level_root)
	
	await _load_level(level, true)
	
	# pausing the game until it is started
	get_tree().paused = true
	
# LEVEL MANAGEMENT

func _load_level(level_number, first_load) -> void:
	
	#fade out
	if not first_load:
		await _fade(1.0)
	
	if current_level_root:
		current_level_root.queue_free()
	
	# change level
	var level_path = "res://scenes/levels/level%s.tscn" %level_number
	
	current_level_root = load(level_path).instantiate()
	add_child(current_level_root)
	current_level_root.name = "LevelRoot"
	
	_setup_level(current_level_root)
	
	# fade in
	await _fade(0.0)
	

# funtion for setting up the level
# e.g. setting up the signal for the snails to emit
func _setup_level(level_root) -> void:

	#connect enemies
	var enemies = level_root.get_node_or_null("Enemies")
	
	if enemies:
		for enemy in enemies.get_children():
			enemy.player_died.connect(_on_player_died)
	
	# connecting exit signal
	var exit = level_root.get_node_or_null("Exit")
	
	if exit and level == 3:
		exit.body_entered.connect(_end_game)
	elif exit:
		exit.body_entered.connect(_on_exit_body_entered)
		

# SIGNAL HANDLERS

func _on_player_died(body) -> void:
	body.die()
	print("player died")
	await _load_level(level, false)
	

func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		level += 1
		body.can_move = false
		await _load_level(level, false)


# FADE

func _fade(to_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", to_alpha, 1.5)
	await tween.finished

#END GAME
# showing the end game screen
func _end_game(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().paused = true
		%EndScreen.visible = true

#START GAME
# hide the start screen
func _on_button_pressed() -> void:
	get_tree().paused = false
	%StartScreen.visible = false

## handle gameplay logic
# need signals for death and attack (because health)

#TODO
# Game freezes when run - likely because code is incomplete
# Finish sorting out player health and death
# Actually make levels
# Finish game overview on start screen
# sound effects for death and jumping
# check music
# Fix attack animation for player
