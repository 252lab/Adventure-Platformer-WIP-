extends Node2D

# retriving nodes as variables
@onready var collect: AudioStreamPlayer2D = %Collect
@onready var fade: CanvasLayer = $Fade

# setting what level the player is on 
var level = 1

# defining variable in global scope
var current_level_root = null

# starting health
# the player should be able to take two hits and then die to the third
var health = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# setting up the level
	# retriving the current level root
	current_level_root = get_node("LevelRoot")
	
	# loading the first level (set to one so level 1)
	await _load_level(level)
	
# LEVEL MANAGEMENT

# function for loading all levels
func _load_level(level_number) -> void:

# if there is a current level loaded, unload it
	if current_level_root:
		current_level_root.queue_free()
	
	# retrieving new level to be loaded
	var level_path = "res://scenes/levels/level%s.tscn" %level_number
	
	# setting the new level as the level root node
	current_level_root = load(level_path).instantiate()
	add_child(current_level_root)
	current_level_root.name = "LevelRoot"
	
	# setting up the new level
	await _setup_level(current_level_root)
	
	# fade in the new level
	await fade.fade(0.0, 1.5).finished

# funtion for setting up the level
func _setup_level(level_root) -> void:

	#connecting the enemies
	var enemies = level_root.get_node_or_null("Enemies")
	
	# connecting the player hit signal 
	if enemies:
		for enemy in enemies.get_children():
			enemy.player_hit.connect(_on_player_hit)
	
	# connecting exit/end game signal
# if the level is the final level, connect the _end_game function
	if level == 10:
		var prize = level_root.get_node_or_null("Prize")
		prize.body_entered.connect(_end_game)
	
	# otherwise connect the function to trigger a level change
	elif level < 10:
		var exit = level_root.get_node_or_null("Exit")
		exit.body_entered.connect(_on_exit_body_entered)
		
# SIGNAL HANDLERS

# when the player enters the level's exit
# take them to the next level
func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		
		# increase the level by one and make sure the playr can't move
		level += 1
		body.can_move = false
		
		#fade out the current level and load the new one
		await fade.fade(1.0, 1.5).finished
		await _load_level(level)
		

# handling if the player has been hit
func _on_player_hit(body) -> void:
	
	# player loses health when hit
	if body.name == "Player":
		body.lose_health()
	
	# if the player has no health left, they die
		if body.health == 0:
			_on_player_died(body)

#DEAD PLAYER

#handling when the player dies
# just sends them back to the start of the level
func _on_player_died(body) -> void:
	body.die()
	print("player died")
	await _load_level(level)

#END GAME
# handles once the player has completed the game
func _end_game(body: Node2D) -> void:
	if body.name == "Player":
		
		# indicate that the player has collected the treasure
		collect.play()
		
		# stops the player from moving
		body.can_move = false
		
		# shows the ending screen
		%EndScreen.visible = true

#START GAME
# hides the start screen once the start button has been pressed
# the player can also now move
func _on_button_pressed() -> void:
	%StartScreen.visible = false



#TODO
# Actually make levels
# game icon
# fix die animation for
# fix attacking, hit and die animations for player
# also handle attack damage for player and enemy
# make it so the player can't move until start button pressed
