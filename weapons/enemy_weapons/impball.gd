## The ball that the Imp throws at the player
#
extends Area2D

var travelled_distance = 0
var direction = Vector2.ZERO
var is_blowing = false     #is it blowing up right now?
const IMPBALL_SPEED = 600  #less than half speed of player's bullet (design notes)
const IMPBALL_RANGE = 1200 #if it misses it will disappear later

## Constructor: Takes the direction and "move"s towards it
#
func init(init_direction):
	direction = init_direction
	%AnimatedBall.play("move")
	

## Each tick: it moves along, unless it is blowing up!
#
func _physics_process(delta):
	var distance_travelled_this_delta = 0
	if not is_blowing:
		distance_travelled_this_delta = IMPBALL_SPEED * delta
		position = position + direction * distance_travelled_this_delta
		travelled_distance = travelled_distance + distance_travelled_this_delta
		if travelled_distance > IMPBALL_RANGE and not is_blowing:
			is_blowing = true	
			%AnimatedBall.play("blow") #will queue_free at end

## This function damages the character it enters. Only.
#
func _on_body_entered(body):
	if is_blowing:
		return
	if body.has_method("take_damage"):
		body.take_damage(3 + randi() % 15) #3-24 in Doom1 / 3-18 here (balance notes)
	is_blowing = true
	%ImpballCollision.set_deferred("disabled", true)
	%AnimatedBall.play("blow")

## The Only non-looping animation is the "blow up" animation --> then it goes away
# 
func _on_animation_finished():
	queue_free()
