#This is the player's Bullet (same for Pistol/Machine Gun/Shotgun)
extends Area2D

var travelled_distance = 0
const BULLET_SPEED = 1400
const BULLET_RANGE = 1600

## Each tick: it moves along, until it moves no more
#
func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	position = position + direction * BULLET_SPEED * delta
	
	travelled_distance = travelled_distance + BULLET_SPEED * delta
	if travelled_distance > BULLET_RANGE:
		queue_free()


## This function damages characters it enters (and then disappears).
#
func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage( int(10 + randf() * 10) ) #5-15 in Doom1 / 10+ here
	queue_free()
