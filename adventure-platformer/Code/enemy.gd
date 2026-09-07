extends Area2D
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
	
	if !is_attacking:
		#updating the position of the enemy
		position.x += direction * SPEED * delta

func _on_timer_timeout() -> void:
	# flip the direction of movement
	direction *= -1.
	
	#updating the animation
	animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h

# if player has pressed attack key, play die animation
# if not emit signal and play attack animation

#handling if the player collides with an enemy
# checks to see if the player attacks the enemy or not
func _on_body_entered(body: Node2D) -> void:
	attack_sound.play()
	
	# if the player hits the enemy, kill the enemy
	if body.name == "Player" and body.alive and Input.is_action_pressed("attack"):
		animated_sprite_2d.animation = "die"
		queue_free()
		
		# if the player collides with the enemy and isn't attacking it
	elif body.name == "Player" and body.alive:
		animated_sprite_2d.play("attacking")
		is_attacking = true
		emit_signal("player_hit", body)
		print("collision")

# once the attack animation has been completed, switch back to the run animation
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "attacking":
		is_attacking = false
		animated_sprite_2d.play("run")
