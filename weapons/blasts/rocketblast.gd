## The blast of the Rocket
# (in order to calculate enemies in range that will get hit)
#
extends Area2D

var damaged = false
var not_played_sfx = true

## Plays the Sound (normally it should be at a Singleton Sound Player)
#
func play_sfx():
	%rocket_blast_sound.global_position = global_position
	%rocket_blast_sound.play()

#It's a bit stupid implementation, but at the very first frame, it doesn't find any overlapping bodies! (and it's only 3 frames anyway)
# Also another minor bug: if the first enemy has died and was the only one, there is no enemy left to trigger this!
# However this doesn't affect the game's performance -> it forces me to use not_played_sfx though (not needed if I was using a Singleton Sound player)
#
func _physics_process(_delta):
	if not damaged:
		var enemies_in_range = get_overlapping_bodies()	
		if enemies_in_range.size() > 0:
			damaged = true
		if not_played_sfx:
			play_sfx()
			not_played_sfx = false
		for enemy in enemies_in_range:
			if enemy.has_method("take_damage"):
				enemy.take_damage(randi() % 61)              #0-128  in Doom1 / 0-60 here (balance notes)
		%RocketBlastCollision.set_deferred("disabled", true) #no more enemies damaged!
	%AnimatedRocketBlast.play("blow")                        #will be invisible at end of animation (to play SFX too)
	

## The Only non-looping animation is the "blow up" animation --> then it goes away
# 
func _on_animation_finished():
	%AnimatedRocketBlast.visible = false

## When the sound has finished playing, it can be discarded (not needed if I was using a Singleton Sound player)
# 
func _on_sound_finished():
	queue_free()
