extends Node2D
@onready var fade: ColorRect = $Fade
@onready var collect: AudioStreamPlayer2D = %Collect

# setting what level the player is on 
var level = 1

# defining variaable in global scope
var current_level_root = null

# starting health
# the player should be able to take two hits and then die to the third
var health = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# setting up the fade effect
	fade.modulate.a = 1.0
	
	# setting up the level
	current_level_root = get_node("LevelRoot")
	
	await _load_level(level, true)
	
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
	
	await _setup_level(current_level_root)
	
	# fade in
	await _fade(0.0)
	

# funtion for setting up the level
# e.g. setting up the signal for the snails to emit
func _setup_level(level_root) -> void:

	#connect enemies
	var enemies = level_root.get_node_or_null("Enemies")
	
	if enemies:
		for enemy in enemies.get_children():
			enemy.player_hit.connect(_on_player_hit)
	
	# connecting exit/end game signal
	
	if level == 10:
		var prize = level_root.get_node_or_null("Prize")
		prize.body_entered.connect(_end_game)
		
	elif level < 10:
		var exit = level_root.get_node_or_null("Exit")
		exit.body_entered.connect(_on_exit_body_entered)
		
# SIGNAL HANDLERS

func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		level += 1
		body.can_move = false
		await _load_level(level, false)

func _on_player_hit(body) -> void:
	
	print("player hit function called")
	if body.name == "Player":
		body.lose_health()
		
		if body.health == 0:
			_on_player_died(body)

# FADE

func _fade(to_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", to_alpha, 1.5)
	await tween.finished

#DEAD PLAYER

func _on_player_died(body) -> void:
	body.die()
	print("player died")
	await _load_level(level, false)

#END GAME
# showing the end game screen
func _end_game(body: Node2D) -> void:
	if body.name == "Player":
		collect.play()
		body.can_move = false
		%EndScreen.visible = true

#START GAME
# hide the start screen
func _on_button_pressed() -> void:
	%StartScreen.visible = false

## handle gameplay logic
# need signals for death and attack (because health)

#TODO
# Actually make levels
# Fix attack & damage animation for player
# fade not playing
# finish adding comments to code
# game icon
