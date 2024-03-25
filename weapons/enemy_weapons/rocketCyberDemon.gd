## This is the cyberdemon's Rocket
# It's faster than the player's. It would be great if we could just inherit from a base object, but I don't know how to in GDScript (yet)
#
extends Area2D

var travelled_distance = 0
var direction = Vector2.ZERO
var is_blowing = false     #is it blowing up at this moment?
const ROCKET_SPEED = 800   #much faster than player's rockets
const ROCKET_RANGE = 1800  #if it misses it will disappear later (but due to big shooting-range it's bigger than player's)

## Constructor: Direction and rotation given, then "move"s.
#
func init(init_direction):
	direction = init_direction
	global_rotation = direction.angle()
	#print ("GR: " + str(rad_to_deg(global_rotation)))
	%AnimatedRocketCD.play("move")


## Each tick: it moves along, unless it is blowing up!
#
func _physics_process(delta):
	var distance_travelled_this_delta = 0
	if not is_blowing:
		distance_travelled_this_delta = ROCKET_SPEED * delta
		position = position + direction * distance_travelled_this_delta
		travelled_distance = travelled_distance + distance_travelled_this_delta
		if travelled_distance > ROCKET_RANGE and not is_blowing:
			is_blowing = true	
			%AnimatedRocketCD.play("blow") #will queue_free at end
	

## This function damages the character it enters.
# As I decided to not damage other enemies, no splash damage here (design notes)
#
func _on_body_entered(body):
	if is_blowing:
		return
	if body.has_method("take_damage"):
		body.take_damage(30 + randi() % 61) #20-160 (direct hit) in Doom1 / 30-90 here (balance notes)
	is_blowing = true	
	%RocketCDCollision.set_deferred("disabled", true) #no more collisions/hits
	%AnimatedRocketCD.play("blow")


## The Only non-looping animation is the "blow up" animation --> then it goes away
# 
func _on_animation_finished():
	queue_free()
