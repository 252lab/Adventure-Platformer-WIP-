extends CharacterBody2D

# retriving nodes as variables
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var attack_sound: AudioStreamPlayer2D = $AttackSound

# setting constants
const SPEED = 300.0
const JUMP_VELOCITY = -600.0

# starting health
# the player should be able to take two hits and then die to the third
var health = 3

# flag to check if the player is alive
var alive = true;

# flag for if the player can move the sprite
var can_move = true;

#flag for checking if the player is attacking the enemy
var is_player_attacking = false

# used to prevent idle and running animations from overwriting current animations from being played
var overwrite_animation = false


func _physics_process(delta: float) -> void:
	
	# if the player is dead, don't run the function
	if !alive:
		return
	
	#adding the gravity
	if not is_on_floor():
		velocity += get_gravity()*delta
	
	# if the player can move
	if can_move: 
		#handling jump movement and sound
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			jump_sound.play()
			
		#get the input direction and handle the movement/deceleration
		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		# allows the player to move
		move_and_slide()
		
		#checking what direction the player is moving
		if direction == 1.0:
			animated_sprite_2d.flip_h = false
		elif direction == -1.0:
			animated_sprite_2d.flip_h = true

# function for playing animations
func _process(_delta: float) -> void:
	
		# if the player is dead, don't run the function
	if !alive:
		return
	
	#adding animation for player sprite
	# if the player is moving, play the run animation
	# otherwise play the idle animation
	
	if overwrite_animation == false:
		if velocity.x > 1 or velocity.x < -1 and is_on_floor():
			animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("idle")
	
	# if the player can move
	if can_move: 
		
		#if the player is jumping
		# play the jump animation
		if not is_on_floor():
			animated_sprite_2d.play("jumping")
			await animated_sprite_2d.animation_finished
		
		# if the player is attacking
		# play the attack animation
		# freezes on the second frame - TODO
		if Input.is_action_just_pressed("attack"):
			is_player_attacking = true
			overwrite_animation = true
			attack_sound.play()
			animated_sprite_2d.play("attacking")
			await animated_sprite_2d.animation_finished
			overwrite_animation = false
			is_player_attacking = false
			
			
# if the player has been hit, play the hit animation
# also the player loses health
func lose_health() -> void:
	overwrite_animation = true
	animated_sprite_2d.play("hit")
	await animated_sprite_2d.animation_finished
	health -=1
	overwrite_animation = false


# handling the player's death
# play the die animation and sets the alive flag to false
func die() -> void:
	overwrite_animation = true
	animated_sprite_2d.play("die")
	await animated_sprite_2d.animation_finished
	alive = false
	overwrite_animation = false
