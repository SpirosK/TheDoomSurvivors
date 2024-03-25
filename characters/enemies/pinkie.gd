extends CharacterBody2D

## Pinkie is a "disruptive" monster
# It will run towards the player and try to bite him! (also blocks him - design notes)
# If the player moves out of the biting range though, before it completes he will take no damage.
#
var health = 120             #pinkie Health in Doom1 is 150 (design notes)
var is_stunned = false
var is_biting = false
const CHANCE_TO_BE_HURT_STUNNED = 0.7
const BITING_DISTANCE = 75
const BITING_CHANCE = 0.80
const STANDOFF_DISTANCE = 45 #won't get closer than that
const DMG_DONE = 20
const VELOCITY = 320.0
signal enemy_died

var player1

## Initially: Walks to the player from wherever it is!
#
func _ready():
	player1 = get_node("/root/Game/Player1")
	get_node("AnimatedPinkie/health").text = str(health)
	var animation_direction = get_animation_direction()
	%AnimatedPinkie.play("walk"+animation_direction)


## Every tick: it either moves, is stunned, bites, or dies.
#
func _physics_process(_delta):
	var direction = global_position.direction_to(player1.global_position)
	var distance_from_player = global_position.distance_to(player1.global_position)
	#dead/stunned/biting things don't move
	if health <= 0 or is_stunned or is_biting:
		velocity = direction * 0.0
	else:
		#if it is in biting distance, it might stand and bite
		if distance_from_player <= BITING_DISTANCE:
			if randf() < BITING_CHANCE:
				velocity = direction * 0.0
				bite_player()
		else:
			if distance_from_player <= STANDOFF_DISTANCE:
				velocity = direction * 0.0
			else:
				velocity = direction * VELOCITY
	move_and_slide()


## Enemy is damaged, there is a possibility of hurt-stunning (if not dead)
#
func take_damage(bullet_damage) -> void:
	health -= bullet_damage
	get_node("AnimatedPinkie/health").text = str(health)
	if health <= 0:
		%pinkie_death.global_position = global_position
		%pinkie_death.play()
		%CollisionPinkie.set_deferred("disabled", true) #not get shot while dying
		%AnimatedPinkie.play("death")
	else:
		if (randf() < CHANCE_TO_BE_HURT_STUNNED):
			is_stunned = true
			play_hurt()
	

## Plays the proper "walk animation"
#
func play_walk() -> void:
	var animation_direction = get_animation_direction()
	%AnimatedPinkie.play("walk"+animation_direction)

## Plays the proper "pain animation"
#
func play_hurt() -> void:
	%pinkie_pain.global_position = global_position
	%pinkie_pain.play()
	var animation_direction = get_animation_direction()
	%AnimatedPinkie.play("hurt"+animation_direction)

#The chance to bite is calculated before it is called
# Damage will  be calculated at end of animation (player might have walked away)
#
func bite_player() -> void:
	%pinkie_bite.global_position = global_position
	%pinkie_bite.play()
	is_biting = true
	var animation_direction = get_animation_direction()
	%AnimatedPinkie.play("shoot"+animation_direction)

## Returns the animation direction to use (would be great in the singleton, if I knew it then)
#
func get_animation_direction() -> String:
	var direction = global_position.direction_to(player1.global_position)
	var LR_dir = ""
	var UD_dir = ""

	if direction[0] < 0:
		LR_dir = "L"
	elif direction[0] > 0:
		LR_dir = "R"
	else:
		LR_dir = " "

	if direction[1] < 0:
		UD_dir = "U"
	elif direction[1] > 0:
		UD_dir = "D"
	else:
		UD_dir = " "
	
	var final_dir_string = UD_dir+LR_dir

	match final_dir_string:
		"U ":
			return ("_up")
		"D ":
			return("_down")
		" L":
			return("_left")
		" R":
			return("_right")
		"DL":
			return("_down_left")
		"DR":
			return("_down_right")
		"UL":
			return("_up_left")
		"UR":
			return("_up_right")
		_:
			return ("_down")
			
## What to do when an animation finishes playing
# Animations that "end": Death, Hurt and Shoot
#
func _on_animation_finished() -> void:
	#If enemy was dead => bye!
	if health <=0:
		enemy_died.emit()
		queue_free()
	else:
		# if it was biting, it's time to check if player is damaged (not walked away)
		if is_biting:
			is_stunned = false
			is_biting = false
			var distance_from_player = global_position.distance_to(player1.global_position)
			if distance_from_player <= BITING_DISTANCE:
				damage_player()
		else:
			is_stunned = false
		var animation_direction = get_animation_direction()
		%AnimatedPinkie.play("walk"+animation_direction)


## Damages the player "instantly" 
#in Doom1: 30 
#Here    : 20 (balance notes)
#
func damage_player() -> void:
	player1.take_damage(DMG_DONE)
