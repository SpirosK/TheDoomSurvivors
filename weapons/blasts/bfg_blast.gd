## The blast of the Rocket
# (in order to calculate enemies in range that will get hit)
# Differs from the Rocket one, as it spawns non-hitting copies of itself on all enemies affected!
#
extends Area2D

var damaged = false
var not_played_sfx = true

## Plays the Sound (normally it should be at a Singleton Sound Player)
#
func play_sfx():
	%BFGBlast_sound.global_position = global_position
	%BFGBlast_sound.play()

#It's a bit stupid implementation, but at the very first frame, it doesn't find any overlapping bodies! (and it's only 3 frames anyway)
# Also another minor bug: if the first enemy has died and was the only one, there is no enemy left to trigger this!
# However this doesn't affect the game's performance -> it forces me to use not_played_sfx though (not needed if I was using a Singleton Sound player)
#
func _physics_process(_delta):
	if not damaged:
		var enemies_in_range = get_overlapping_bodies()	
		if enemies_in_range.size() > 0:
			damaged = true
			#dmg in Doom1 = 15-120 per one of 40 tracers -VS- HERE: (30-200) per enemy in range (design notes)
			for enemy in enemies_in_range:
				if enemy.has_method("take_damage"):
					const BFG_BLAST = preload("res://weapons/blasts/bfg_blast.tscn")
					var new_blast = BFG_BLAST.instantiate()
					new_blast.global_position = enemy.global_position
					new_blast.damaged=true                #We only want the animation from the copy!!
					get_parent().add_child(new_blast)
					enemy.take_damage(30 + randi() % 171) #30-2000 for each enemy affected && animation on them
		if not_played_sfx:
			play_sfx()
			not_played_sfx = false
	%AnimatedBFGBlast.play("blow") #will disappear at end
	

## The Only non-looping animation is the "blow up" animation --> then it goes away
# 
func _on_animation_finished():
	%AnimatedBFGBlast.visible = false

## When the sound has finished playing, it can be discarded (not needed if I was using a Singleton Sound player)
# 
func _on_sound_finished():
	queue_free()
