## This is the player's Rocket
#
extends Area2D

var travelled_distance = 0
var is_blowing = false     #is it blowing up at this moment?
const ROCKET_SPEED = 400   #slower than most, stil faster than bfg (balance note)
const ROCKET_RANGE = 1200  #if it misses it will disappear later



## Each tick: it moves along, unless it is blowing up!
#
func _physics_process(delta):
	var distance_travelled_this_delta = 0 
	if not is_blowing:   #if yes blowing: just stays where it is
		distance_travelled_this_delta = ROCKET_SPEED * delta
		var direction = Vector2.RIGHT.rotated(rotation)
		position = position + direction * distance_travelled_this_delta
		travelled_distance = travelled_distance + distance_travelled_this_delta
		#Blows by itself after max_distance travelled (no need to track them when out of scope)
		if travelled_distance > ROCKET_RANGE:
			%RocketCollision.set_deferred("disabled", true)
			call_rocket_blast()
	%AnimatedRocket.play("move") #This should be static image ideally
	

## This function performs the Splash Damage
#
# Couldn't just use the animation, because of the new collision box that we need to have.
# Perhaps we could have two areas and enable/disable them, but I prefer this
# 
func call_rocket_blast():
	const ROCKET_BLAST = preload("res://weapons/blasts/rocketblast.tscn")
	var new_blast = ROCKET_BLAST.instantiate()
	new_blast.global_position = %AnimatedRocket.global_position
	#It has to be a sibling, as this will go away now!
	get_parent().call_deferred("add_child", new_blast)
	queue_free()

## This function damages the character it enters. Then calls the Rocket Blast for splash damage
#
func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(20 + randi() % 61) #20-160 in Doom1 / 20-80 here (balance note)
	is_blowing = true	
	%RocketCollision.set_deferred("disabled", true)
	call_rocket_blast()
