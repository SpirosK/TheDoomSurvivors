extends Area2D

var enemies_in_range_now = 0

## Each tick it gets the enemies in range and targets the closest one
#
func _physics_process(_delta):
	var enemies_in_range = get_overlapping_bodies()
	
	if enemies_in_range.size() > 0:
		var target_enemy = enemies_in_range[0]
		look_at(target_enemy.global_position)

	enemies_in_range_now = enemies_in_range.size()

## Function that is called in order to disable itself.
# Actually stopes the timer (no shooting) and becomes invisible
func disable_me():
	$rocket_launcher_pivot/rocket_launcher_model.set_deferred("visible", false)
	%rocket_launcher_timer.stop()

## Function that is called in order to enable itself.
# Becomes visible and timer starts again!
func enable_me():
	$rocket_launcher_pivot/rocket_launcher_model.set_deferred("visible", true)
	%rocket_launcher_timer.start()

## This function shoots the gun (is called on timer event)
#  It: checks for enemies, checks and spends the ammo, plays the sound, creates the rocket!
#
func shoot():
	var the_player = get_parent()

	#not shooting if noone to shoot
	if enemies_in_range_now <= 0:
		return
	
	# It's by design to lose a "click" on auto weapong change
	if the_player.get_ammo(the_player.ROCKET_AMMO) <= 0:
		the_player.ammo_done()
		return
	else:
		the_player.spend_ammo(the_player.ROCKET_AMMO, 1)

	%rocket_launcher_sound.global_position = %rocket_launcher_muzzle.global_position
	%rocket_launcher_sound.play()
	
	const ROCKET = preload("res://weapons/projectiles/rocket.tscn")
	var new_rocket = ROCKET.instantiate()
	new_rocket.global_position = %rocket_launcher_muzzle.global_position
	new_rocket.global_rotation = %rocket_launcher_muzzle.global_rotation
	#Adding to parent (the player) so they don't disappear when weapon changes etc
	get_parent().add_child(new_rocket)


## Shoot timer timeout
#
func _on_timer_timeout():
	shoot()
