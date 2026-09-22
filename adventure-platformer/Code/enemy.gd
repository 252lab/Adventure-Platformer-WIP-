extends Area2D # extending nide

# retriving nodes as variables
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_sound: AudioStreamPlayer2D = $AttackSound


#signal to indicate that the player has been hit
signal player_hit

#movement speed of the enemy
const SPEED = 30.0

#starting direction of the enemy - starts by facing right
var direction = 1.0

#variable to check if the enemy is attacking
var is_attacking = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# if the enemy is not attacking
	# it can move
	if !is_attacking:
		#updating the position of the enemy
		position.x += direction * SPEED * delta

#handling if the player collides with an enemy
# checks to see if the player attacks the enemy or not
func _on_body_entered(body: Node2D) -> void:
	
	# if the player hits the enemy, kill the enemy
	# the enemy being removed is handled in the is animation finished signal receiver
	# otherwise animation won't play in full
	if body.name == "Player" and body.alive and body.is_player_attacking == true:
		animated_sprite_2d.animation = "die"
		await animated_sprite_2d.animation_finished
		queue_free()

	# if the player collides with the enemy and isn't attacking it
	# damage the player
	# and play the attack sound
	elif body.name == "Player" and body.alive and body.is_player_attacking == false:
		attack_sound.play()
		is_attacking = true
		animated_sprite_2d.play("attacking")
		emit_signal("player_hit", body)
		await animated_sprite_2d.animation_finished
		is_attacking = false
		animated_sprite_2d.play("run")
		
#Handling collision with the tile ma

# if the enemy collides with a wall, flip the direction of movement
func _on_side_collision_body_entered(body: Node2D) -> void:
	if body.name == "TileMapLayer":
			# flip the direction of movement
			direction *= -1.
	
			#updating the animation
			animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h

# if the left side of an enemy is about to walk of a platform, flip the direction of movement
func _on_floor_left_collision_body_exited(body: Node2D) -> void:
	if body.name == "TileMapLayer":
		# flip the direction of movement
		direction *= -1.
	
		#updating the animation
		animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h

# if the right side of an enemy is about to walk of a platform, flip the direction of movement
func _on_floor_right_collision_body_exited(body: Node2D) -> void:
	if body.name == "TileMapLayer":
		# flip the direction of movement
		direction *= -1.
	
		#updating the animation
		animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
