## The slime that the Baron throws at the player
#
extends Area2D

var travelled_distance = 0
var direction = Vector2.ZERO
var is_blowing = false   #is it blowing up right now?
const SLIME_SPEED = 900  #faster than imp (design notes)
const SLIME_RANGE = 1200 #if it misses it will disappear a bit later

## Constructor: looks towards player and "move"s there
#
func init(knight_position, player1):
	direction = knight_position.direction_to(player1.global_position)
	global_rotation = direction.angle()
	%AnimatedSlime.play("move")
	

## Each tick: it moves along, unless it is blowing up!
#
func _physics_process(delta):
	var distance_travelled_this_delta = 0
	if not is_blowing:
		distance_travelled_this_delta = SLIME_SPEED * delta
		position = position + direction * distance_travelled_this_delta
		travelled_distance = travelled_distance + distance_travelled_this_delta
		if travelled_distance > SLIME_RANGE and not is_blowing:
			is_blowing = true	
			%AnimatedSlime.play("blow") #will queue_free at end
	

## This function damages the character it enters. Only.
#
func _on_body_entered(body):
	if is_blowing:
		return
	if body.has_method("take_damage"):
		body.take_damage(8 + randi() % 30) #8-64 in Doom1 / 8-38 here (balance notes)
	is_blowing = true	
	%SlimeballCollision.set_deferred("disabled", true)
	%AnimatedSlime.play("blow")

## The Only non-looping animation is the "blow up" animation --> then it goes away
# 
func _on_animation_finished():
	queue_free()
