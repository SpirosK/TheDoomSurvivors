extends CharacterBody2D

var health = 60                     #Imp  Health in Doom1 (design notes)
var is_stunned = false
var is_shooting = false
const CHANCE_TO_BE_HURT_STUNNED = 0.25  #1 in 4 to be stunned
const SHOOTING_DISTANCE = 600       #To start shooting fireballs from far, in order to motivate player
const SHOOTING_CHANCE = 0.1
const STANDOFF_DISTANCE = 100       #won't get closer than that, behind soldiers and "bombard" player (design notes)
const VELOCITY = 150.0              #a little slower than soldier, gives player time to deal with faster enemies (balance notes)
const FIREBALL = preload("res://weapons/enemy_weapons/impball.tscn")
signal enemy_died

var player1

## Initially: Walks to the player from wherever it is!
#
func _ready():
	player1 = get_node("/root/Game/Player1")
	get_node("AnimatedImp/health").text = str(health)
	var animation_direction = get_animation_direction()
	%AnimatedImp.play("walk"+animation_direction)


## Every tick: it either moves, is stunned, shoots fireball, or dies.
#
func _physics_process(_delta):
	var direction = global_position.direction_to(player1.global_position)
	var distance_from_player = global_position.distance_to(player1.global_position)
	if health <= 0 or is_stunned or is_shooting:
		velocity = direction * 0.0
	else:
		#normal state: if it can shoot, it might stand and shoot
		if distance_from_player <= SHOOTING_DISTANCE and randf() < SHOOTING_CHANCE:
			velocity = direction * 0.0
			shoot_player()
		else:
			velocity = direction * VELOCITY

	# Stopping at Standoff distance block overrides all else
	if distance_from_player <= STANDOFF_DISTANCE:
		velocity = direction * 0.0
	move_and_slide()


## Enemy is damaged, there is a possibility of hurt-stunning (if not dead)
#
func take_damage(bullet_damage):
	health -= bullet_damage
	get_node("AnimatedImp/health").text = str(health)
	if health <= 0:
		%imp_death.global_position = global_position
		%imp_death.play()
		%CollisionImp.set_deferred("disabled", true) #not get shot while dying
		%AnimatedImp.play("death")
	else:
		if (randf() < CHANCE_TO_BE_HURT_STUNNED):
			is_stunned = true
			play_hurt()
	
## Plays the proper "walk animation"
#
func play_walk():
	var animation_direction = get_animation_direction()
	%AnimatedImp.play("walk"+animation_direction)

## Plays the "pain animation"
#
func play_hurt():
	%imp_pain.global_position = global_position
	%imp_pain.play()
	var animation_direction = get_animation_direction()
	%AnimatedImp.play("hurt"+animation_direction)

#The chance to shoot is calculated before this is called
# No monster infighting for now (design notes)
#
func shoot_player():
	is_shooting = true
	%imp_shoot.global_position = global_position
	%imp_shoot.play()
	var animation_direction = get_animation_direction()
	%AnimatedImp.play("shoot"+animation_direction)
	var new_impball = FIREBALL.instantiate()
	new_impball.init(global_position.direction_to(player1.global_position))
	new_impball.global_position = global_position
	new_impball.add_to_group("projectiles")
	get_parent().add_child(new_impball)

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
		var animation_direction = get_animation_direction()
		%AnimatedImp.play("walk"+animation_direction)
