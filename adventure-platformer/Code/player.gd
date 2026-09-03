extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


const SPEED = 300.0
const JUMP_VELOCITY = -850.0

# starting health
# the player should be able to take two hits and then die to the third
var health = 3.0

# flag to check if the player is alive
var alive = true;

# flag for if the player can move the sprite
var can_move = true;

#physics function - created by godot

func _physics_process(delta: float) -> void:
	
	# if the player is dead, don't run the function
	if !alive:
		return
	
	#adding the gravity
	if not is_on_floor():
		velocity += get_gravity()*delta
	
	# if the player can move
	if can_move: 
		#handling jump movement
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			
		#get the input direction and handle the movement/deceleration
		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
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
	if velocity.x > 1 or velocity.x < -1 and is_on_floor():
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	# if the player can move
	if can_move: 
		#handling jump animation
		if not is_on_floor():
			animated_sprite_2d.play("jumping")
		
		# handling attack animation
		# freezes on the second frame - TODO
		if Input.is_action_pressed("attack"):
			animated_sprite_2d.play("attacking")
			
# handling the player's death
func die() -> void:
	animated_sprite_2d.animation = "die"
	alive = false
