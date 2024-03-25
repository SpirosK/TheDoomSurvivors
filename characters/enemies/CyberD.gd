extends CharacterBody2D

var health = 4000                #Cyberdemon Health in Doom 1 (design notes)
var is_stunned = false
var is_shooting = false
const CHANCE_TO_BE_HURT_STUNNED = 0.01  #1 in 100 to be stunned
const SHOOTING_DISTANCE = 1000   # We want them to start shooting from VERY far, to scare players
const SHOOTING_CHANCE = 0.1      # 1 in 10 to shoot rocket (more than enough!)
const STANDOFF_DISTANCE = 200    # Won't get too close to the player (it would be obliterating, with its rocket speed)
const VELOCITY = 250.0           # It's quite fast! But not too much!
const ROCKETCD = preload("res://weapons/enemy_weapons/rocketCyberDemon.tscn")
signal enemy_died

var player1

## Initially: Walks to the player from wherever it is!
#
func _ready():
	player1 = get_node("/root/Game/Player1")
	get_node("AnimatedCyberD/health").text = str(health)
	play_walk()

## Every tick: it either moves, is stunned, shoots rockets, or dies.
#
func _physics_process(_delta):
	var direction = global_position.direction_to(player1.global_position)
	var distance_from_player = global_position.distance_to(player1.global_position)
	if health <= 0 or is_stunned or is_shooting:
		velocity = Vector2.ZERO
	else:
		#normal state: if it can shoot, it might stand and shoot
		if distance_from_player <= SHOOTING_DISTANCE and randf() < SHOOTING_CHANCE:
			velocity = Vector2.ZERO
			shoot_player()
		else:
			velocity = direction * VELOCITY

	# Stopping at Standoff distance block overrides all else
	if distance_from_player <= STANDOFF_DISTANCE:
		velocity = Vector2.ZERO  #stops at standoff distance (for damage reasons mostly)	
	move_and_slide()

## Enemy is damaged, there is a possibility of hurt-stunning (if not dead)
#
func take_damage(bullet_damage):
	health -= bullet_damage
	get_node("AnimatedCyberD/health").text = str(health)
	if health <= 0:
		%cyberdemon_death.global_position = global_position
		%cyberdemon_death.play()
		%CollisionCyberD.set_deferred("disabled", true) #not get shot while dying
		%AnimatedCyberD.play("death")
	else:
		if (randf() < CHANCE_TO_BE_HURT_STUNNED):
			is_stunned = true
			play_hurt()
	

## Plays the proper "walk animation"
#
func play_walk():
	var animation_direction = get_animation_direction()
	%AnimatedCyberD.play("walk"+animation_direction)

## Plays the "pain animation"
#
func play_hurt():
	%cyberdemon_pain.global_position = global_position
	%cyberdemon_pain.play()
	var animation_direction = get_animation_direction()
	%AnimatedCyberD.play("hurt"+animation_direction)

#The chance to shoot is calculated before this is called
# No monster infighting for now (design notes)
#
func shoot_player():
	is_shooting = true
	%cyberdemon_shoot.global_position = global_position
	%cyberdemon_shoot.play()
	var animation_direction = get_animation_direction()
	%AnimatedCyberD.play("shoot"+animation_direction)
	var new_rocket_cd = ROCKETCD.instantiate()
	new_rocket_cd.init(global_position.direction_to(player1.global_position))
	new_rocket_cd.global_position = global_position
	new_rocket_cd.add_to_group("projectiles")
	get_parent().add_child(new_rocket_cd)

## Returns the animation direction to use (would be great in the singleton, if I knew it then)
#
func get_animation_direction():
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
func _on_animation_finished():
	#If enemy was dead => bye!
	if health <=0:
		enemy_died.emit()
		queue_free()
	else: 
		# if it was shooting: it's shooting no more!
		if is_shooting:
			is_shooting = false
		# And also not stunned anymore: No IF needed for this
		is_stunned = false
		play_walk()


## Plays the sound of walking after each step finishes animating
#  (couldn't find a better way to to do it from this, and be consistent)
#
func _on_walk_play_timer_timeout():
	%cyberdemon_walk.global_position = global_position
	%cyberdemon_walk.play()
