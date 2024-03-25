#This is the player's Plasma Ball
extends Area2D

var travelled_distance = 0
var direction = Vector2.ZERO
var is_blowing = false        #is it blowing up at this moment?
const PLASMABALL_SPEED = 900  #speed is between impball and bullet (balance note)
const PLASMABALL_RANGE = 1000 #less range than other weapons (balance note)

## Initially we set it upon a direction
#
func init():
	direction = Vector2.RIGHT.rotated(rotation)
	%PlasmaballAnimation.play("move")

## Each tick: it moves along, unless it is blowing up!
#
func _physics_process(delta):
	var distance_travelled_this_delta = 0
	if not is_blowing:   #if yes blowing: just stays where it is
		distance_travelled_this_delta = PLASMABALL_SPEED * delta
		position = position + direction * distance_travelled_this_delta
		travelled_distance = travelled_distance + distance_travelled_this_delta
		if travelled_distance > PLASMABALL_RANGE:
			is_blowing = true	
			%PlasmaballAnimation.play("blow") #will queue_free at end
	

## This function damages characters it enters.
#
func _on_body_entered(body):
	if is_blowing:
		return
	if body.has_method("take_damage"):
		body.take_damage(5 + randi() % 29) #5-40 in Doom1 / 5-33 here (balance note)
	is_blowing = true	
	%PlasmaballCollision.set_deferred("disabled", true) #no more activations
	%PlasmaballAnimation.play("blow")

## Freeing up after the only non-loop animation: blow up 
#
func _on_animation_finished():
	queue_free()
