extends Area2D

var travelled_distance = 0
var is_blowing = false  #is it blowing up at this moment?
const BFG_SPEED = 300   #slower than all (balance notes)
const BFG_RANGE = 1200  #if it misses it will disappear later


## Each tick: it moves along, unless it is blowing up!
#
func _physics_process(delta):
	var distance_travelled_this_delta = 0
	if not is_blowing:
		distance_travelled_this_delta = BFG_SPEED * delta
		var direction = Vector2.RIGHT.rotated(rotation)
		position = position + direction * distance_travelled_this_delta
		travelled_distance = travelled_distance + distance_travelled_this_delta
		# Disappears (no blast)  by itself after max_distance travelled
		if travelled_distance > BFG_RANGE and not is_blowing:
			%BFG_ballCollision.set_deferred("disabled", true)
			%AnimatedBFG_ball.play("disappear")
			queue_free()
		%AnimatedBFG_ball.play("move")
	

## This funcτion performs the Splash Damage
#
# Couldn't just use the animation, because of the new collision box that we need to have.
# Perhaps we could have two areas and enable/disable them, but I prefer this now
# 
func call_bfg_blast():
	const BFG_BLAST = preload("res://weapons/blasts/bfg_blast.tscn")
	var new_blast = BFG_BLAST.instantiate()
	new_blast.global_position = %AnimatedBFG_ball.global_position
	#It has to be a sibling, as this will go away now!
	get_parent().call_deferred("add_child", new_blast)
	queue_free()

## This function damages characters it enters. Then calls the BFG Blast for "super splash" damage
#
func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(100 + 100 * (randi() % 8)) #100-860 in Doom1 / here too --tracing damage in the blast
	is_blowing = true	
	%BFG_ballCollision.set_deferred("disabled", true) #no more contacts
	call_bfg_blast()
