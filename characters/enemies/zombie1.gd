## Pistol Zombie Enemy
#
extends CharacterBody2D

var health = 20 #Zombieman Health in Doom1 (design notes)
var is_stunned = false
var is_shooting = false
const CHANCE_TO_BE_HURT_STUNNED = 0.5
const SHOOTING_DISTANCE = 280
const SHOOTING_CHANCE = 0.2
const SHOOTING_SUCCESS_CHANCE = 0.4
const STANDOFF_DISTANCE = 80   #won't get closer than that
const DMG_MODIFIER = 3
const VELOCITY = 200.0
signal enemy_died

var player1

## Initially: Walks to the player from wherever it is!
#
func _ready():
	player1 = get_node("/root/Game/Player1")
	get_node("AnimatedZombie1/health").text = str(health)
	var animation_direction = get_animation_direction()
	%AnimatedZombie1.play("walk"+animation_direction)

## Every tick: it either moves, is stunned, shoots, or dies.
#
func _physics_process(_delta):
	var direction = global_position.direction_to(player1.global_position)
	var distance_from_player = global_position.distance_to(player1.global_position)

	#dead/stunned/shooting enemies don't move
	if health <= 0 or is_stunned or is_shooting:
		velocity = direction * 0.0
	else:
		#normal state: if it can shoot, it might stand and shoot
		if distance_from_player <= SHOOTING_DISTANCE and randf() < SHOOTING_CHANCE:
			velocity = direction * 0.0 #dead things don't move
			shoot_player()
		else:
			velocity = direction * VELOCITY

	# Stopping at Standoff distance block overrides all else
	if distance_from_player <= STANDOFF_DISTANCE:
		velocity = direction * 0.0
	move_and_slide()


## Enemy is damaged, there is a possibility of hurt-stunning (if not dead)
#
func take_damage(bullet_damage) -> void:
	health -= bullet_damage
	get_node("AnimatedZombie1/health").text = str(health)
	if health <= 0:
		%zombie_death.global_position = global_position
		%zombie_death.play()
		%CollisionZombie1.set_deferred("disabled", true) #not get shot while dying
		%AnimatedZombie1.play("death")
	else:
		if (randf() < CHANCE_TO_BE_HURT_STUNNED):
			is_stunned = true
			play_hurt()


## Plays the proper "walk animation"
#
func play_walk() -> void:
	var animation_direction = get_animation_direction()
	%AnimatedZombie1.play("walk"+animation_direction)


## Plays the "pain animation"
#
func play_hurt() -> void:
	%zombie_pain.global_position = global_position
	%zombie_pain.play()
	var animation_direction = get_animation_direction()
	%AnimatedZombie1.play("hurt"+animation_direction)

#The chance to shoot is calculated before this is called
# No monster infighting for now (design notes)
#
func shoot_player() -> void:
	%zombie_shoot.global_position = global_position
	%zombie_shoot.play()
	is_shooting = true
	var animation_direction = get_animation_direction()
	%AnimatedZombie1.play("shoot"+animation_direction)

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
		# Shoot once only and deal damage instantly
		if is_shooting:
			is_stunned = false
			is_shooting = false
			if randf() < SHOOTING_SUCCESS_CHANCE:
				damage_player()
		else:
			# Hurt no more!
			is_stunned = false
		var animation_direction = get_animation_direction()
		%AnimatedZombie1.play("walk"+animation_direction)


## Damages the player instantly ("scan and hit" enemy -- minus the "scan")
#in Doom1: 3 to 15 damage
#Here    : 1 to DMG_MODIFIER+1 dmg randomly (design notes)
#
func damage_player() -> void:
	var damage = 1+int(randf()*DMG_MODIFIER)
	player1.take_damage(damage) 
